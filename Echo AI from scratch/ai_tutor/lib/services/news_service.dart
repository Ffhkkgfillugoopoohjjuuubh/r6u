import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/news_article.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  static const Map<String, String> _feedUrls = {
    'all': 'https://timesofindia.indiatimes.com/rssfeeds/296589292.cms',
    'india': 'https://timesofindia.indiatimes.com/rssfeeds/296589292.cms',
    'education': 'https://www.thehindu.com/education/feeder/default.rss',
    'technology': 'https://feeds.feedburner.com/gadgets360-latest',
    'science': 'https://www.thehindu.com/sci-tech/feeder/default.rss',
  };

  Future<List<NewsArticle>> fetchNews(String category) async {
    try {
      final url = _feedUrls[category] ?? _feedUrls['all']!;
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      final articles = <NewsArticle>[];
      final source = _extractSource(url);

      for (final item in items) {
        final title = _getElementText(item, 'title');
        final description = _cleanHtml(_getElementText(item, 'description'));
        final link = _getElementText(item, 'link');
        final pubDateStr = _getElementText(item, 'pubDate');

        DateTime publishedAt;
        try {
          publishedAt = DateTime.tryParse(pubDateStr) ?? DateTime.now();
        } catch (e) {
          publishedAt = DateTime.now();
        }

        if (title.isNotEmpty) {
          articles.add(NewsArticle(
            title: title,
            description: description,
            url: link,
            source: source,
            publishedAt: publishedAt,
            category: category,
          ));
        }
      }

      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return articles;
    } catch (e) {
      return [];
    }
  }

  String _getElementText(XmlElement parent, String tagName) {
    final element = parent.findElements(tagName).firstOrNull;
    return element?.innerText.trim() ?? '';
  }

  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String _extractSource(String url) {
    final uri = Uri.parse(url);
    return uri.host.replaceFirst('www.', '');
  }
}