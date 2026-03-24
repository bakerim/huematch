import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/providers/game_provider.dart';
import '../../data/services/ad_manager.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = Theme.of(context);

    // 🔥 DİL KONTROLÜ: Telefon Türkçeyse true, değilse false
    final bool isTr = context.locale.languageCode == 'tr';

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
          "store".tr().toUpperCase(),
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
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
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "current_balance_label".tr().toUpperCase(),
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
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFFFD54F),
                          size: 40,
                        ),
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

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: InkWell(
                onTap: () {
                  AdManager.showRewardedAd(
                    context: context,
                    onRewardEarned: () {
                      provider.addBonusCoins(10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("congrats_earned_coins".tr()),
                          backgroundColor: const Color(0xFF66BB6A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF673AB7).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Color(0xFF673AB7),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "watch_video_earn_coins".tr(),
                        style: const TextStyle(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildPiggyBankCard(context, provider, theme, isTr),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "in_game_items".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildHintPackage(
                            context,
                            provider,
                            theme,
                            "three_hints".tr(),
                            3,
                            50,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildHintPackage(
                            context,
                            provider,
                            theme,
                            "ten_hints".tr(),
                            10,
                            120,
                            isPopular: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "buy_coins".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height:
                        165, // 🔥 Butonlar büyüdüğü için yüksekliği artırdık
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        // 🔥 DİNAMİK FİYAT VE SAHTE İNDİRİM SİSTEMİ
                        _buildCoinPackage(
                          context,
                          provider,
                          theme,
                          "starter_pack".tr(),
                          500,
                          isTr ? "₺29.99" : "\$0.99",
                          oldPriceStr: isTr ? "₺59.99" : "\$1.99",
                        ),
                        _buildCoinPackage(
                          context,
                          provider,
                          theme,
                          "pro_pack".tr(),
                          1500,
                          isTr ? "₺79.99" : "\$2.99",
                          oldPriceStr: isTr ? "₺159.99" : "\$5.99",
                          isPopular: true,
                        ),
                        _buildCoinPackage(
                          context,
                          provider,
                          theme,
                          "tycoon_pack".tr(),
                          5000,
                          isTr ? "₺199.99" : "\$7.99",
                          oldPriceStr: isTr ? "₺399.99" : "\$15.99",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "card_themes".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
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
                          theme: theme,
                          title: "classic_white".tr(),
                          description: "classic_desc".tr(),
                          themeId: 'classic',
                          price: 0,
                          icon: Icons.check_circle_rounded,
                          iconColor: const Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          theme: theme,
                          title: "dark_matter".tr(),
                          description: "dark_matter_desc".tr(),
                          themeId: 'dark_matter',
                          price: 500,
                          icon: Icons.nightlight_round,
                          iconColor: const Color(0xFF00E5FF),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          theme: theme,
                          title: "holographic_neon".tr(),
                          description: "neon_desc".tr(),
                          themeId: 'neon',
                          price: 1500,
                          icon: Icons.terminal_rounded,
                          iconColor: const Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 16),
                        _buildShopItem(
                          context: context,
                          provider: provider,
                          theme: theme,
                          title: "royal_gold".tr(),
                          description: "gold_desc".tr(),
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

  Widget _buildPiggyBankCard(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
    bool isTr, // 🔥 Dil bilgisini buraya aldık
  ) {
    double fillPercentage =
        provider.piggyBankCoins / provider.maxPiggyBankCoins;

    // 🔥 KUMBARA DİNAMİK FİYATI
    String piggyPrice = isTr ? "₺19.99" : "\$0.99";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Color(0xFFFFD54F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "piggy_bank".tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                    Text(
                      "piggy_bank_desc".tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "savings".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                "${provider.piggyBankCoins} / ${provider.maxPiggyBankCoins}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD54F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: fillPercentage,
              minHeight: 12,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD54F),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: provider.piggyBankCoins > 0
                  ? () {
                      provider.smashPiggyBank();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("piggy_bank_smashed".tr()),
                          backgroundColor: const Color(0xFF66BB6A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                provider.isPiggyBankFull
                    ? "smash_piggy_bank".tr(
                        args: [piggyPrice],
                      ) // 🔥 Fiyat Dinamik
                    : "buy_now".tr(args: [piggyPrice]), // 🔥 Fiyat Dinamik
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintPackage(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
    String title,
    int hintAmount,
    int priceCoin, {
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: theme.colorScheme.secondary, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_rounded,
            color: isPopular
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (provider.totalCoins >= priceCoin) {
                  provider.buyCoinPackage(-priceCoin);
                  provider.addHints(hintAmount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("hints_added".tr()),
                      backgroundColor: const Color(0xFF66BB6A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("insufficient_coins".tr()),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                foregroundColor: theme.colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$priceCoin",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.monetization_on_rounded,
                    size: 14,
                    color: Color(0xFFFFD54F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
    String title,
    int amount,
    String priceStr, {
    required String
    oldPriceStr, // 🔥 SAHTE İNDİRİM İÇİN ESKİ FİYAT PARAMETRESİ EKLENDİ
    bool isPopular = false,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: const Color(0xFFFFD54F), width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFFFD54F),
                      size: 16,
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48, // 🔥 Eski fiyatı sığdırmak için butonu uzattık
                  child: ElevatedButton(
                    onPressed: () {
                      provider.buyCoinPackage(amount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "purchase_success_coins_added".tr(
                              namedArgs: {"amount": amount.toString()},
                            ),
                          ),
                          backgroundColor: const Color(0xFF66BB6A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔥 ÜSTÜ ÇİZİLİ ESKİ FİYAT ILLÜZYONU
                        Text(
                          oldPriceStr,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2.0,
                            color: theme.scaffoldBackgroundColor.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // 🔥 YENİ CAZİP FİYAT
                        Text(
                          priceStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  "most_popular".tr().toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
    required ThemeData theme,
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isEquipped
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
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
          _buildActionButton(
            context,
            provider,
            theme,
            themeId,
            price,
            isOwned,
            isEquipped,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    GameProvider provider,
    ThemeData theme,
    String themeId,
    int price,
    bool isOwned,
    bool isEquipped,
  ) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "equipped".tr(),
          style: TextStyle(
            color: theme.scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
    if (isOwned) {
      return OutlinedButton(
        onPressed: () {
          provider.equipTheme(themeId);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "select".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () {
        bool success = provider.buyTheme(themeId, price);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "theme_unlocked".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF66BB6A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "insufficient_coins_buy_above".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
            ),
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
          Text(
            "$price",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.monetization_on_rounded, size: 16),
        ],
      ),
    );
  }
}
