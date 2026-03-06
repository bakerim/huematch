import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/card_model.dart';
import '../../data/providers/game_provider.dart';

class GameCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = provider.currentTheme;

    // --- TEMA (SKIN) TASARIM KURALLARI ---
    Color bgColor = Colors.white;
    Color iconColor = card.color;
    Color closedBgColor = const Color(0xFFE0E0E0); // Kapalıyken (Kartın Arkası)
    BoxBorder? border;
    List<BoxShadow>? shadow = [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
    ];

    if (theme == 'dark') {
      bgColor = const Color(0xFF1A1A1D); // Karanlık Madde (Antrasit)
      closedBgColor = const Color(0xFF2C2C2E);
      shadow = [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))];
    } else if (theme == 'neon') {
      bgColor = Colors.black; // Holografik Neon (Siyah zemin üzerine fosforlu hatlar)
      closedBgColor = const Color(0xFF0D0D0D);
      iconColor = card.color.withOpacity(0.9);
      border = Border.all(color: card.color.withOpacity(0.8), width: 2);
      shadow = [BoxShadow(color: card.color.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)];
    } else if (theme == 'gold') {
      bgColor = const Color(0xFF121212); // Royal Gold (Siyah mat zemin, Altın ikonlar)
      closedBgColor = const Color(0xFF1C1C1C);
      iconColor = const Color(0xFFFFD54F); // Altın yaldız rengi
      border = Border.all(color: const Color(0xFFFFD54F).withOpacity(0.5), width: 1);
      shadow = [BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.2), blurRadius: 10)];
    }

    // Eşleşmiş Kartın Solma (Fade) Efekti
    if (card.isMatched) {
      bgColor = bgColor.withOpacity(0.5);
      iconColor = iconColor.withOpacity(0.3);
      border = null;
      shadow = null;
    }

    // --- 3D KART DÖNDÜRME (FLIP) ANİMASYONU ---
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: card.isFlipped ? bgColor : closedBgColor,
          borderRadius: BorderRadius.circular(16),
          border: card.isFlipped ? border : null,
          boxShadow: shadow,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotateAnim,
              child: child,
              builder: (context, widget) {
                final isUnder = (ValueKey(card.isFlipped) != widget?.key);
                final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                return Transform(
                  transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.001), // 3D Derinlik
                  alignment: Alignment.center,
                  child: widget,
                );
              },
            );
          },
          child: card.isFlipped
              ? Center(
                  key: const ValueKey(true),
                  child: Transform.scale(
                    scale: card.isMatched ? 0.8 : 1.0, // Eşleşince hafif küçülür
                    child: Icon(
                      card.icon,
                      size: 40,
                      color: iconColor,
                    ),
                  ),
                )
              : Container(
                  key: const ValueKey(false),
                  // Kapalı kartın arkasına şık bir logo veya desen koyabilirsin. Şimdilik boş ve temiz.
                ),
        ),
      ),
    );
  }
}