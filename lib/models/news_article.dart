import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsArticle {
  final String title;
  final String imageUrl;
  final String url;

  NewsArticle({required this.title, required this.imageUrl, required this.url});

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'],
    );
  }
}
