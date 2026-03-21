import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';

class ScoresPage extends StatelessWidget {
  const ScoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = Theme.of(context); // DİNAMİK TEMA MOTORU

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // TEMA ARKA PLANI
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "İSTATİSTİKLER",
          style: TextStyle(
            color: theme.colorScheme.primary, // DİNAMİK YAZI
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kişisel Rekorların",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary, // DİNAMİK YAZI
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Bu değerler cihazına kaydedilmiştir.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary.withOpacity(0.5), // DİNAMİK SOLUK YAZI
                ),
              ),
              const SizedBox(height: 40),

              _buildStatCard(
                theme: theme,
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFD54F),
                title: "En Yüksek Toplam Puan",
                value: "${provider.highScore}",
              ),
              const SizedBox(height: 20),

              _buildStatCard(
                theme: theme,
                icon: Icons.military_tech_rounded,
                iconColor: const Color(0xFF42A5F5),
                title: "Ulaşılan En Yüksek Seviye",
                value: "Level ${provider.highestLevel}",
              ),
              const SizedBox(height: 20),

              _buildStatCard(
                theme: theme,
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFF66BB6A),
                title: "Mevcut Altın (Cüzdan)",
                value: "${provider.totalCoins} Coin",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // DİNAMİK KART RENGİ
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary, // DİNAMİK DEĞER RENGİ
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}