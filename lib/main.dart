import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:smart_oboi/wallpaper_page.dart';
import 'package:smart_oboi/wallpaper_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/' : (context) => WallpaperPage(),
        '/wallpaper_view' : (context) => WallpaperView()
      },
    );
  }
}