import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../data/providers/game_provider.dart';

import 'level_map_page.dart'; 
import 'scores_page.dart';
import 'settings_page.dart';
import 'shop_page.dart'; 
import 'daily_spin_page.dart'; // YENİ ÇARK SAYFASI

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(position: _slideAnimation, child: _buildTitleSection()),
                ),

                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(position: _slideAnimation, child: _buildActionButtons(context, provider)),
                ),

                const Spacer(flex: 4), 
              ],
            ),

            Positioned(
              top: 16,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Text("${provider.totalCoins}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                      const SizedBox(width: 6),
                      const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoShape(Icons.change_history_rounded, const Color(0xFF66BB6A)), 
            const SizedBox(width: 8),
            _buildLogoShape(Icons.square_rounded, const Color(0xFFFFA726), isElevated: true), 
            const SizedBox(width: 8),
            _buildLogoShape(Icons.circle, const Color(0xFF42A5F5)), 
          ],
        ),
        const SizedBox(height: 24),
        const Text("HueMatch", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 2.0)),
        const SizedBox(height: 8),
        Text("Odaklan, Eşleştir, Temizle.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade500, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildLogoShape(IconData icon, Color color, {bool isElevated = false}) {
    return Container(
      width: isElevated ? 56 : 48,
      height: isElevated ? 56 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: isElevated ? 20 : 10, offset: const Offset(0, 8))],
      ),
      child: Center(child: Icon(icon, color: color, size: isElevated ? 32 : 28)),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // YOLCULUĞA BAŞLA
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, anim, secAnim) => const LevelMapPage(),
                  transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 32),
                  SizedBox(width: 12),
                  Text("Yolculuğa Başla", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // MAĞAZA VE ÇARK YANYANA
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShopPage())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_rounded, size: 24, color: Color(0xFFFFD54F)),
                        SizedBox(width: 8),
                        Text("Mağaza", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DailySpinPage())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66BB6A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Icon(Icons.casino_rounded, size: 28),
                        ),
                      ),
                      // BEDAVA ÇARK UYARISI (Kırmızı Nokta)
                      if (provider.canSpinFree)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SKORLAR VE AYARLAR
          Row(
            children: [
              Expanded(child: _buildSecondaryButton(Icons.leaderboard_rounded, "Skorlar", () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ScoresPage())))),
              const SizedBox(width: 16),
              Expanded(child: _buildSecondaryButton(Icons.settings_rounded, "Ayarlar", () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage())))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}