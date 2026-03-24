import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart';

class DailySpinPage extends StatefulWidget {
  const DailySpinPage({super.key});

  @override
  State<DailySpinPage> createState() => _DailySpinPageState();
}

class _DailySpinPageState extends State<DailySpinPage> {
  int _gameState = 0;
  int? _selectedIndex;

  final List<int> _originalRewards = [0, 0, 2, 2, 5, 5, 10, 10, 15];
  late List<int> _currentRewards;
  late List<int> _shuffledPositions;

  bool _isGathered = false;
  bool _showFronts = true;

  @override
  void initState() {
    super.initState();
    _currentRewards = List.from(_originalRewards);
    _shuffledPositions = List.generate(9, (index) => index);
  }

  void _startRound(GameProvider provider, bool isFree) {
    if (_gameState != 0 && _gameState != 4) return;

    if (provider.isVibrationEnabled) HapticFeedback.mediumImpact();

    setState(() {
      _gameState = 1;
      _selectedIndex = null;
      _currentRewards = List.from(_originalRewards);
      _shuffledPositions = List.generate(9, (index) => index);
      _showFronts = true;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (provider.isVibrationEnabled) HapticFeedback.selectionClick();
      setState(() => _showFronts = false);

      Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (provider.isVibrationEnabled) HapticFeedback.heavyImpact();
        setState(() {
          _gameState = 2;
          _isGathered = true;
        });

        Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          if (provider.isVibrationEnabled) HapticFeedback.vibrate();
          setState(() {
            _currentRewards.shuffle(Random());
            _shuffledPositions.shuffle(Random());
          });

          Timer(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            if (provider.isVibrationEnabled) HapticFeedback.mediumImpact();
            setState(() {
              _isGathered = false;
              _gameState = 3;
            });
          });
        });
      });
    });
  }

  void _onCardTapped(
    int index,
    GameProvider provider,
    bool isFree,
    ThemeData theme,
  ) {
    if (_gameState != 3) return;

    if (provider.isVibrationEnabled) HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
      _gameState = 4;
    });

    final wonAmount = _currentRewards[index];
    provider.applySpinReward(wonAmount, isFree);

    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) _showResultDialog(wonAmount, theme, provider);
    });
  }

  void _showResultDialog(int amount, ThemeData theme, GameProvider provider) {
    bool isEmpty = amount == 0;
    if (provider.isVibrationEnabled) {
      isEmpty ? HapticFeedback.vibrate() : HapticFeedback.heavyImpact();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                  color: isEmpty
                      ? Colors.red.withValues(alpha: 0.1)
                      : const Color(0xFFFFD54F).withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? theme.colorScheme.primary.withValues(alpha: 0.05)
                        : const Color(0xFFFFD54F).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEmpty ? Icons.close_rounded : Icons.diamond_rounded,
                    size: 64,
                    color: isEmpty
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : const Color(0xFFFFD54F),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEmpty ? "bad_luck".tr() : "+$amount ${"coins".tr().toUpperCase()}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEmpty
                      ? "unlucky_card_empty".tr()
                      : "great_choice_coins_added".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "awesome".tr().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final canSpinFree = provider.canSpinFree;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "lucky_cards".tr().toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${provider.totalCoins}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFD54F),
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _gameState == 0
                  ? "ready_to_try_luck".tr()
                  : _gameState == 1
                  ? "watch_rewards".tr()
                  : _gameState == 2
                  ? "cards_shuffling".tr()
                  : _gameState == 3
                  ? "trust_intuition".tr()
                  : "here_is_your_win".tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: _gameState == 3
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = 12.0;
                    double cardHeight =
                        (constraints.maxHeight - (spacing * 2)) / 3;
                    double cardWidth = cardHeight * 0.8;

                    if (cardWidth * 3 + spacing * 2 > constraints.maxWidth) {
                      cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;
                      cardHeight = cardWidth / 0.8;
                    }

                    final double gridTotalWidth =
                        (cardWidth * 3) + (spacing * 2);
                    final double gridTotalHeight =
                        (cardHeight * 3) + (spacing * 2);
                    final double offsetX =
                        (constraints.maxWidth - gridTotalWidth) / 2;
                    final double offsetY =
                        (constraints.maxHeight - gridTotalHeight) / 2;

                    final double centerX =
                        (constraints.maxWidth / 2) - (cardWidth / 2);
                    final double centerY =
                        (constraints.maxHeight / 2) - (cardHeight / 2);

                    return Stack(
                      children: List.generate(9, (index) {
                        int currentPos = _shuffledPositions.indexOf(index);
                        int row = currentPos ~/ 3;
                        int col = currentPos % 3;

                        double leftPos = _isGathered
                            ? centerX
                            : offsetX + (col * (cardWidth + spacing));
                        double topPos = _isGathered
                            ? centerY
                            : offsetY + (row * (cardHeight + spacing));

                        bool isSelected = _selectedIndex == index;
                        bool showFront =
                            _showFronts || (_gameState == 4 && isSelected);
                        bool isDimmed = _gameState == 4 && !isSelected;

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubicEmphasized,
                          left: leftPos,
                          top: topPos,
                          width: cardWidth,
                          height: cardHeight,
                          child: GestureDetector(
                            onTap: () => _onCardTapped(
                              index,
                              provider,
                              canSpinFree,
                              theme,
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isDimmed ? 0.3 : 1.0,
                              child: _build3DCard(
                                showFront,
                                _currentRewards[index],
                                theme,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: _gameState == 0 || _gameState == 4
                  ? (canSpinFree
                        ? SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () => _startRound(provider, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    "free_shuffle".tr().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                AdManager.showRewardedAd(
                                  context: context,
                                  onRewardEarned: () =>
                                      _startRound(provider, false),
                                  onClosed: () {},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor: theme.colorScheme.secondary
                                    .withValues(alpha: 0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "watch_ad_shuffle".tr().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                  : const SizedBox(height: 64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DCard(bool showFront, int rewardAmount, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotateAnim = Tween(begin: pi, end: 0.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return AnimatedBuilder(
          animation: rotateAnim,
          child: child,
          builder: (context, widget) {
            final isUnder = (ValueKey(showFront) != widget?.key);
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
      child: showFront
          ? _buildCardFront(rewardAmount, theme, key: const ValueKey(true))
          : _buildCardBack(theme, key: const ValueKey(false)),
    );
  }

  Widget _buildCardFront(int amount, ThemeData theme, {Key? key}) {
    bool isJackpot = amount == 15;
    bool isEmpty = amount == 0;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isJackpot
              ? const Color(0xFFFFD54F)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          width: isJackpot ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isJackpot
                ? const Color(0xFFFFD54F).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEmpty
                  ? Icons.close_rounded
                  : (isJackpot
                        ? Icons.diamond_rounded
                        : Icons.monetization_on_rounded),
              color: isEmpty
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : (isJackpot
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFF66BB6A)),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              isEmpty ? "empty".tr().toUpperCase() : "$amount",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isEmpty
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : (isJackpot
                          ? const Color(0xFFFFD54F)
                          : theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }
}