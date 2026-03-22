import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:audioplayers/audioplayers.dart'; // 🔥 Ses kütüphanesi

import '../models/card_model.dart';
import '../services/notification_service.dart';

class GameProvider extends ChangeNotifier {
  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  bool _isLocked = true;
  bool get isLocked => _isLocked;

  final List<int> _currentFlippedCards = [];
  int _matchesFound = 0;

  Timer? _gameTimer;
  Timer? _delayedGameOverTimer;
  Timer? _memorizeTimer;

  int _timeLeft = 0;
  int get timeLeft => _timeLeft;

  bool _isTimeUp = false;
  bool get isTimeUp => _isTimeUp;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  int _totalScore = 0;
  int get totalScore => _totalScore;

  int _lastLevelScore = 0;
  int get lastLevelScore => _lastLevelScore;

  int _totalCoins = 0;
  int get totalCoins => _totalCoins;

  int _piggyBankCoins = 0;
  int get piggyBankCoins => _piggyBankCoins;
  final int maxPiggyBankCoins = 500;
  bool get isPiggyBankFull => _piggyBankCoins >= maxPiggyBankCoins;

  int _highScore = 0;
  int get highScore => _highScore;

  int _highestLevel = 1;
  int get highestLevel => _highestLevel;

  bool _isVibrationEnabled = true;
  bool get isVibrationEnabled => _isVibrationEnabled;

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  List<String> _ownedThemes = ['classic'];
  List<String> get ownedThemes => _ownedThemes;

  String _currentTheme = 'classic';
  String get currentTheme => _currentTheme;

  int _lastEarnedCoins = 0;
  int get lastEarnedCoins => _lastEarnedCoins;

  bool _isDoubleCoinClaimed = false;
  bool get isDoubleCoinClaimed => _isDoubleCoinClaimed;

  int _gamesPlayed = 0;
  bool get shouldShowInterstitial => _gamesPlayed > 0 && _gamesPlayed % 3 == 0;

  String _lastFreeSpinDate = "";

  bool get canSpinFree {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lastFreeSpinDate != today;
  }

  Map<String, int> _levelStars = {};

  int _hintCount = 1;
  int get hintCount => _hintCount;

  List<int> _hintedCardIndices = [];
  List<int> get hintedCardIndices => _hintedCardIndices;

  List<int> _nearMissIndices = [];
  List<int> get nearMissIndices => _nearMissIndices;

  // ==========================================================
  // 🔥 SES MOTORU VE OYNATICILAR (Senin belirlediğin isimlerle)
  // ==========================================================
  final AudioPlayer _sfxFlipPlayer = AudioPlayer();
  final AudioPlayer _sfxCorrectPlayer = AudioPlayer();
  final AudioPlayer _sfxIncorrectPlayer = AudioPlayer();
  final AudioPlayer _sfxGainPlayer = AudioPlayer();
  final AudioPlayer _sfxLosePlayer = AudioPlayer();
  final AudioPlayer _sfxPanicPlayer = AudioPlayer();
  final AudioPlayer _sfxButtonPlayer = AudioPlayer(); // UI Butonları için!
  final AudioPlayer _bgmPlayer = AudioPlayer();

  void _playSfx(AudioPlayer player, String path) {
    if (_isSoundEnabled) {
      player.play(AssetSource('sounds/$path'));
    }
  }

  // UI sayfalarından kolayca çağırabilmen için özel buton sesi metodu:
  // Kullanımı: context.read<GameProvider>().playButtonClickSound();
  void playButtonClickSound() {
    _playSfx(_sfxButtonPlayer, 'button_click.mp3');
  }

  void _startBgm() {
    if (_isSoundEnabled) {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer.setVolume(0.3); // Arka plan müziği kısık sesle çalsın
      _bgmPlayer.play(AssetSource('sounds/ambient_bg.mp3'));
    } else {
      _bgmPlayer.stop();
    }
  }
  // ==========================================================

  int getStarsForLevel(int level) {
    return _levelStars[level.toString()] ?? 0;
  }

  int get memorizeTimeMilliseconds {
    if (_currentLevel <= 15) return 3000;
    if (_currentLevel <= 50) {
      return max(2000, 3000 - ((_currentLevel - 15) * 20));
    }
    if (_currentLevel <= 150) {
      return max(1500, 2500 - ((_currentLevel - 50) * 10));
    }
    if (_currentLevel <= 300) {
      return max(1000, 1500 - ((_currentLevel - 150) * 5));
    }
    return 800;
  }

  int get totalLevelTime {
    if (_currentLevel <= 15) return 60;
    if (_currentLevel <= 50) return max(45, 60 - ((_currentLevel - 15) ~/ 2));
    if (_currentLevel <= 150) return max(35, 45 - ((_currentLevel - 50) ~/ 5));
    return 30;
  }

  GameProvider() {
    _loadSavedData();
    _startBgm(); // Oyun açılır açılmaz müzik pusuya yatar
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    _highestLevel = prefs.getInt('highestLevel') ?? 1;
    _totalCoins = prefs.getInt('totalCoins') ?? 0;
    _piggyBankCoins = prefs.getInt('piggyBankCoins') ?? 0;
    _hintCount = prefs.getInt('hintCount') ?? 1;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true;
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    _ownedThemes = prefs.getStringList('ownedThemes') ?? ['classic'];
    _currentTheme = prefs.getString('currentTheme') ?? 'classic';
    _lastFreeSpinDate = prefs.getString('lastFreeSpinDate') ?? "";

    final starsString = prefs.getString('levelStars');
    if (starsString != null) {
      _levelStars = Map<String, int>.from(json.decode(starsString));
    }

    NotificationService().scheduleRetentionNotification();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_totalScore > _highScore) {
      _highScore = _totalScore;
      await prefs.setInt('highScore', _highScore);
    }
    if (_currentLevel >= _highestLevel && !_isTimeUp) {
      _highestLevel = _currentLevel + 1;
      await prefs.setInt('highestLevel', _highestLevel);
    }

    await prefs.setInt('totalCoins', _totalCoins);
    await prefs.setInt('piggyBankCoins', _piggyBankCoins);
    await prefs.setInt('hintCount', _hintCount);
    await prefs.setStringList('ownedThemes', _ownedThemes);
    await prefs.setString('currentTheme', _currentTheme);
    await prefs.setString('lastFreeSpinDate', _lastFreeSpinDate);
    await prefs.setString('levelStars', json.encode(_levelStars));
  }

  void startGame() {
    _gameTimer?.cancel();
    _delayedGameOverTimer?.cancel();
    _memorizeTimer?.cancel();
    _sfxPanicPlayer.stop(); // Panik sesini sustur!

    _cards.clear();
    _currentFlippedCards.clear();
    _hintedCardIndices.clear();
    _nearMissIndices.clear();
    _matchesFound = 0;
    _isGameOver = false;
    _isTimeUp = false;
    _timeLeft = totalLevelTime;
    _isLocked = true;

    _generateCards();
    notifyListeners();

    _memorizeTimer = Timer(
      Duration(milliseconds: memorizeTimeMilliseconds),
      () {
        for (var card in _cards) {
          card.isFlipped = false;
        }
        _isLocked = false;
        _startCountdown();
        notifyListeners();
      },
    );
  }

  void _startCountdown() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;

        if (_timeLeft <= 10 && _timeLeft > 0) {
          if (_isVibrationEnabled) HapticFeedback.selectionClick();
          // 🔥 YENİ: Süre azaldığında 'time_left' sesini çal
          _playSfx(_sfxPanicPlayer, 'time_left.mp3');
        }

        notifyListeners();
      } else {
        _gameTimer?.cancel();
        _isLocked = true;
        _sfxPanicPlayer.stop(); // Süre bitince panik sesini sustur

        int firstMiss = _cards.indexWhere((c) => !c.isMatched);
        if (firstMiss != -1) {
          int secondMiss = _cards.indexWhere(
            (c) =>
                !c.isMatched &&
                c.id != _cards[firstMiss].id &&
                c.color == _cards[firstMiss].color &&
                c.icon == _cards[firstMiss].icon,
          );
          if (secondMiss != -1) {
            _cards[firstMiss].isFlipped = true;
            _cards[secondMiss].isFlipped = true;
            _nearMissIndices = [firstMiss, secondMiss];
            if (_isVibrationEnabled) HapticFeedback.heavyImpact();
          }
        }
        notifyListeners();

        _delayedGameOverTimer = Timer(const Duration(milliseconds: 1500), () {
          _isTimeUp = true;
          _gameOver(failed: true);
        });
      }
    });
  }

  void useHint(VoidCallback onShowAd) {
    if (_isLocked || _isGameOver || _isTimeUp) return;

    if (_hintCount > 0) {
      _hintCount--;
      _saveData();

      int firstIndex = _cards.indexWhere((c) => !c.isMatched && !c.isFlipped);
      if (firstIndex != -1) {
        int secondIndex = _cards.indexWhere(
          (c) =>
              !c.isMatched &&
              c.id != _cards[firstIndex].id &&
              c.color == _cards[firstIndex].color &&
              c.icon == _cards[firstIndex].icon,
        );

        if (secondIndex != -1) {
          if (_isVibrationEnabled) HapticFeedback.mediumImpact();
          // İpucu kullanılınca kartlar açılırken ses çal
          _playSfx(_sfxFlipPlayer, 'card_flip.mp3');

          _cards[firstIndex].isFlipped = true;
          _cards[secondIndex].isFlipped = true;
          _hintedCardIndices = [firstIndex, secondIndex];
          _isLocked = true;
          notifyListeners();

          Timer(const Duration(milliseconds: 2000), () {
            if (!_cards[firstIndex].isMatched) {
              _cards[firstIndex].isFlipped = false;
            }
            if (!_cards[secondIndex].isMatched) {
              _cards[secondIndex].isFlipped = false;
            }
            _hintedCardIndices.clear();
            _isLocked = false;
            notifyListeners();
          });
        }
      }
    } else {
      onShowAd();
    }
  }

  void addHints(int amount) {
    _hintCount += amount;
    _saveData();
    notifyListeners();
  }

  void addExtraTime(int seconds) {
    _timeLeft += seconds;
    _isTimeUp = false;
    _isGameOver = false;
    _isLocked = false;

    for (int index in _nearMissIndices) {
      if (!_cards[index].isMatched) {
        _cards[index].isFlipped = false;
      }
    }
    _nearMissIndices.clear();

    _startCountdown();
    notifyListeners();
  }

  void playSpecificLevel(int level) {
    _currentLevel = level;
    startGame();
  }

  void restartGame() {
    startGame();
  }

  void nextLevel() {
    _currentLevel++;
    startGame();
  }

  void _generateCards() {
    int idCounter = 0;
    List<CardModel> tempCards = [];
    List<Map<String, dynamic>> pool = [];
    int uniqueVariety = 4;

    final Color cYellow = const Color(0xFFFFD54F);
    final Color cBlue = const Color(0xFF42A5F5);
    final Color cGreen = const Color(0xFF66BB6A);
    final Color cRed = const Color(0xFFEF5350);
    final Color cPurple = const Color(0xFFAB47BC);
    final Color cOrange = const Color(0xFFFF9800);
    final Color cPink = const Color(0xFFEC407A);
    final Color cCyan = const Color(0xFF26C6DA);
    final Color cLime = const Color(0xFFD4E157);
    final Color cDarkBlue = const Color(0xFF1565C0);

    final IconData iSquare = Icons.square_rounded;
    final IconData iCircle = Icons.circle;
    final IconData iTriangle = Icons.change_history_rounded;
    final IconData iHexagon = Icons.hexagon_rounded;
    final IconData iStar = Icons.star_rounded;
    final IconData iDiamond = Icons.diamond_rounded;
    final IconData iShield = Icons.shield_rounded;
    final IconData iHeart = Icons.favorite_rounded;
    final IconData iPentagon = Icons.pentagon_rounded;
    final IconData iHollowCircle = Icons.radio_button_unchecked_rounded;

    if (_currentLevel <= 15) {
      pool = [
        {'color': cYellow, 'icon': iSquare},
        {'color': cBlue, 'icon': iCircle},
        {'color': cGreen, 'icon': iTriangle},
        {'color': cRed, 'icon': iHexagon},
      ];
      uniqueVariety = 4;
    } else if (_currentLevel <= 50) {
      uniqueVariety = 5 + ((_currentLevel - 16) ~/ 10);
      pool = _createRandomPool(
        [cYellow, cBlue, cGreen, cRed],
        [iSquare, iCircle, iTriangle, iHexagon],
        uniqueVariety,
      );
    } else if (_currentLevel <= 150) {
      uniqueVariety = 7 + ((_currentLevel - 51) ~/ 25);
      pool = _createRandomPool(
        [cYellow, cBlue, cGreen, cRed, cPurple, cOrange, cPink],
        [
          iSquare,
          iCircle,
          iTriangle,
          iHexagon,
          iStar,
          iDiamond,
          iShield,
          iHeart,
        ],
        uniqueVariety,
      );
    } else if (_currentLevel <= 300) {
      uniqueVariety = 10;
      pool = _createRandomPool(
        [
          cYellow,
          cBlue,
          cGreen,
          cRed,
          cPurple,
          cOrange,
          cPink,
          cCyan,
          cLime,
          cDarkBlue,
        ],
        [
          iSquare,
          iCircle,
          iTriangle,
          iHexagon,
          iStar,
          iDiamond,
          iShield,
          iHeart,
          iPentagon,
          iHollowCircle,
        ],
        uniqueVariety,
      );
    } else {
      uniqueVariety = 10;
      pool = _createRandomPool(
        [
          cYellow,
          cBlue,
          cGreen,
          cRed,
          cPurple,
          cOrange,
          cPink,
          cCyan,
          cLime,
          cDarkBlue,
          Colors.teal,
          Colors.brown,
        ],
        [
          iSquare,
          iCircle,
          iTriangle,
          iHexagon,
          iStar,
          iDiamond,
          iShield,
          iHeart,
          iPentagon,
          iHollowCircle,
          Icons.cloud_rounded,
          Icons.anchor_rounded,
        ],
        uniqueVariety,
      );
    }

    List<Map<String, dynamic>> finalPairsToCreate = [];
    for (int i = 0; i < 10; i++) {
      finalPairsToCreate.add(pool[i % uniqueVariety]);
    }

    for (var combo in finalPairsToCreate) {
      tempCards.add(
        CardModel(
          id: idCounter++,
          color: combo['color'],
          icon: combo['icon'],
          isFlipped: true,
        ),
      );
      tempCards.add(
        CardModel(
          id: idCounter++,
          color: combo['color'],
          icon: combo['icon'],
          isFlipped: true,
        ),
      );
    }
    tempCards.shuffle(Random());
    _cards = tempCards;
  }

  List<Map<String, dynamic>> _createRandomPool(
    List<Color> colors,
    List<IconData> icons,
    int count,
  ) {
    List<Map<String, dynamic>> result = [];
    Random random = Random();
    while (result.length < count) {
      Color c = colors[random.nextInt(colors.length)];
      IconData ic = icons[random.nextInt(icons.length)];
      if (!result.any((cmb) => cmb['color'] == c && cmb['icon'] == ic)) {
        result.add({'color': c, 'icon': ic});
      }
    }
    return result;
  }

  void onCardTapped(int index) {
    if (_isLocked ||
        _isGameOver ||
        _isTimeUp ||
        _cards[index].isFlipped ||
        _cards[index].isMatched) {
      return;
    }

    if (_isVibrationEnabled) HapticFeedback.lightImpact();

    // 🔥 YENİ: Kart çevirme sesi
    _playSfx(_sfxFlipPlayer, 'card_flip.mp3');

    _cards[index].isFlipped = true;
    _currentFlippedCards.add(index);
    notifyListeners();

    if (_currentFlippedCards.length == 2) {
      int first = _currentFlippedCards[0];
      int second = _currentFlippedCards[1];
      _currentFlippedCards.clear();
      _checkForMatch(first, second);
    }
  }

  Future<void> _checkForMatch(int firstIndex, int secondIndex) async {
    bool isMatch =
        (_cards[firstIndex].color == _cards[secondIndex].color) &&
        (_cards[firstIndex].icon == _cards[secondIndex].icon);

    if (isMatch) {
      if (_isVibrationEnabled) HapticFeedback.mediumImpact();
      // 🔥 YENİ: Doğru Eşleşme
      _playSfx(_sfxCorrectPlayer, 'correct_match.mp3');

      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _matchesFound++;

      if (_matchesFound == 10) {
        _gameOver(failed: false);
      }
      notifyListeners();
    } else {
      if (_isVibrationEnabled) HapticFeedback.vibrate();
      // 🔥 YENİ: Hatalı Eşleşme
      _playSfx(_sfxIncorrectPlayer, 'incorrect_match.mp3');

      await Future.delayed(const Duration(milliseconds: 1000));
      _cards[firstIndex].isFlipped = false;
      _cards[secondIndex].isFlipped = false;
      notifyListeners();
    }
  }

  void _gameOver({required bool failed}) {
    _isGameOver = true;
    _gameTimer?.cancel();
    _sfxPanicPlayer.stop(); // Panik sesini durdur

    _gamesPlayed++;
    _isDoubleCoinClaimed = false;

    if (failed) {
      _lastLevelScore = 0;
      _lastEarnedCoins = 0;
      // 🔥 YENİ: Süre Bitti (Kaybettin)
      _playSfx(_sfxLosePlayer, 'level_lose.mp3');
    } else {
      _lastLevelScore = calculateScore();
      _totalScore += _lastLevelScore;

      // 🔥 YENİ: Seviye Tamamlandı
      _playSfx(_sfxGainPlayer, 'level_win.mp3');

      int stars = calculateStars();
      int previousStars = _levelStars[_currentLevel.toString()] ?? 0;
      if (stars > previousStars) {
        _levelStars[_currentLevel.toString()] = stars;
      }

      if (stars == 3) {
        _lastEarnedCoins = 2;
      } else if (stars == 2) {
        _lastEarnedCoins = 1;
      } else {
        _lastEarnedCoins = 0;
      }

      _totalCoins += _lastEarnedCoins;

      // Eğer altın kazandıysa, win sesinden hemen sonra coin sesi çok gürültü yapabilir.
      // Win sesi zaten yeterliyse burayı kapatabilirsin ama şimdilik "şıngırtı" efekti olarak duruyor.
      if (_lastEarnedCoins > 0) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
        });
      }

      if (_piggyBankCoins < maxPiggyBankCoins) {
        _piggyBankCoins = min(maxPiggyBankCoins, _piggyBankCoins + 10);
      }

      if ((_currentLevel == 5 || _currentLevel == 15 || _currentLevel == 30) &&
          stars == 3) {
        _triggerSmartReview();
      }
    }

    _saveData();
    notifyListeners();
  }

  void smashPiggyBank() {
    if (_piggyBankCoins > 0) {
      _totalCoins += _piggyBankCoins;
      _piggyBankCoins = 0;
      // 🔥 YENİ: Altın kazanma efekti
      _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
      _saveData();
      notifyListeners();
    }
  }

  Future<void> _triggerSmartReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await Future.delayed(const Duration(milliseconds: 1000));
        inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint("Yıldız avı sırasında pürüz: $e");
    }
  }

  void applySpinReward(int reward, bool isFreeSpin) {
    if (reward > 0) {
      _totalCoins += reward;
      _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
    }
    if (isFreeSpin) {
      _lastFreeSpinDate = DateTime.now().toIso8601String().split('T')[0];
      NotificationService().scheduleDailySpinNotification();
    }
    _saveData();
    notifyListeners();
  }

  bool buyTheme(String themeId, int price) {
    if (_totalCoins >= price && !_ownedThemes.contains(themeId)) {
      _totalCoins -= price;
      _ownedThemes.add(themeId);
      _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  void equipTheme(String themeId) {
    if (_ownedThemes.contains(themeId)) {
      _currentTheme = themeId;
      _saveData();
      notifyListeners();
    }
  }

  void buyCoinPackage(int amount) {
    _totalCoins += amount;
    _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
    _saveData();
    notifyListeners();
  }

  void toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    notifyListeners();
  }

  void toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnabled', _isSoundEnabled);

    if (_isSoundEnabled) {
      _startBgm();
    } else {
      _bgmPlayer.stop();
    }

    notifyListeners();
  }

  void claimDoubleCoins() {
    if (!_isDoubleCoinClaimed && _lastEarnedCoins > 0) {
      _totalCoins += _lastEarnedCoins;
      _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
      _isDoubleCoinClaimed = true;
      _saveData();
      notifyListeners();
    }
  }

  void addBonusCoins(int amount) {
    _totalCoins += amount;
    _playSfx(_sfxGainPlayer, 'coin_gain.mp3');
    _saveData();
    notifyListeners();
  }

  int calculateScore() {
    return 5000 + (_timeLeft * 100);
  }

  int calculateStars() {
    double timeRatio = _timeLeft / totalLevelTime;
    if (timeRatio >= 0.5) return 3;
    if (timeRatio >= 0.2) return 2;
    return 1;
  }

  void pauseGame() {
    _gameTimer?.cancel();
    _sfxPanicPlayer.stop();
    _bgmPlayer.pause();
    notifyListeners();
  }

  void resumeGame() {
    if (!_isGameOver && !_isLocked && !_isTimeUp) {
      _startCountdown();
      _bgmPlayer.resume();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _delayedGameOverTimer?.cancel();
    _memorizeTimer?.cancel();

    // RAM Dostu Temizlik!
    _sfxFlipPlayer.dispose();
    _sfxCorrectPlayer.dispose();
    _sfxIncorrectPlayer.dispose();
    _sfxGainPlayer.dispose();
    _sfxLosePlayer.dispose();
    _sfxPanicPlayer.dispose();
    _sfxButtonPlayer.dispose(); // UI Buton Player
    _bgmPlayer.dispose();
    super.dispose();
  }
}
