import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/game_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // --- GİZLİLİK POLİTİKASI LİNKİNİ AÇMA FONKSİYONU ---
  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://bilbuz.com/huematch-privacy-policy/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Link açılamadı: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = Theme.of(context);

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
          "AYARLAR",
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Oyun Deneyimi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  // YENİ STANDART: withOpacity yerine withValues(alpha: ...)
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      theme: theme,
                      icon: Icons.vibration_rounded,
                      iconColor: const Color(0xFFFFA726),
                      title: "Titreşim (Haptic)",
                      value: provider.isVibrationEnabled,
                      onChanged: (val) => provider.toggleVibration(),
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      indent: 60,
                    ),
                    _buildSwitchTile(
                      theme: theme,
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

              Text(
                "Destek & Hakkında",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      theme: theme,
                      icon: Icons.star_rate_rounded,
                      iconColor: const Color(0xFFFFD54F),
                      title: "Bizi Değerlendir",
                      onTap: () {
                        // TODO: Uygulama mağazaya yüklenince buraya Store linki eklenecek
                      },
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      indent: 60,
                    ),
                    _buildActionTile(
                      theme: theme,
                      icon: Icons.privacy_tip_rounded,
                      iconColor: const Color(0xFF66BB6A),
                      title: "Gizlilik Politikası",
                      onTap: _launchPrivacyPolicy,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Opacity(
                      opacity: theme.brightness == Brightness.dark ? 0.6 : 1.0,
                      child: Image.asset(
                        'assets/image/moving_pixel.png',
                        width: 60,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.gamepad_rounded,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Moving Pixel Studios",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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

  Widget _buildSwitchTile({
    required ThemeData theme,
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
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required ThemeData theme,
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
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
