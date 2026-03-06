import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOS tarzı switch için
import 'package:provider/provider.dart';
import '../../data/providers/game_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          "AYARLAR",
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OYUN DENEYİMİ KARTI
              const Text(
                "Oyun Deneyimi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.vibration_rounded,
                      iconColor: const Color(0xFFFFA726),
                      title: "Titreşim (Haptic)",
                      value: provider.isVibrationEnabled,
                      onChanged: (val) => provider.toggleVibration(),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                    _buildSwitchTile(
                      icon: Icons.music_note_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      title: "Ses Efektleri (SFX)",
                      value: provider.isSoundEnabled,
                      onChanged: (val) => provider.toggleSound(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // DESTEK VE HAKKINDA KARTI
              const Text(
                "Destek & Hakkında",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.star_rate_rounded,
                      iconColor: const Color(0xFFFFD54F),
                      title: "Bizi Değerlendir",
                      onTap: () {
                        // TODO: Mağaza linki eklenecek
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                    _buildActionTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: const Color(0xFF66BB6A),
                      title: "Gizlilik Politikası",
                      onTap: () {
                        // TODO: Gizlilik politikası linki eklenecek
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Geliştirici İmzası
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/image/moving_pixel.png',
                      width: 60,
                      errorBuilder: (_, __, ___) => const Icon(Icons.gamepad_rounded, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Moving Pixel Studios",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // IOS Tarzı Aç/Kapat (Toggle) Widget'ı
  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.black87,
          ),
        ],
      ),
    );
  }

  // Tıklanabilir Liste Elemanı Widget'ı
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}