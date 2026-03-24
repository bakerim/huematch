import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart';
import 'game_page.dart';
import 'menu_page.dart';
import 'level_map_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late bool _isFailed;
  late int _stars;
  late int _levelScore;
  late int _earnedCoins;
  late int _currentLevel;

  @override
  void initState() {
    super.initState();

    final provider = context.read<GameProvider>();
    _isFailed = provider.isTimeUp;
    _stars = _isFailed ? 0 : provider.calculateStars();
    _levelScore = _isFailed ? 0 : provider.lastLevelScore;
    _earnedCoins = _isFailed ? 0 : provider.lastEarnedCoins;
    _currentLevel = provider.currentLevel;

    _loadBannerAd();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _loadBannerAd() {
    _bannerAd = AdManager.createBannerAd(
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Sonuç Sayfası Banner Hatası: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isFailed
                            ? "time_up".tr()
                            : "${"level".tr()} $_currentLevel ${"completed".tr()}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _isFailed
                              ? Colors.redAccent
                              : Colors.grey.shade500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildHeader(_stars, _isFailed),
                      const SizedBox(height: 32),

                      _buildStars(_stars, _isFailed),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "level_score".tr(),
                              "+$_levelScore",
                              theme.colorScheme.primary,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              "earned".tr(),
                              "+$_earnedCoins",
                              const Color(0xFFFFD54F),
                              theme,
                              icon: Icons.monetization_on_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_isFailed)
                        _buildRetryButton(context, gameProvider, theme)
                      else ...[
                        if (!gameProvider.isDoubleCoinClaimed &&
                            _earnedCoins > 0)
                          _buildDoubleCoinsButton(
                            context,
                            gameProvider,
                            _earnedCoins,
                            theme,
                          ),

                        if (gameProvider.isDoubleCoinClaimed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              "coins_doubled".tr(),
                              style: const TextStyle(
                                color: Color(0xFF66BB6A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        if (!gameProvider.isDoubleCoinClaimed &&
                            _earnedCoins > 0)
                          const SizedBox(height: 24),

                        _buildActionButtons(context, gameProvider, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (_isBannerLoaded && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.only(bottom: 8),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleCoinsButton(
    BuildContext context,
    GameProvider provider,
    int amount,
    ThemeData theme,
  ) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              provider.playButtonClickSound();
              AdManager.showRewardedAd(
                context: context,
                onRewardEarned: () {
                  provider.claimDoubleCoins();
                },
                onClosed: () {},
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.black87,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "double_coins".tr(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "${"get_free_coins".tr()} +$amount",
                      style: TextStyle(
                        color: Colors.black87.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              provider.playButtonClickSound();
              provider.restartGame();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "retry".tr().toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: TextButton(
            onPressed: () {
              provider.playButtonClickSound();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MenuPage()),
                (route) => false,
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LevelMapPage()),
              );
            },
            child: Text(
              "back_to_map".tr(),
              style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int stars, bool isFailed) {
    final theme = Theme.of(context);
    String title = "great_job".tr();
    if (isFailed) {
      title = "failed".tr();
    } else if (stars == 3) {
      title = "perfect".tr();
    } else if (stars == 0) {
      title = "barely_finished".tr();
    }

    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: isFailed ? Colors.redAccent : theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStars(int earnedStars, bool isFailed) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isEarned = index < earnedStars && !isFailed;
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
                  color: isEarned
                      ? const Color(0xFFFFD54F)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  shadows: isEarned
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color valueColor,
    ThemeData theme, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
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

  Widget _buildActionButtons(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              provider.playButtonClickSound();
              provider.nextLevel();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              elevation: 0,
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "next_level".tr().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 28),
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
              provider.playButtonClickSound();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MenuPage()),
                (route) => false,
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LevelMapPage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "back_to_map".tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}