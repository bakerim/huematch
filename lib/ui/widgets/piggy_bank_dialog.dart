import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';

class PiggyBankDialog extends StatelessWidget {
  const PiggyBankDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = Theme.of(context);

    // Yüzde kaçı dolmuş hesaplıyoruz (Bar için)
    double fillPercentage =
        provider.piggyBankCoins / provider.maxPiggyBankCoins;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kumbara İkonu (Parlak ve davetkâr)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.savings_rounded,
                  size: 64,
                  color: Color(0xFFFFD54F),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "KUMBARAN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Oynadıkça biriken altınlarını inanılmaz bir indirimle hemen al!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Birikim Barı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Birikim",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  "${provider.piggyBankCoins} / ${provider.maxPiggyBankCoins}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: fillPercentage,
                minHeight: 12,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFD54F),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Kırma Butonu
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: provider.piggyBankCoins > 0
                    ? () {
                        provider.smashPiggyBank(); // ALTINLARI CÜZDANA AKTAR
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  provider.isPiggyBankFull
                      ? "KUMBARAYI KIR (\$0.99)"
                      : "ŞİMDİ AL (\$0.99)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Daha Sonra",
                style: TextStyle(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
