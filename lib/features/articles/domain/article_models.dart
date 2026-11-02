class Article {
  const Article({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.readTime,
    required this.publishDate,
    required this.author,
    required this.imageUrl,
    required this.tags,
    required this.isFeatured,
  });

  final String id;
  final String slug;
  final String title;
  final String category;
  final String summary;
  final List<String> content;
  final String readTime;
  final String publishDate;
  final String author;
  final String imageUrl;
  final List<String> tags;
  final bool isFeatured;

  bool get isValid => id.isNotEmpty && slug.isNotEmpty && title.isNotEmpty;

  factory Article.fromJson(
    Map<String, dynamic> json, {
    required String Function(String value) resolveImageUrl,
  }) {
    final rawContent = json['content'];
    final content = switch (rawContent) {
      List value =>
        value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
      String value when value.trim().isNotEmpty => [value.trim()],
      _ => const <String>[],
    };
    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final image = json['image']?.toString().trim() ?? '';
    return Article(
      id: json['id']?.toString().trim() ?? '',
      slug: json['slug']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      summary: json['summary']?.toString().trim() ?? '',
      content: List.unmodifiable(content),
      readTime: json['readTime']?.toString().trim() ?? '',
      publishDate: json['publishDate']?.toString().trim() ?? '',
      author: json['author']?.toString().trim() ?? '',
      imageUrl: image.isEmpty ? '' : resolveImageUrl(image),
      tags: List.unmodifiable(tags),
      isFeatured: json['isFeatured'] == true,
    );
  }
}

class ArticleCatalog {
  const ArticleCatalog({
    required this.categories,
    required this.articles,
    this.featured,
  });

  final List<String> categories;
  final Article? featured;
  final List<Article> articles;

  Article? findBySlug(String slug) {
    final normalized = slug.trim();
    if (normalized.isEmpty) return null;
    if (featured?.slug == normalized) return featured;
    for (final article in articles) {
      if (article.slug == normalized) return article;
    }
    return null;
  }
}
