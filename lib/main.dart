import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'data/providers/game_provider.dart';
import 'data/services/ad_manager.dart';
import 'data/services/notification_service.dart';
import 'ui/pages/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ZEKİ BİLDİRİM MOTORUNU BAŞLAT
  await NotificationService().init();

  // 2. REKLAM SDK'SINI BAŞLAT
  await MobileAds.instance.initialize();

  // 3. GARANTİCİ HAMLE: Google'a Test Modunda olduğumuzu bildiriyoruz
  RequestConfiguration configuration = RequestConfiguration(testDeviceIds: []);
  MobileAds.instance.updateRequestConfiguration(configuration);

  // 4. 🔥 REKLAMLARI ÖNCEDEN CEPHANEYE YÜKLE (Açılış reklamı eklendi!)
  AdManager.loadAppOpenAd(); // Sinsi açılış reklamı
  AdManager.loadInterstitialAd(); // Kapı bekçisi
  AdManager.loadRewardedAd(); // Altın kanca

  // 5. EKRANI DİKET POZİSYONA KİLİTLE
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const HueMatchApp());
  });
}

// 🔥 ARTIK STATEFUL: Çünkü telefonun durumunu (alta atılma/açılma) dinleyeceğiz!
class HueMatchApp extends StatefulWidget {
  const HueMatchApp({super.key});

  @override
  State<HueMatchApp> createState() => _HueMatchAppState();
}

class _HueMatchAppState extends State<HueMatchApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajanı göreve başlat
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Ajanı görevden al
    super.dispose();
  }

  // 🔥 UYGULAMANIN DURUMU DEĞİŞTİĞİNDE TETİKLENEN SİNSİ KOD
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // OYUNCU OYUNA GERİ DÖNDÜ! REKLAMI YAPIŞTIR! 💸
      debugPrint("📱 Oyuncu geri döndü, App Open Reklamı tetikleniyor...");
      AdManager.showAppOpenAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: Consumer<GameProvider>(
        builder: (context, provider, child) {
          String currentTheme = provider.currentTheme;

          return MaterialApp(
            title: 'HueMatch',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(currentTheme),
            home: const MenuPage(),
          );
        },
      ),
    );
  }

  // ============================================================================
  // FULL DİNAMİK TEMA MOTORU
  // ============================================================================
  ThemeData _buildTheme(String themeId) {
    switch (themeId) {
      case 'dark_matter':
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
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          fontFamily: 'Roboto',
        );

      case 'neon':
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050505),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF39FF14),
            secondary: Color(0xFFFF00FF),
            surface: Color(0xFF151515),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF39FF14)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: TextStyle(
              color: Color(0xFF39FF14),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          fontFamily: 'Roboto',
        );

      case 'gold':
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            secondary: Color(0xFFD32F2F),
            surface: Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFFFD700)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          fontFamily: 'Roboto',
        );

      case 'classic':
      default:
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
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          fontFamily: 'Roboto',
        );
    }
  }
}
