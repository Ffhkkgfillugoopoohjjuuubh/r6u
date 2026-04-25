class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String category;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    required this.category,
  });

  factory NewsArticle.fromRssItem(Map<String, dynamic> item, String source) {
    final title = item['title'] ?? '';
    final description = item['description'] ?? '';
    final url = item['url'] ?? '';
    final pubDateStr = item['pubDate'] ?? '';
    
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(pubDateStr);
    } catch (e) {
      publishedAt = DateTime.now();
    }
    
    return NewsArticle(
      title: title,
      description: description,
      url: url,
      source: source,
      publishedAt: publishedAt,
      category: item['category'] ?? 'all',
    );
  }
}