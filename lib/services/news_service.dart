import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news_article.dart';

class NewsService {
  final String apiKey = 'newsapi.org_api_key_here';

  Future<List<NewsArticle>> fetchArticles({String? country, String? source, String? category}) async {
    const String baseUrl = 'https://newsapi.org/v2/top-headlines';
    String url = '$baseUrl?apiKey=$apiKey';

    if (country != null) {
      url += '&country=$country';
    }
    if (source != null) {
      url += '&sources=$source';
    }
    if (category != null) {
      url += '&category=$category';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> articlesJson = jsonData['articles'];
      return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
