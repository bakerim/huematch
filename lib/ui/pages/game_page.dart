import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart';
import '../widgets/game_card.dart';
import '../widgets/pause_dialog.dart';
import 'result_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // 🔥 BUG FIX: initState içindeki startGame çağrısını sildik!
  // Çünkü "ResultPage" ve "LevelMapPage" oyunu başlatıp zaten buraya yönlendiriyor.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            if (gameProvider.isGameOver && !gameProvider.isTimeUp) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ResultPage()),
                );
              });
            }

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTopBar(context, gameProvider, theme),
                    const SizedBox(height: 24),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildGrid(gameProvider),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!gameProvider.isTimeUp && !gameProvider.isGameOver)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildPauseButton(
                                context,
                                gameProvider,
                                theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildHintButton(
                                context,
                                gameProvider,
                                theme,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),

                if (gameProvider.isTimeUp)
                  _buildTimesUpOverlay(context, gameProvider, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    bool isPanic = provider.timeLeft <= 10;
    Color timerBgColor = isPanic
        ? const Color(0xFFE53935)
        : theme.colorScheme.primary;
    Color timerTextColor = isPanic
        ? Colors.white
        : theme.scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${provider.cards.where((c) => c.isMatched).length ~/ 2} / 10',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          TweenAnimationBuilder(
            key: ValueKey(provider.timeLeft),
            tween: Tween<double>(begin: isPanic ? 1.15 : 1.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: timerBgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isPanic
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE53935).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: timerTextColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${provider.timeLeft}s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: timerTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        provider.pauseGame();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PauseDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pause_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                "DURDUR",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    bool hasFreeHint = provider.hintCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (provider.isLocked) return;
        provider.useHint(() {
          AdManager.showRewardedAd(
            context: context,
            onRewardEarned: () {
              provider.addHints(1);
              provider.useHint(() {});
            },
            onClosed: () {},
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasFreeHint
                ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                : [const Color(0xFFE53935), const Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  (hasFreeHint
                          ? theme.colorScheme.secondary
                          : const Color(0xFFE53935))
                      .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFreeHint ? Icons.search_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                hasFreeHint ? "İPUCU (${provider.hintCount})" : "İPUCU (İZLE)",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(GameProvider provider) {
    if (provider.cards.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: provider.cards.length,
      itemBuilder: (context, index) {
        final card = provider.cards[index];
        return GameCard(
          card: card,
          index: index,
          onTap: () => provider.onCardTapped(index),
        );
      },
    );
  }

  Widget _buildTimesUpOverlay(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          color: theme.scaffoldBackgroundColor.withOpacity(0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_off_rounded,
                    size: 72,
                    color: Color(0xFFE53935),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SÜRE BİTTİ!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Çok yaklaşmıştın! Bölümü geçmek için ekstra zamana ihtiyacın var.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        AdManager.showRewardedAd(
                          context: context,
                          onRewardEarned: () {
                            provider.addExtraTime(15);
                          },
                          onClosed: () {},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill_rounded, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "+15 Saniye Kazan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ResultPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary.withOpacity(
                          0.5,
                        ),
                      ),
                      child: const Text(
                        "Pes Et ve Çık",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
