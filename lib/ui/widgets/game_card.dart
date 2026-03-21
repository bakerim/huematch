import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/card_model.dart';
import '../../data/providers/game_provider.dart';

class GameCard extends StatelessWidget {
  final CardModel card;
  final int index; // 🔥 YENİ: Kartın sırası (Kıl payı ve ipucu kontrolü için)
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.card,
    required this.index, // 🔥 ZORUNLU KILINDI
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = provider.currentTheme;

    // Ajanlarımız devrede mi?
    bool isHinted = provider.hintedCardIndices.contains(index);
    bool isNearMiss = provider.nearMissIndices.contains(index);

    // --- TEMA (SKIN) TASARIM KURALLARI ---
    Color bgColor = Colors.white;
    Color iconColor = card.color;
    Color closedBgColor = const Color(0xFFE0E0E0);
    BoxBorder? border;
    List<BoxShadow>? shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    if (theme == 'dark_matter') {
      bgColor = const Color(0xFF1A1A1D);
      closedBgColor = const Color(0xFF2C2C2E);
      shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (theme == 'neon') {
      bgColor = Colors.black;
      closedBgColor = const Color(0xFF0D0D0D);
      iconColor = card.color.withOpacity(0.9);
      border = Border.all(color: card.color.withOpacity(0.8), width: 2);
      shadow = [
        BoxShadow(
          color: card.color.withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (theme == 'gold') {
      bgColor = const Color(0xFF121212);
      closedBgColor = const Color(0xFF1C1C1C);
      iconColor = const Color(0xFFFFD54F);
      border = Border.all(
        color: const Color(0xFFFFD54F).withOpacity(0.5),
        width: 1,
      );
      shadow = [
        BoxShadow(
          color: const Color(0xFFFFD54F).withOpacity(0.2),
          blurRadius: 10,
        ),
      ];
    }

    // Eşleşmiş Kartın Solma (Fade) Efekti
    if (card.isMatched) {
      bgColor = bgColor.withOpacity(0.5);
      iconColor = iconColor.withOpacity(0.3);
      border = null;
      shadow = null;
    }

    // 🔥 CİNLİK 1 & 2 GÖRSEL EFEKTLERİ! (Mevcut temayı ezer geçer!)
    if (isNearMiss) {
      // SÜRE BİTİNCE KAHREDEN KAN KIRMIZISI EFEKT!
      bgColor = const Color(0xFFB71C1C);
      iconColor = Colors.white;
      border = Border.all(color: Colors.redAccent, width: 3);
      shadow = [
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.8),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];
    } else if (isHinted) {
      // İPUCU ALINDIĞINDA PARLAYAN NEON YEŞİL EFEKT!
      bgColor = const Color(0xFF1B5E20);
      iconColor = const Color(0xFF39FF14);
      border = Border.all(color: const Color(0xFF39FF14), width: 3);
      shadow = [
        BoxShadow(
          color: const Color(0xFF39FF14).withOpacity(0.8),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];
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
                final value = isUnder
                    ? min(rotateAnim.value, pi / 2)
                    : rotateAnim.value;
                return Transform(
                  transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.001),
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
                    scale: card.isMatched
                        ? 0.8
                        : (isNearMiss
                              ? 1.1
                              : 1.0), // Kıl payı kaçan kartlar biraz BÜYÜR!
                    child: Icon(card.icon, size: 40, color: iconColor),
                  ),
                )
              : Container(key: const ValueKey(false)),
        ),
      ),
    );
  }
}
