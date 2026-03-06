import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/game_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/pause_dialog.dart'; // Pause menüsü eklendi
import 'result_page.dart'; // Sonuç ekranı eklendi

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    // Sayfa ilk yüklendiğinde oyunu sıfırlayıp başlatıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            
            // Oyun bitiş kontrolü: Eğer 12 çift de bulunduysa sonuç ekranına geç
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
                _buildTopBar(context, gameProvider),
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
  Widget _buildTopBar(BuildContext context, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri/Duraklat Butonu
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // 1. Önce oyun süresini durduruyoruz
              provider.pauseGame();
              
              // 2. Bulanık arka planlı (Buzlu cam) Pause menüsünü açıyoruz
              showDialog(
                context: context,
                barrierDismissible: false, // Dışarı tıklayarak kapanmasını engeller
                builder: (context) => const PauseDialog(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.pause_rounded, color: Colors.black87),
            ),
          ),

          // Eşleşme Skoru (Ortada)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
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
              '${provider.cards.where((c) => c.isMatched).length ~/ 2} / 12',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Zamanlayıcı (Sağda)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87, 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${provider.elapsedSeconds}s',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Kartların Dizildiği Ana Grid (4x6) ---
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