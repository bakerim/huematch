import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart';

class DailySpinPage extends StatefulWidget {
  const DailySpinPage({super.key});

  @override
  State<DailySpinPage> createState() => _DailySpinPageState();
}

class _DailySpinPageState extends State<DailySpinPage> with TickerProviderStateMixin {
  int _gameState = 0; 
  int? _selectedIndex;
  
  final List<int> _originalRewards = [
    0, 0, 0, 
    2, 2, 2, 
    5, 5, 5, 
    10, 10, 
    15
  ];
  
  late List<int> _currentRewards;
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<int> _displayIndices; 

  @override
  void initState() {
    super.initState();
    _currentRewards = List.from(_originalRewards);
    _displayIndices = List.generate(12, (index) => index);
    
    _controllers = List.generate(
      12, 
      (index) => AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 400),
      )
    );
    
    _animations = List.generate(
      12, 
      (index) => Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controllers[index])
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startRound(GameProvider provider, bool isFree) {
    if (_gameState != 0 && _gameState != 4) return;

    setState(() {
      _gameState = 1; 
      _selectedIndex = null;
      _currentRewards.shuffle(Random()); 
      _displayIndices = List.generate(12, (index) => index); 
    });

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _gameState = 2; 
        });
        _shuffleCardsAnimation(5); 
      }
    });
  }

  void _shuffleCardsAnimation(int timesLeft) {
    if (timesLeft == 0) {
      if (mounted) {
        setState(() {
          _gameState = 3; 
        });
      }
      return;
    }

    setState(() {
      _displayIndices.shuffle(Random());
    });

    for (int i = 0; i < 12; i++) {
      double offsetX = (Random().nextDouble() * 2 - 1) * 0.5; 
      double offsetY = (Random().nextDouble() * 2 - 1) * 0.5; 
      
      _animations[i] = Tween<Offset>(
        begin: Offset.zero, 
        end: Offset(offsetX, offsetY)
      ).animate(CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut));
      
      _controllers[i].forward(from: 0.0).then((_) {
        if (mounted) _controllers[i].reverse(); 
      });
    }

    Timer(const Duration(milliseconds: 450), () {
      if (mounted) _shuffleCardsAnimation(timesLeft - 1);
    });
  }

  void _onCardTapped(int index, GameProvider provider, bool isFree, ThemeData theme) {
    if (_gameState != 3) return; 

    setState(() {
      _selectedIndex = index;
      _gameState = 4; 
    });

    final wonAmount = _currentRewards[index];
    provider.applySpinReward(wonAmount, isFree);

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) _showResultDialog(wonAmount, theme);
    });
  }

  void _showResultDialog(int amount, ThemeData theme) {
    bool isEmpty = amount == 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface, // DİNAMİK YÜZEY RENGİ
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEmpty ? "TÜH BE!" : "GİZEM ÇÖZÜLDÜ!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary), // DİNAMİK YAZI
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isEmpty ? theme.colorScheme.primary.withOpacity(0.1) : const Color(0xFFFFD54F).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmpty ? Icons.sentiment_dissatisfied_rounded : Icons.monetization_on_rounded,
                  size: 64,
                  color: isEmpty ? theme.colorScheme.primary.withOpacity(0.5) : const Color(0xFFFFD54F),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEmpty ? "Boş Kart Çıktı" : "+$amount ALTIN",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.primary), // DİNAMİK YAZI
              ),
              const SizedBox(height: 8),
              Text(
                isEmpty ? "Bir dahaki sefere daha şanslı olabilirsin." : "Cüzdanına başarıyla eklendi.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary.withOpacity(0.6)),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // DİNAMİK BUTON
                  foregroundColor: theme.scaffoldBackgroundColor, // DİNAMİK YAZI
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("TAMAM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final canSpinFree = provider.canSpinFree;
    final theme = Theme.of(context); // DİNAMİK TEMA BİLGİSİ

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // TEMA RENGİNE GÖRE DEĞİŞİR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "ŞANSLI KART",
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Premium Cüzdan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // DİNAMİK YÜZEY
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${provider.totalCoins}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 28),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Bilgi Metni
            Text(
              _gameState == 0 ? "Şansını denemeye hazır mısın?" :
              _gameState == 1 ? "Ödülleri aklında tut!" :
              _gameState == 2 ? "Karıııışşşııııyoorr!!!" :
              _gameState == 3 ? "Şimdi Seçimini Yap!" : "İşte kazancın!",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w800, 
                color: _gameState == 3 ? theme.colorScheme.secondary : theme.colorScheme.primary.withOpacity(0.6), // DİNAMİK BİLGİ RENGİ
              ),
            ),
            const SizedBox(height: 24),

            // --- 12'Lİ GİZEMLİ KART MATRİSİ (3x4 GRID) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), 
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8, 
                  ),
                  itemCount: 12,
                  itemBuilder: (context, gridIndex) {
                    int visualIndex = _displayIndices[gridIndex];
                    
                    bool showFront = _gameState == 1 || (_gameState == 4 && _selectedIndex == visualIndex);
                    bool isDimmed = _gameState == 4 && _selectedIndex != visualIndex; 
                    
                    return SlideTransition(
                      position: _animations[gridIndex], 
                      child: GestureDetector(
                        onTap: () => _onCardTapped(visualIndex, provider, canSpinFree, theme),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isDimmed ? 0.4 : 1.0,
                          child: _build3DCard(showFront, _currentRewards[visualIndex], theme),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- AKSİYON BUTONLARI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: _gameState == 0 || _gameState == 4
                  ? (canSpinFree
                      ? SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () => _startRound(provider, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary, // DİNAMİK BUTON
                              foregroundColor: theme.scaffoldBackgroundColor, // DİNAMİK YAZI
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.1),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_mosaic_rounded, size: 28),
                                SizedBox(width: 12),
                                Text("KARTLARI DAĞIT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
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
                                onRewardEarned: () => _startRound(provider, false),
                                onClosed: () {},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary, // DİNAMİK SECONDARY RENGİ (Zıt renk, örneğin neon yeşil)
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: theme.colorScheme.secondary.withOpacity(0.5),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_fill_rounded, size: 28),
                                SizedBox(width: 12),
                                Text("REKLAM İZLE & DAĞIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ))
                  : const SizedBox( // Oyun esnasında buton yerine boşluk
                      height: 64,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3D KART ÇEVİRME ANİMASYONU ---
  Widget _build3DCard(bool showFront, int rewardAmount, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotateAnim = Tween(begin: pi, end: 0.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return AnimatedBuilder(
          animation: rotateAnim,
          child: child,
          builder: (context, widget) {
            final isUnder = (ValueKey(showFront) != widget?.key);
            final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
            return Transform(
              transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.002), 
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

  // KARTIN ÖN YÜZÜ (Ödül)
  Widget _buildCardFront(int amount, ThemeData theme, {Key? key}) {
    bool isJackpot = amount == 15; 
    bool isEmpty = amount == 0;
    
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: isEmpty ? theme.colorScheme.surface.withOpacity(0.6) : theme.colorScheme.surface, // DİNAMİK KART RENGİ
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJackpot ? const Color(0xFFFFD54F) : theme.colorScheme.onSurface.withOpacity(0.1), 
          width: isJackpot ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isJackpot ? const Color(0xFFFFD54F).withOpacity(0.4) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEmpty ? Icons.sentiment_dissatisfied_rounded : (isJackpot ? Icons.diamond_rounded : Icons.monetization_on_rounded), 
              color: isEmpty ? theme.colorScheme.primary.withOpacity(0.4) : (isJackpot ? const Color(0xFFFFD54F) : const Color(0xFF66BB6A)), 
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              "$amount",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isEmpty ? theme.colorScheme.primary.withOpacity(0.4) : (isJackpot ? const Color(0xFFFFD54F) : theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTIN ARKA YÜZÜ (Gizem - DİNAMİK TEMA GRADYANI)
  Widget _buildCardBack(ThemeData theme, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8), // Temanın ana rengi
            theme.colorScheme.secondary.withOpacity(0.8) // Temanın vurgu rengi
          ], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Icon(Icons.help_outline_rounded, color: Colors.white.withOpacity(0.4), size: 36),
      ),
    );
  }
}