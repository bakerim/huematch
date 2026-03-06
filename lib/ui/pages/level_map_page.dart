import 'dart:math'; // Sinüs dalgaları ve matematik için gerekli
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';
import 'game_page.dart';

class LevelMapPage extends StatelessWidget {
  const LevelMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final highestLevel = provider.highestLevel;
    
    // Oyuncuya her zaman en az 100 bölüm gösterir. İlerledikçe ufuk genişler!
    final totalLevelsToShow = max(100, highestLevel + 20);

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
          "YOLCULUK",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          reverse: true, // Aşağıdan yukarıya doğru akar
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 80, bottom: 40), // Üstten ve alttan ferahlık
          itemCount: totalLevelsToShow,
          itemBuilder: (context, index) {
            final levelNumber = index + 1;
            final isCompleted = levelNumber < highestLevel;
            final isCurrent = levelNumber == highestLevel;
            final isLocked = levelNumber > highestLevel;
            
            // --- MATEMATİKSEL SİHİR BURADA BAŞLIYOR ---
            // Sinüs dalgası (Sine Wave) ile bölümleri sağa ve sola organik olarak kıvrıltıyoruz
            // 0.8 katsayısı kıvrımların sıklığını, 100 ise sağa/sola genişliğini belirler
            final currentX = sin(levelNumber * 0.8) * 100;
            final nextX = sin((levelNumber + 1) * 0.8) * 100;

            final isLastNode = levelNumber == totalLevelsToShow;

            return _buildLevelNode(
              context: context,
              provider: provider,
              levelNumber: levelNumber,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
              currentX: currentX,
              nextX: nextX,
              isLastNode: isLastNode,
              highestLevel: highestLevel,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelNode({
    required BuildContext context,
    required GameProvider provider,
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required double currentX,
    required double nextX,
    required bool isLastNode,
    required int highestLevel,
  }) {
    // Şimdiki bölümden bir sonrakine giden yolun kilitli olup olmadığı
    final isPathLocked = levelNumber >= highestLevel;

    return SizedBox(
      height: 140, // Kıvrımların ferahça görülebilmesi için dikey mesafe artırıldı
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none, // Çizgilerin kutu dışına taşarak birleşmesini sağlar
        children: [
          // 1. ORGANİK KIVRIMLI ÇİZGİ (BEZIER PATH)
          if (!isLastNode)
            CustomPaint(
              size: const Size(double.infinity, 140),
              painter: SagaPathPainter(
                currentX: currentX,
                nextX: nextX,
                isPathLocked: isPathLocked,
              ),
            ),

          // 2. SEVİYE DÜĞÜMÜ VE ETİKETİ (Dinamik Konumlandırma)
          Center(
            child: Transform.translate(
              offset: Offset(currentX, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Düğüm ekranın sağına kaydıysa, yazıyı soluna koy
                  if (currentX >= 0) _buildLevelLabel(levelNumber, isCurrent, isLocked),
                  if (currentX >= 0) const SizedBox(width: 16),
                  
                  // ANA DÜĞÜM (NODE)
                  GestureDetector(
                    onTap: () {
                      if (!isLocked) {
                        provider.playSpecificLevel(levelNumber);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const GamePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Önce önceki bölümleri tamamlamalısın!", style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.black87,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: isCurrent 
                      ? _buildPulsingNode() 
                      : _buildStaticNode(isLocked),
                  ),

                  // Düğüm ekranın soluna kaydıysa, yazıyı sağına koy
                  if (currentX < 0) const SizedBox(width: 16),
                  if (currentX < 0) _buildLevelLabel(levelNumber, isCurrent, isLocked),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MİNİMALİST YAZI ETİKETİ ---
  Widget _buildLevelLabel(int level, bool isCurrent, bool isLocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.black87 : (isLocked ? Colors.transparent : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: isLocked ? null : Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: isLocked ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        "Seviye $level",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isCurrent ? Colors.white : (isLocked ? Colors.grey.shade400 : Colors.black87),
        ),
      ),
    );
  }

  // --- KİLİTLİ VEYA TAMAMLANMIŞ DÜĞÜM ---
  Widget _buildStaticNode(bool isLocked) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : const Color(0xFF66BB6A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.check_rounded,
        color: isLocked ? Colors.grey.shade400 : Colors.white,
        size: 24,
      ),
    );
  }

  // --- ŞU ANKİ BÖLÜM (PARLAYAN EFEKT) ---
  Widget _buildPulsingNode() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.1),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutSine,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.black87, size: 32),
          ),
        );
      },
      onEnd: () {
        // Sonsuz nefes alma efekti için state'i yormadan basit bir Flutter trick'i
      },
    );
  }
}

// ============================================================================
// MATEMATİKSEL ÇİZİM FIRÇASI (CUBIC BEZIER KIVRIMLARI)
// ============================================================================
class SagaPathPainter extends CustomPainter {
  final double currentX;
  final double nextX;
  final bool isPathLocked;

  SagaPathPainter({
    required this.currentX,
    required this.nextX,
    required this.isPathLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Çizgi Stili
    final paint = Paint()
      ..color = isPathLocked ? Colors.grey.shade300 : const Color(0xFF66BB6A)
      ..strokeWidth = 6 // Kalın ve tok bir yol çizgisi
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Şimdiki düğümün merkezi
    final startX = size.width / 2 + currentX;
    final startY = size.height / 2;

    // Bir sonraki düğümün merkezi (Liste ters olduğu için bir sonraki düğüm yukarıdadır, yani Y değeri negatiftir)
    final endX = size.width / 2 + nextX;
    final endY = -size.height / 2;

    final path = Path();
    path.moveTo(startX, startY);

    // Düz çizgi yerine, uçları yumuşatılmış "S" harfi gibi kıvrılan Kübik Bezier Eğrisi (Cubic Bezier Curve)
    path.cubicTo(
      startX, startY - size.height / 2, // Eğriyi ilk düğümden yukarı doğru dik çeker
      endX, endY + size.height / 2,     // Eğriyi ikinci düğüme aşağıdan dik bağlar
      endX, endY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}