import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 DİL MOTORU EKLENDİ

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd; 
  static bool _isShowingAd = false;

  static String get interstitialAdUnitId =>
      'ca-app-pub-3940256099942544/1033173712';
  static String get rewardedAdUnitId =>
      'ca-app-pub-3940256099942544/5224354917';
  static String get bannerAdUnitId =>
      'ca-app-pub-3940256099942544/6300978111'; 
  static String get appOpenAdUnitId =>
      'ca-app-pub-3940256099942544/9257395921'; 

  static BannerAd createBannerAd({BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? BannerAdListener(
        onAdLoaded: (ad) => debugPrint('✅ Banner Yüklendi!'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner Hata: ${error.message}');
          ad.dispose();
        },
      ),
    ); 
  }

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
          loadInterstitialAd(); 
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
      onClosed(); 
      loadInterstitialAd(); 
    }
  }

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
          onRewardEarned(); 
        },
      );
      _rewardedAd = null;
    } else {
      debugPrint('⚠️ Reklam yok ama oyuncu mağdur edilmiyor!');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ad_not_loaded_fallback".tr(), // 🔥 DİNAMİK YAZI
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      onRewardEarned(); 
      loadRewardedAd(); 
      onClosed();      
    }
  }

  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Açılış Reklamı Yüklendi!');
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
      loadAppOpenAd(); 
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); 
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