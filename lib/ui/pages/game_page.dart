import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/game_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/pause_dialog.dart'; 
import 'result_page.dart'; 

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // YENİ: DİNAMİK TEMA MOTORU

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // TEMA RENGİNE GÖRE DEĞİŞİR
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            
            if (gameProvider.isGameOver) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ResultPage()),
                );
              });
            }

            return Column(
              children: [
                const SizedBox(height: 16), 
                _buildTopBar(context, gameProvider, theme), // Tema objesini yolladık
                const SizedBox(height: 24), 
                
                // Oyun Alanı (Grid)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildGrid(gameProvider),
                  ),
                ),
                
                const SizedBox(height: 16), 
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Üst Bilgi Çubuğu (Zaman ve Skor) ---
  Widget _buildTopBar(BuildContext context, GameProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri/Duraklat Butonu
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              provider.pauseGame();
              showDialog(
                context: context,
                barrierDismissible: false, 
                builder: (context) => const PauseDialog(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // DİNAMİK YÜZEY
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.pause_rounded, color: theme.colorScheme.primary), // DİNAMİK İKON
            ),
          ),

          // Eşleşme Skoru (Ortada)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // DİNAMİK YÜZEY
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              '${provider.cards.where((c) => c.isMatched).length ~/ 2} / 10',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary, // DİNAMİK YAZI
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Zamanlayıcı (Sağda - Zıt Renkli Kutu)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // DİNAMİK ZIT ARKA PLAN
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: theme.scaffoldBackgroundColor, size: 18), // DİNAMİK ZIT İKON
                const SizedBox(width: 6),
                Text(
                  '${provider.elapsedSeconds}s',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.scaffoldBackgroundColor, // DİNAMİK ZIT YAZI
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Kartların Dizildiği Ana Grid (Senin orijinal 4 sütunlu yapın) ---
  Widget _buildGrid(GameProvider provider) {
    if (provider.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
          onTap: () => provider.onCardTapped(index),
        );
      },
    );
  }
}