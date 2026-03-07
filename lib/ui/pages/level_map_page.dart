import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';
import 'game_page.dart';

class LevelMapPage extends StatefulWidget {
  const LevelMapPage({super.key});

  @override
  State<LevelMapPage> createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> {
  // Otomatik Odaklanma (Scroll) Kontrolcüsü
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Sayfa render edildikten HEMEN SONRA scroll işlemini tetikle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    if (!mounted) return;
    final provider = context.read<GameProvider>();
    final highestLevel = provider.highestLevel;

    double targetOffset = ((highestLevel - 1) * 140.0) - (MediaQuery.of(context).size.height / 3);
    if (targetOffset < 0) targetOffset = 0;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final highestLevel = provider.highestLevel;
    final theme = Theme.of(context); // DİNAMİK TEMA BİLGİSİ
    
    // Oyuncuya her zaman en az 100 bölüm gösterir.
    final totalLevelsToShow = max(100, highestLevel + 20);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // TEMA RENGİNE GÖRE DEĞİŞİR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary), // DİNAMİK İKON RENGİ
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "YOLCULUK",
          style: TextStyle(
            color: theme.colorScheme.primary, // DİNAMİK YAZI RENGİ
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          controller: _scrollController, 
          reverse: true, 
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 80, bottom: 40), 
          itemCount: totalLevelsToShow,
          itemBuilder: (context, index) {
            final levelNumber = index + 1;
            final isCompleted = levelNumber < highestLevel;
            final isCurrent = levelNumber == highestLevel;
            final isLocked = levelNumber > highestLevel;
            
            final earnedStars = isCompleted ? provider.getStarsForLevel(levelNumber) : 0;

            final currentX = sin(levelNumber * 0.8) * 100;
            final nextX = sin((levelNumber + 1) * 0.8) * 100;
            final isLastNode = levelNumber == totalLevelsToShow;

            return _buildLevelNode(
              context: context,
              provider: provider,
              theme: theme, // Tema bilgisi gönderildi
              levelNumber: levelNumber,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
              earnedStars: earnedStars,
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
    required ThemeData theme,
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required int earnedStars,
    required double currentX,
    required double nextX,
    required bool isLastNode,
    required int highestLevel,
  }) {
    final isPathLocked = levelNumber >= highestLevel;

    return SizedBox(
      height: 140, 
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          // 1. ORGANİK KIVRIMLI ÇİZGİ
          if (!isLastNode)
            CustomPaint(
              size: const Size(double.infinity, 140),
              painter: SagaPathPainter(
                currentX: currentX,
                nextX: nextX,
                isPathLocked: isPathLocked,
                theme: theme, // Tema eklendi
              ),
            ),

          // 2. SEVİYE DÜĞÜMÜ, ETİKETİ VE YILDIZLAR
          Center(
            child: Transform.translate(
              offset: Offset(currentX, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sol taraf
                  if (currentX >= 0) _buildLevelInfoBlock(levelNumber, isCurrent, isLocked, isCompleted, earnedStars, theme),
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
                            content: const Text("Önce önceki bölümleri tamamlamalısın!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            backgroundColor: theme.colorScheme.primary, // Dinamik Hata Rengi
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: isCurrent 
                      ? _buildPulsingNode() 
                      : _buildStaticNode(isLocked, theme),
                  ),

                  // Sağ taraf
                  if (currentX < 0) const SizedBox(width: 16),
                  if (currentX < 0) _buildLevelInfoBlock(levelNumber, isCurrent, isLocked, isCompleted, earnedStars, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfoBlock(int level, bool isCurrent, bool isLocked, bool isCompleted, int earnedStars, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLevelLabel(level, isCurrent, isLocked, theme),
        
        if (isCompleted) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              bool isEarned = index < earnedStars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Icon(
                  isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  // Yıldızlar hep altın rengidir, temadan bağımsız kalması daha şık
                  color: isEarned ? const Color(0xFFFFD54F) : theme.colorScheme.onSurface.withOpacity(0.3),
                  shadows: isEarned 
                    ? [BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.5), blurRadius: 4)]
                    : null,
                ),
              );
            }),
          ),
        ]
      ],
    );
  }

  Widget _buildLevelLabel(int level, bool isCurrent, bool isLocked, ThemeData theme) {
    // Tema moduna göre kilitli yazının rengi değişmeli
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? theme.colorScheme.primary : (isLocked ? Colors.transparent : theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(20),
        border: isLocked ? null : Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1), width: 2),
        boxShadow: isLocked ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        "Seviye $level",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isCurrent 
              ? theme.scaffoldBackgroundColor 
              : (isLocked ? theme.colorScheme.onSurface.withOpacity(isDark ? 0.3 : 0.5) : theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildStaticNode(bool isLocked, ThemeData theme) {
    bool isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isLocked 
          ? (isDark ? const Color(0xFF2A2A35) : Colors.grey.shade200) // Dinamik kilit rengi
          : theme.colorScheme.secondary, // Tamamlanmış seviye rengi
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.surface, width: 4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.check_rounded,
        color: isLocked ? theme.colorScheme.onSurface.withOpacity(isDark ? 0.4 : 0.4) : theme.scaffoldBackgroundColor,
        size: 24,
      ),
    );
  }

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
              color: const Color(0xFFFFD54F), // Şu anki level her temada sarı kalsın, dikkat çeksin
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
      onEnd: () {},
    );
  }
}

class SagaPathPainter extends CustomPainter {
  final double currentX;
  final double nextX;
  final bool isPathLocked;
  final ThemeData theme;

  SagaPathPainter({
    required this.currentX,
    required this.nextX,
    required this.isPathLocked,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    bool isDark = theme.brightness == Brightness.dark;

    final paint = Paint()
      ..color = isPathLocked 
          ? (isDark ? const Color(0xFF2A2A35) : Colors.grey.shade300) // Kilitli yol rengi temaya göre değişir
          : theme.colorScheme.secondary // Açık yol rengi temanın vurgu rengidir
      ..strokeWidth = 6 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startX = size.width / 2 + currentX;
    final startY = size.height / 2;

    final endX = size.width / 2 + nextX;
    final endY = -size.height / 2;

    final path = Path();
    path.moveTo(startX, startY);

    path.cubicTo(
      startX, startY - size.height / 2, 
      endX, endY + size.height / 2,    
      endX, endY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}