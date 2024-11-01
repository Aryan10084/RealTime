import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService newsService = NewsService();
  List<NewsArticle> articles = [];
  String? selectedCountry = 'us';
  String? selectedSource;
  List<String> countries = ['us', 'ca', 'gb', 'de'];
  List<String> sources = ['bbc-news', 'cnn', 'the-verge'];
  List<String> categories = ['Business', 'Entertainment', 'Health', 'Science', 'Sports', 'Technology'];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles({String? category}) async {
    articles = await newsService.fetchArticles(
      country: selectedCountry,
      source: selectedSource,
      category: category,
    );
    setState(() {});
  }

  void refreshFilters() {
    setState(() {
      selectedCountry = 'us';
      selectedSource = null;
      selectedCategory = null;
      articles.clear();
    });
    fetchArticles();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    print("Attempting to launch URL: $url");

    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print("Launched URL successfully.");
      } catch (e) {
        print("Error launching URL: $e");
      }
    } else {
      print("Could not launch URL: $url");
      // Optionally, show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealTime News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedCountry,
                hint: const Text('Select Country'),
                items: countries.map((String country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    fetchArticles();
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedSource,
                hint: const Text('Select Source'),
                items: sources.map((String source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSource = value;
                    fetchArticles();
                  });
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.toUpperCase()),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category : null;
                        });
                        fetchArticles(category: selectedCategory?.toLowerCase());
                      },
                      selectedColor: Colors.blue,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: articles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          height: 150,
                          viewportFraction: 0.9,
                          enlargeCenterPage: true,
                        ),
                        items: articles.take(5).map((article) {
                          return GestureDetector(
                            onTap: () {
                              _launchURL(article.url);
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    article.imageUrl,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return GestureDetector(
                        onTap: () => _launchURL(article.url),
                        child: Card(
                          color: AppColors.cardBackground,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (article.imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    article.imageUrl,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
