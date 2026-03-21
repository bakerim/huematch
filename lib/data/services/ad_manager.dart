import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd; // 🔥 ŞAŞIRTICI HAMLE: AÇILIŞ REKLAMI!
  static bool _isShowingAd = false;

  // --- GOOGLE TEST ADMOB ID'LERİ (Canlıya çıkarken seninkilerle değişecek) ---
  static String get interstitialAdUnitId =>
      'ca-app-pub-3940256099942544/1033173712';
  static String get rewardedAdUnitId =>
      'ca-app-pub-3940256099942544/5224354917';
  static String get bannerAdUnitId =>
      'ca-app-pub-3940256099942544/6300978111'; // 🔥 YENİ: BANNER
  static String get appOpenAdUnitId =>
      'ca-app-pub-3940256099942544/9257395921'; // 🔥 YENİ: APP OPEN

  // =======================================================================
  // 1. SESSİZ İŞÇİ: BANNER REKLAMI (Widget olarak döner, istediğin yere as)
  // =======================================================================
  static BannerAd createBannerAd({BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      // Eğer sayfa kendi dinleyicisini (listener) yollarsa onu kullan, 
      // yollamazsa senin o efsane orijinal log sistemini çalıştır!
      listener: listener ?? BannerAdListener(
        onAdLoaded: (ad) => debugPrint('✅ Banner Yüklendi! Ekmeğimiz pişiyor.'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner Hata: ${error.message}');
          ad.dispose();
        },
      ),
    ); // DİKKAT: Buradaki ..load() kısmını kaldırdık! Çünkü artık sayfalarda kendi ..load() komutumuzu veriyoruz, iki defa yüklemeye çalışıp crash olmasın.
  }

  // =======================================================================
  // 2. KAPI BEKÇİSİ: GEÇİŞ REKLAMI (Interstitial)
  // =======================================================================
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Geçiş Reklamı Yüklendi!');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Geçiş Reklamı Yüklenemedi: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd({required VoidCallback onClosed}) {
    if (_interstitialAd != null && !_isShowingAd) {
      _isShowingAd = true;
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _isShowingAd = false;
          ad.dispose();
          loadInterstitialAd(); // Mermiyi yeniden namluya sür
          onClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowingAd = false;
          ad.dispose();
          loadInterstitialAd();
          onClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onClosed(); // Hazır değilse oyuncuyu bekletme, direkt oyuna sok!
    }
  }

  // =======================================================================
  // 3. ALTIN KANCA: ÖDÜLLÜ REKLAM (Rewarded)
  // =======================================================================
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Ödüllü Reklam Yüklendi!');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Ödüllü Reklam Hata: ${error.message}');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({
    required BuildContext context,
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
  }) {
    if (_rewardedAd != null && !_isShowingAd) {
      _isShowingAd = true;
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _isShowingAd = false;
          ad.dispose();
          loadRewardedAd();
          onClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowingAd = false;
          ad.dispose();
          loadRewardedAd();
          onClosed();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned(); // Müşteri videoyu sonuna kadar izledi, parayı ver!
        },
      );
      _rewardedAd = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Reklam bağlantısı kuruluyor, lütfen 3-4 saniye bekleyip tekrar dene!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      loadRewardedAd();
      onClosed();
    }
  }

  // =======================================================================
  // 4. 🔥 SİNSİ SİLAH: UYGULAMA AÇILIŞ REKLAMI (App Open Ad)
  // =======================================================================
  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Açılış Reklamı (App Open) Pusuya Yattı!');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Açılış Reklamı Yüklenemedi: ${error.message}');
          _appOpenAd = null;
        },
      ),
    );
  }

  static void showAppOpenAdIfAvailable() {
    if (_appOpenAd == null || _isShowingAd) {
      loadAppOpenAd(); // Yoksa yüklemeye başla
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // Bir sonraki açılış için hemen yenisini hazırla
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }
}
