import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart'; 

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

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
          "MAĞAZA",
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
        child: Column(
          children: [
            // --- CÜZDAN / BAKİYE KARTI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B2D42), Color(0xFF14151F)], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "MEVCUT BAKİYE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 40),
                        const SizedBox(width: 12),
                        Text(
                          "${provider.totalCoins}",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- VİDEO İZLE +10 ALTIN KAZAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // BURASI DÜZELDİ: context parametresi eklendi
                  AdManager.showRewardedAd(
                    context: context,
                    onRewardEarned: () {
                      provider.addBonusCoins(10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Tebrikler! +10 Altın kazandın.", style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF66BB6A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    onClosed: () {},
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.5), width: 2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: Color(0xFF673AB7), size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Video İzle: +10 Altın",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  
                  // --- 1. REYON: GERÇEK PARAYLA ALTIN SATIN AL (IAP) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Altın Satın Al",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150, 
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildCoinPackage(context, provider, "Başlangıç", 500, "₺29.99"),
                        _buildCoinPackage(context, provider, "Profesyonel", 1500, "₺79.99", isPopular: true),
                        _buildCoinPackage(context, provider, "Tycoon Paketi", 5000, "₺199.99"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  const SizedBox(height: 24),

                  // --- 2. REYON: KART TEMALARI (SKINS) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Text(
                          "Kart Temaları",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Koleksiyon",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          title: "Klasik Beyaz",
                          description: "Standart, temiz ve sade.",
                          themeId: 'classic',
                          price: 0,
                          icon: Icons.check_circle_rounded,
                          iconColor: const Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          title: "Karanlık Madde",
                          description: "Göz yormayan antrasit gece modu.",
                          themeId: 'dark',
                          price: 500,
                          icon: Icons.nightlight_round,
                          iconColor: const Color(0xFF42A5F5),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          title: "Holografik Neon",
                          description: "Matris esintili karanlık zemin.",
                          themeId: 'neon',
                          price: 1500,
                          icon: Icons.terminal_rounded,
                          iconColor: const Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          title: "Royal Gold",
                          description: "Mat siyah ve altın yaldız.",
                          themeId: 'gold',
                          price: 5000,
                          icon: Icons.diamond_rounded,
                          iconColor: const Color(0xFFFFD54F),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackage(BuildContext context, GameProvider provider, String title, int amount, String priceStr, {bool isPopular = false}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPopular ? Border.all(color: const Color(0xFFFFD54F), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$amount",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 16),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.buyCoinPackage(amount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Satın alım başarılı! +$amount Altın eklendi.", style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF66BB6A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(priceStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD54F),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: const Text(
                  "EN POPÜLER",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required GameProvider provider,
    required String title,
    required String description,
    required String themeId,
    required int price,
    required IconData icon,
    required Color iconColor,
  }) {
    bool isOwned = provider.ownedThemes.contains(themeId);
    bool isEquipped = provider.currentTheme == themeId;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isEquipped ? Border.all(color: Colors.black87, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          _buildActionButton(context, provider, themeId, price, isOwned, isEquipped),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, GameProvider provider, String themeId, int price, bool isOwned, bool isEquipped) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("Kuşanıldı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    }

    if (isOwned) {
      return OutlinedButton(
        onPressed: () { provider.equipTheme(themeId); }, 
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.black87, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Seç", style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return ElevatedButton(
      onPressed: () {
        bool success = provider.buyTheme(themeId, price);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Tema açıldı!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF66BB6A), behavior: SnackBarBehavior.floating),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Yetersiz altın! Yukarıdan satın alabilirsin.", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFFEF5350), behavior: SnackBarBehavior.floating),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD54F), 
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$price", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.monetization_on_rounded, size: 16),
        ],
      ),
    );
  }
}