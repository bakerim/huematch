import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart'; // Toast mesajları için eklendi

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  // Google Test AdMob ID'leri
  static String get interstitialAdUnitId => 'ca-app-pub-3940256099942544/1033173712';
  static String get rewardedAdUnitId => 'ca-app-pub-3940256099942544/5224354917';

  // --- GEÇİŞ REKLAMI ---
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
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); 
          onClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Geçiş Reklamı Gösterilirken Hata: ${error.message}');
          ad.dispose();
          loadInterstitialAd();
          onClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('⚠️ Geçiş reklamı hazır değildi, pas geçildi.');
      onClosed();
    }
  }

  // --- ÖDÜLLÜ REKLAM ---
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
          debugPrint('❌ Ödüllü Reklam Yüklenemedi: ${error.message}');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({required BuildContext context, required VoidCallback onRewardEarned, required VoidCallback onClosed}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd(); 
          onClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Ödüllü Reklam Gösterilirken Hata: ${error.message}');
          ad.dispose();
          loadRewardedAd();
          onClosed();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardEarned(); 
      });
      _rewardedAd = null;
    } else {
      // REKLAM HAZIR DEĞİLSE OYUNCUYA BİLDİR!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Reklam bağlantısı kuruluyor, lütfen 3-4 saniye bekleyip tekrar dene!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      loadRewardedAd(); // Yüklenmediyse tekrar tetikle
      onClosed();
    }
  }
}