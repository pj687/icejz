import 'package:flutter/material.dart';
import 'package:icejz_app/app.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/app_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = await AppCache.create();
  ApiClient.instance.init(cache);
  runApp(IcejzApp(cache: cache));
}
