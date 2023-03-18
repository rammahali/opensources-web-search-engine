import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageSearch {
  static  String _subscriptionKey = dotenv.env['API_KEY']!;
  static const String _host = 'https://api.bing.microsoft.com';
  static const String _path = '/v7.0/images/search';

  static Future<List<ImageResult>> searchImages(String query) async {
    final queryParams = '?q=' + Uri.encodeQueryComponent(query);
    final uri = _host + _path + queryParams;

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> imageList = data['value'];

    final List<ImageResult> images = imageList.map((image) {
      return ImageResult(
        image['name'],
        image['thumbnailUrl'],
        image['contentUrl'],
      );
    }).toList();

    return images;
  }
  static Future<ImageResult> searchWikiImage(String query) async {
    final queryParams = '?q=' + Uri.encodeQueryComponent(query);
    final uri = _host + _path + queryParams;

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> imageList = data['value'];

    final List<ImageResult> images = imageList.map((image) {
      return ImageResult(
        image['name'],
        image['thumbnailUrl'],
        image['contentUrl'],
      );
    }).toList();

    return images.first;
  }
}