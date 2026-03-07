import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import 'package:provider/provider.dart';

import 'data/providers/game_provider.dart';
import 'data/services/ad_manager.dart'; 
import 'ui/pages/menu_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await MobileAds.instance.initialize();
  AdManager.loadInterstitialAd();
  AdManager.loadRewardedAd();

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
      child: Consumer<GameProvider>(
        builder: (context, provider, child) {
          
          // Artık sadece Karanlık Madde değil, HANGİ tema seçiliyse onu yolluyoruz!
          String currentTheme = provider.currentTheme;

          return MaterialApp(
            title: 'HueMatch',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(currentTheme), // 4 FARKLI TEMAYI TANIYAN MOTOR
            home: const MenuPage(),
          );
        },
      ),
    );
  }

  // ============================================================================
  // FULL DİNAMİK TEMA MOTORU (TÜM SKİNLER EKLENDİ)
  // ============================================================================
  ThemeData _buildTheme(String themeId) {
    switch (themeId) {
      
      case 'dark_matter':
        // 🌌 KARANLIK MADDE (Derin uzay siyahı ve Neon Mavi)
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D0D12), 
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF), 
            secondary: Color(0xFFA100FF), 
            surface: Color(0xFF1A1A24), 
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle.light, 
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
          ),
          fontFamily: 'Roboto',
        );

      case 'neon':
        // 🟩 HOLOGRAFİK NEON (Matris siyahı ve Zehir Yeşili)
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050505), 
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF39FF14), // Neon Yeşil
            secondary: Color(0xFFFF00FF), // Neon Pembe
            surface: Color(0xFF151515), 
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF39FF14)),
            systemOverlayStyle: SystemUiOverlayStyle.light, 
            titleTextStyle: TextStyle(color: Color(0xFF39FF14), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
          ),
          fontFamily: 'Roboto',
        );

      case 'gold':
        // 👑 ROYAL GOLD (Mat siyah ve Altın Yaldız)
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212), 
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700), // Kraliyet Altını
            secondary: Color(0xFFD32F2F), // Tok Kırmızı
            surface: Color(0xFF1E1E1E), 
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFFFD700)),
            systemOverlayStyle: SystemUiOverlayStyle.light, 
            titleTextStyle: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
          ),
          fontFamily: 'Roboto',
        );

      case 'classic':
      default:
        // ☀️ KLASİK BEYAZ (Senin orijinal ferah tasarımın)
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA), 
          colorScheme: const ColorScheme.light(
            primary: Colors.black87,
            secondary: Color(0xFF66BB6A),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            systemOverlayStyle: SystemUiOverlayStyle.dark, 
            titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
          ),
          fontFamily: 'Roboto',
        );
    }
  }
}