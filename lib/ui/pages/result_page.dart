import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart'; // Reklam yöneticisi eklendi
import 'game_page.dart';
import 'menu_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final int stars = gameProvider.calculateStars();
    final int levelScore = gameProvider.lastLevelScore;
    final int earnedCoins = gameProvider.lastEarnedCoins;
    final int currentLevel = gameProvider.currentLevel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LEVEL $currentLevel TAMAMLANDI",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade400,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),

                _buildHeader(stars),
                const SizedBox(height: 32),

                _buildStars(stars),
                const SizedBox(height: 32),

                // Puan ve Kazanılan Altın Kartları
                Row(
                  children: [
                    Expanded(child: _buildStatCard("BÖLÜM PUANI", "+$levelScore", Colors.black87)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        "KAZANILAN", 
                        "+$earnedCoins", 
                        const Color(0xFFFFD54F),
                        icon: Icons.monetization_on_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- 2X ALTIN (REWARDED AD) BUTONU ---
                if (!gameProvider.isDoubleCoinClaimed && earnedCoins > 0)
                  _buildDoubleCoinsButton(context, gameProvider, earnedCoins),

                if (gameProvider.isDoubleCoinClaimed)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      "Altınlar İkiye Katlandı! 🎉",
                      style: TextStyle(color: Color(0xFF66BB6A), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                if (!gameProvider.isDoubleCoinClaimed && earnedCoins > 0)
                  const SizedBox(height: 24),

                // Aksiyon Butonları (Sıradaki Seviye & Menü)
                _buildActionButtons(context, gameProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleCoinsButton(BuildContext context, GameProvider provider, int amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)], // Dikkat çekici mor gradyan
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF673AB7).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Ödüllü reklamı göster, bitince parayı ikiye katla!
            // DÜZELTME: context parametresi eklendi
            AdManager.showRewardedAd(
              context: context,
              onRewardEarned: () {
                provider.claimDoubleCoins();
              },
              onClosed: () {
                // Reklam kapandı. Eğer yarıda kestiyse ödül verilmeyecek.
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                "Reklam İzle 2X Kazan (+$amount)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int stars) {
    String title = "Harika İş!";
    if (stars == 3) {
      title = "Kusursuz!";
    } else if (stars == 0) title = "Biraz Yavaş...";

    return Text(
      title,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStars(int earnedStars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isEarned = index < earnedStars;
        double size = index == 1 ? 80.0 : 60.0;
        EdgeInsets margin = index == 1 
            ? const EdgeInsets.only(bottom: 20, left: 10, right: 10) 
            : const EdgeInsets.symmetric(horizontal: 5);

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 200)), 
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: margin,
                child: Icon(
                  isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: size,
                  color: isEarned ? const Color(0xFFFFD54F) : Colors.grey.shade300,
                  shadows: isEarned 
                    ? [BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.5), blurRadius: 15)]
                    : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: valueColor, size: 24),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              // --- GEÇİŞ REKLAMI (INTERSTITIAL) KONTROLÜ ---
              if (provider.shouldShowInterstitial) {
                AdManager.showInterstitialAd(
                  onClosed: () {
                    provider.nextLevel(); 
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const GamePage()),
                    );
                  }
                );
              } else {
                provider.nextLevel(); 
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sıradaki Seviye",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 28),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          height: 64,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MenuPage()),
                (route) => false, 
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Ana Menüye Dön",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}