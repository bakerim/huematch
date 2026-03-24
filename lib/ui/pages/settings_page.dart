import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/providers/game_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          onPressed: () {
            provider.playButtonClickSound();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "settings".tr(),
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
                "game_experience".tr(),
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
                    _buildSwitchTile(
                      theme: theme,
                      icon: Icons.vibration_rounded,
                      iconColor: const Color(0xFFFFA726),
                      title: "vibration".tr(),
                      value: provider.isVibrationEnabled,
                      onChanged: (val) {
                        provider.playButtonClickSound();
                        provider.toggleVibration();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      indent: 60,
                    ),
                    _buildSwitchTile(
                      theme: theme,
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      title: "sfx".tr(),
                      value: provider.isSfxEnabled,
                      onChanged: (val) {
                        provider.playButtonClickSound();
                        provider.toggleSfx();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      indent: 60,
                    ),
                    _buildSwitchTile(
                      theme: theme,
                      icon: Icons.music_note_rounded,
                      iconColor: const Color(0xFFEC407A),
                      title: "bgm".tr(),
                      value: provider.isMusicEnabled,
                      onChanged: (val) {
                        provider.playButtonClickSound();
                        provider.toggleMusic();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 🔥 YENİ: DİL SEÇİM ALANI
              Text(
                "language".tr(),
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
                    _buildLanguageTile(
                      context: context,
                      theme: theme,
                      title: "turkish".tr(),
                      locale: const Locale('tr'),
                      isSelected: context.locale == const Locale('tr'),
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      indent: 60,
                    ),
                    _buildLanguageTile(
                      context: context,
                      theme: theme,
                      title: "english".tr(),
                      locale: const Locale('en'),
                      isSelected: context.locale == const Locale('en'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "support_about".tr(),
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
                      title: "rate_us".tr(),
                      onTap: () {
                        provider.playButtonClickSound();
                        // TODO: Mağaza linki
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
                      title: "privacy_policy".tr(),
                      onTap: () {
                        provider.playButtonClickSound();
                        _launchPrivacyPolicy();
                      },
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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

  Widget _buildLanguageTile({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<GameProvider>().playButtonClickSound();
        context.setLocale(locale);
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSelected ? theme.colorScheme.primary : Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.language_rounded, 
                color: isSelected ? theme.colorScheme.primary : Colors.grey, 
                size: 24
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 24),
          ],
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