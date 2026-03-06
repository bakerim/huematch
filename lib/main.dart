import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ADMOB EKLENDİ
import 'package:provider/provider.dart';

import 'data/providers/game_provider.dart';
import 'data/services/ad_manager.dart'; // AD MANAGER EKLENDİ
import 'ui/pages/menu_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Reklam SDK'sını ve ilk reklamları arka planda yükle
  await MobileAds.instance.initialize();
  AdManager.loadInterstitialAd();
  AdManager.loadRewardedAd();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.dark, 
      statusBarBrightness: Brightness.light, 
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const HueMatchApp());
  });
}

class HueMatchApp extends StatelessWidget {
  const HueMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'HueMatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black87,
            background: const Color(0xFFF8F9FA),
            primary: Colors.black87,
          ),
          fontFamily: 'Roboto', 
        ),
        home: const MenuPage(),
      ),
    );
  }
}