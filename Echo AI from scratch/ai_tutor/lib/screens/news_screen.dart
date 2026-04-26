import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../config/app_config.dart';

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String category;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    required this.category,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}

class NewsService {
  static const String _cacheKey = 'cached_news_articles';
  static const int _maxCachedArticles = 50;

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
        return _loadCachedArticles();
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
      
      await _cacheArticles(articles);
      return articles;
    } catch (e) {
      return _loadCachedArticles();
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

  Future<void> _cacheArticles(List<NewsArticle> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = articles.take(_maxCachedArticles).map((a) => a.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  Future<List<NewsArticle>> _loadCachedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return [];
    
    try {
      final jsonList = jsonDecode(cached) as List<dynamic>;
      return jsonList.map((j) => NewsArticle.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}

final newsServiceProvider = NewsService();

final _bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final _newsCategoryProvider = StateProvider<String>((ref) => 'all');
final _newsSearchProvider = StateProvider<String>((ref) => '');

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    final category = ref.read(_newsCategoryProvider);
    final articles = await _newsService.fetchNews(category);
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<NewsArticle> get _filteredArticles {
    final search = _searchController.text.toLowerCase();
    if (search.isEmpty) return _articles;
    return _articles.where((a) => 
      a.title.toLowerCase().contains(search) || 
      a.description.toLowerCase().contains(search)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final categories = [
      ('all', l10n.allNews),
      ('india', l10n.indiaNews),
      ('education', l10n.educationNews),
      ('technology', l10n.techNews),
      ('science', l10n.scienceNews),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search articles...',
                hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.inputRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = ref.watch(_newsCategoryProvider) == cat.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.$2),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(_newsCategoryProvider.notifier).state = cat.$1;
                        _fetchNews();
                      },
                      selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primaryPurple,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected ? AppColors.primaryPurple : textColor,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : _filteredArticles.isEmpty
                    ? _buildEmptyState(secondaryTextColor)
                    : RefreshIndicator(
                        onRefresh: _fetchNews,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                              ),
                              child: InkWell(
                                onTap: () => _launchUrl(article.url),
                                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article.description.length > 120
                                            ? '${article.description.substring(0, 120)}...'
                                            : article.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: secondaryTextColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            article.source,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.primaryPurple,
                                            ),
                                          ),
                                          Text(
                                            _getTimeAgo(article.publishedAt),
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                                .slideY(begin: 0.1);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color secondaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 60,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No news available',
            style: GoogleFonts.inter(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}