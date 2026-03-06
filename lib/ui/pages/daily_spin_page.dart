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

class _DailySpinPageState extends State<DailySpinPage> {
  // Oyun Durumları: 
  // 0 -> Bekliyor (Kartlar kapalı)
  // 1 -> Dağıtılıyor (Ödüller gösteriliyor)
  // 2 -> Seçim Bekleniyor (Kartlar kapalı)
  // 3 -> Bitti (Ödül alındı)
  int _gameState = 0; 
  int? _selectedIndex;
  
  // Ödül Havuzu (Her seferinde karışacak)
  final List<int> _currentRewards = [10, 50, 100];

  void _startRound(GameProvider provider, bool isFree) {
    if (_gameState != 0 && _gameState != 3) return;

    setState(() {
      _gameState = 1; // Kartlar yüzünü gösteriyor
      _selectedIndex = null;
      _currentRewards.shuffle(Random()); // Ödülleri gizlice karıştır
    });

    // 1.5 saniye ödülleri göster, sonra kapat ve seçim bekle
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _gameState = 2; // Artık oyuncu seçebilir
        });
      }
    });
  }

  void _onCardTapped(int index, GameProvider provider, bool isFree) {
    if (_gameState != 2) return; // Sadece seçim aşamasındaysa tıklanabilir

    setState(() {
      _selectedIndex = index;
      _gameState = 3; // Oyun bitti
    });

    final wonAmount = _currentRewards[index];
    
    // Ödülü motora kaydet (isFree parametresi günlük hakkı sıfırlamak için)
    // Ancak oyuncu zaten hakkını _startRound butonuna basarken kullandı varsayıyoruz.
    provider.applySpinReward(wonAmount, isFree);

    // 1 Saniye sonra kutlama ekranını aç
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) _showResultDialog(wonAmount);
    });
  }

  void _showResultDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            "GİZEM ÇÖZÜLDÜ!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: amount == 100 ? const Color(0xFFFFD54F).withOpacity(0.2) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  amount == 100 ? Icons.diamond_rounded : Icons.monetization_on_rounded,
                  size: 64,
                  color: amount == 100 ? const Color(0xFFFFD54F) : const Color(0xFF66BB6A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "+$amount ALTIN",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Cüzdanına başarıyla eklendi.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
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
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("HARİKA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "ŞANSLI KART",
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Premium Cüzdan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87, 
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${provider.totalCoins}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 28),
                ],
              ),
            ),
            
            const Spacer(),

            // Bilgi Metni
            Text(
              _gameState == 0 ? "Şansını denemeye hazır mısın?" :
              _gameState == 1 ? "Ödülleri aklında tut!" :
              _gameState == 2 ? "Kartını Seç!" : "İşte kazancın!",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w800, 
                color: _gameState == 2 ? const Color(0xFF673AB7) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // --- GİZEMLİ KARTLAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  // Kartın hangi yüzünü göstereceğini belirliyoruz
                  bool showFront = _gameState == 1 || (_gameState == 3 && _selectedIndex == index);
                  bool isDimmed = _gameState == 3 && _selectedIndex != index; // Seçilmeyen kartlar solar
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => _onCardTapped(index, provider, canSpinFree),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isDimmed ? 0.4 : 1.0,
                          child: _build3DCard(showFront, _currentRewards[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // --- AKSİYON BUTONLARI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
              child: _gameState == 0 || _gameState == 3
                  ? (canSpinFree
                      ? SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () => _startRound(provider, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: const Color(0xFFFFD54F), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.3),
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
                                context: context, // BURASI GÜNCELLENDİ
                                onRewardEarned: () => _startRound(provider, false),
                                onClosed: () {},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: const Color(0xFF673AB7).withOpacity(0.5),
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
                  : SizedBox( // Oyun esnasında boş yer tutucu
                      height: 64,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3D KART ÇEVİRME ANİMASYONU ---
  Widget _build3DCard(bool showFront, int rewardAmount) {
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
          ? _buildCardFront(rewardAmount, key: const ValueKey(true))
          : _buildCardBack(key: const ValueKey(false)),
    );
  }

  // KARTIN ÖN YÜZÜ (Ödül)
  Widget _buildCardFront(int amount, {Key? key}) {
    bool isJackpot = amount == 100;
    
    return Container(
      key: key,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJackpot ? const Color(0xFFFFD54F) : Colors.grey.shade300, 
          width: isJackpot ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isJackpot ? const Color(0xFFFFD54F).withOpacity(0.4) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isJackpot ? Icons.diamond_rounded : Icons.monetization_on_rounded, 
              color: isJackpot ? const Color(0xFFFFD54F) : const Color(0xFF66BB6A), 
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              "$amount",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isJackpot ? const Color(0xFFFFD54F) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTIN ARKA YÜZÜ (Gizem)
  Widget _buildCardBack({Key? key}) {
    return Container(
      key: key,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2D42), Color(0xFF14151F)], // Tycoon/Gece teması gradyanı
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 6))
        ],
      ),
      child: Center(
        child: Icon(Icons.help_outline_rounded, color: Colors.white.withOpacity(0.3), size: 48),
      ),
    );
  }
}