import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/card_model.dart';
import '../services/notification_service.dart';

class GameProvider extends ChangeNotifier with WidgetsBindingObserver {
  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  bool _isLocked = true;
  bool get isLocked => _isLocked;

  final List<int> _currentFlippedCards = [];
  int _matchesFound = 0;

  Timer? _gameTimer;
  Timer? _delayedGameOverTimer;
  Timer? _memorizeTimer;
  Timer? _mismatchTimer;
  int? _mismatchFirst;
  int? _mismatchSecond;

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

  bool _isSfxEnabled = true;
  bool get isSfxEnabled => _isSfxEnabled;

  bool _isMusicEnabled = true;
  bool get isMusicEnabled => _isMusicEnabled;

  bool _isManuallyPaused = false;

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

  final List<int> _hintedCardIndices = [];
  List<int> get hintedCardIndices => _hintedCardIndices;

  List<int> _nearMissIndices = [];
  List<int> get nearMissIndices => _nearMissIndices;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _sfxPlayers = {};

  int _lastVibrateTime = 0;

  Future<void> _initGlobalAudio() async {
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    );
    await AudioPlayer.global.setAudioContext(audioContext);

    final sounds = [
      'card_flip.mp3',
      'correct_match.mp3',
      'incorrect_match.mp3',
      'button_click.mp3',
      'time_left.mp3',
      'level_win.mp3',
      'level_lose.mp3',
      'coin_gain.mp3',
    ];

    for (String s in sounds) {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource('sounds/$s'));
      _sfxPlayers[s] = player;
    }
  }

  void _playSfx(String path) {
    if (!_isSfxEnabled) return;

    final player = _sfxPlayers[path];
    if (player != null) {
      if (player.state == PlayerState.playing) {
        player.seek(Duration.zero);
      } else {
        player.resume();
      }
    }
  }

  void _safeVibrate(int type) {
    if (!_isVibrationEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastVibrateTime < 80) return;
    _lastVibrateTime = now;

    if (type == 1) {
      HapticFeedback.lightImpact();
    } else if (type == 2) {
      HapticFeedback.mediumImpact();
    } else if (type == 3) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void playButtonClickSound() {
    _playSfx('button_click.mp3');
  }

  void _startBgm() {
    if (_isMusicEnabled) {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer.setVolume(0.3);
      _bgmPlayer.play(AssetSource('sounds/ambient_bg.mp3'));
    } else {
      _bgmPlayer.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _bgmPlayer.pause();

      // Kalkan: Uygulama arka plana düşerse süreyi dondur
      if (!_isManuallyPaused && !_isGameOver && !_isTimeUp && !_isLocked) {
        _gameTimer?.cancel();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isMusicEnabled && !_isManuallyPaused) {
        _bgmPlayer.resume();
      }

      // Kalkan: Geri dönüldüğünde süre kaldığı yerden aksın
      if (!_isManuallyPaused && !_isGameOver && !_isTimeUp && !_isLocked) {
        _startCountdown();
      }
    }
  }

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
    return 60;
  }

  GameProvider() {
    WidgetsBinding.instance.addObserver(this);
    _initAudioAndData();
  }

  Future<void> _initAudioAndData() async {
    await _initGlobalAudio();
    await _loadSavedData();
    _startBgm();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    _highestLevel = prefs.getInt('highestLevel') ?? 1;
    _totalCoins = prefs.getInt('totalCoins') ?? 0;
    _piggyBankCoins = prefs.getInt('piggyBankCoins') ?? 0;
    _hintCount = prefs.getInt('hintCount') ?? 1;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true;
    _isSfxEnabled = prefs.getBool('isSfxEnabled') ?? true;
    _isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
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
    _mismatchTimer?.cancel();

    _mismatchFirst = null;
    _mismatchSecond = null;
    _cards.clear();
    _currentFlippedCards.clear();
    _hintedCardIndices.clear();
    _nearMissIndices.clear();
    _matchesFound = 0;
    _isGameOver = false;
    _isTimeUp = false;
    _timeLeft = totalLevelTime;
    _isLocked = true;
    _isManuallyPaused = false;

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
    // Hayalet Avcısı: Eski sayacı öldürmeden yenisini başlatma
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;

        if (_timeLeft <= 10 && _timeLeft > 0) {
          _safeVibrate(1);
          _playSfx('time_left.mp3');
        }

        notifyListeners();
      } else {
        _gameTimer?.cancel();
        _isLocked = true;
        _closeMismatchCards();

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
            _safeVibrate(3);
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

  void _executeHintLogic() {
    _closeMismatchCards();

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
        _safeVibrate(2);
        _playSfx('correct_match.mp3');

        _cards[firstIndex].isFlipped = true;
        _cards[secondIndex].isFlipped = true;
        _cards[firstIndex].isMatched = true;
        _cards[secondIndex].isMatched = true;
        _matchesFound++;

        notifyListeners();

        if (_matchesFound == 10) {
          _gameOver(failed: false);
        }
      }
    }
  }

  void useHint(VoidCallback onShowAd) {
    if (_isLocked || _isGameOver || _isTimeUp) return;

    if (_hintCount > 0) {
      _hintCount--;
      _saveData();
      _executeHintLogic();
    } else {
      pauseGame();
      onShowAd();
    }
  }

  void onAdHintSuccess() {
    resumeGame();
    _executeHintLogic();
  }

  void onAdHintClosed() {
    if (_isManuallyPaused) {
      resumeGame();
    }
  }

  void addHints(int amount) {
    _hintCount += amount;
    _saveData();
    notifyListeners();
  }

  // =====================================================================
  // 🔥 İŞTE ÇÖZÜM: ELEKTROŞOK PROTOKOLÜ (Tam Diriltme Garantili)
  // =====================================================================
  void addExtraTime(int seconds) {
    // 1. Önce olası bütün eski sayaçları ve tetikleyicileri acımasızca yok ediyoruz!
    _gameTimer?.cancel();
    _delayedGameOverTimer?.cancel();
    _mismatchTimer?.cancel();

    // 2. Hastayı hayata döndürüyoruz!
    _timeLeft += seconds;
    _isTimeUp = false;
    _isGameOver = false;
    _isLocked = false;
    _isManuallyPaused = false; // Sistem pauzda kalmasın

    // Oyun bitti diye istatistiği artırmıştık, hakkı yemesin diye geri alıyoruz
    _gamesPlayed = max(0, _gamesPlayed - 1);

    _closeMismatchCards();

    // Yarım kalan (near miss) animasyon kartlarını çeviriyoruz
    for (int index in _nearMissIndices) {
      if (index >= 0 && index < _cards.length && !_cards[index].isMatched) {
        _cards[index].isFlipped = false;
      }
    }
    _nearMissIndices.clear();

    if (_isMusicEnabled) {
      _bgmPlayer.resume();
    }

    // 3. Altın vuruş: Arayüzün (UI) bu dirilişi anında algılaması için
    // Future.microtask kullanarak kodun UI güncellemesini beklemesini sağlıyoruz.
    Future.microtask(() {
      _startCountdown();
      notifyListeners(); // Bu çağrı o Time's Up ekranını toz eder!
    });
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

    const Color cYellow = Color(0xFFFFD54F);
    const Color cBlue = Color(0xFF42A5F5);
    const Color cGreen = Color(0xFF66BB6A);
    const Color cRed = Color(0xFFEF5350);
    const Color cPurple = Color(0xFFAB47BC);
    const Color cOrange = Color(0xFFFF9800);
    const Color cPink = Color(0xFFEC407A);
    const Color cCyan = Color(0xFF26C6DA);
    const Color cLime = Color(0xFFD4E157);
    const Color cDarkBlue = Color(0xFF1565C0);

    const IconData iSquare = Icons.square_rounded;
    const IconData iCircle = Icons.circle;
    const IconData iTriangle = Icons.change_history_rounded;
    const IconData iHexagon = Icons.hexagon_rounded;
    const IconData iStar = Icons.star_rounded;
    const IconData iDiamond = Icons.diamond_rounded;
    const IconData iShield = Icons.shield_rounded;
    const IconData iHeart = Icons.favorite_rounded;
    const IconData iPentagon = Icons.pentagon_rounded;
    const IconData iHollowCircle = Icons.radio_button_unchecked_rounded;

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

  void _closeMismatchCards() {
    if (_mismatchFirst != null && _mismatchSecond != null) {
      _cards[_mismatchFirst!].isFlipped = false;
      _cards[_mismatchSecond!].isFlipped = false;
      _mismatchFirst = null;
      _mismatchSecond = null;
    }
  }

  void onCardTapped(int index) {
    if (_isLocked ||
        _isGameOver ||
        _isTimeUp ||
        _cards[index].isFlipped ||
        _cards[index].isMatched) {
      return;
    }

    if (_mismatchTimer != null && _mismatchTimer!.isActive) {
      _mismatchTimer!.cancel();
      _closeMismatchCards();
    }

    _safeVibrate(1);
    _playSfx('card_flip.mp3');

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

  void _checkForMatch(int firstIndex, int secondIndex) {
    bool isMatch =
        (_cards[firstIndex].color == _cards[secondIndex].color) &&
        (_cards[firstIndex].icon == _cards[secondIndex].icon);

    if (isMatch) {
      _safeVibrate(2);
      _playSfx('correct_match.mp3');

      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _matchesFound++;

      if (_matchesFound == 10) {
        _gameOver(failed: false);
      }
      notifyListeners();
    } else {
      _safeVibrate(4);
      _playSfx('incorrect_match.mp3');

      _mismatchFirst = firstIndex;
      _mismatchSecond = secondIndex;

      _mismatchTimer = Timer(const Duration(milliseconds: 1000), () {
        _closeMismatchCards();
        notifyListeners();
      });
    }
  }

  void _gameOver({required bool failed}) {
    _isGameOver = true;
    _gameTimer?.cancel();
    _mismatchTimer?.cancel();
    _closeMismatchCards();

    _gamesPlayed++;
    _isDoubleCoinClaimed = false;

    if (failed) {
      _lastLevelScore = 0;
      _lastEarnedCoins = 0;
      _playSfx('level_lose.mp3');
    } else {
      _lastLevelScore = calculateScore();
      _totalScore += _lastLevelScore;

      _playSfx('level_win.mp3');

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

      if (_lastEarnedCoins > 0) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _playSfx('coin_gain.mp3');
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
      _playSfx('coin_gain.mp3');
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
      debugPrint("Review Error: $e");
    }
  }

  void applySpinReward(int reward, bool isFreeSpin) {
    if (reward > 0) {
      _totalCoins += reward;
      _playSfx('coin_gain.mp3');
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
      _playSfx('coin_gain.mp3');
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
    _playSfx('coin_gain.mp3');
    _saveData();
    notifyListeners();
  }

  void toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    notifyListeners();
  }

  void toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSfxEnabled', _isSfxEnabled);
    notifyListeners();
  }

  void toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', _isMusicEnabled);

    if (_isMusicEnabled) {
      _startBgm();
    } else {
      _bgmPlayer.stop();
    }
    notifyListeners();
  }

  void claimDoubleCoins() {
    if (!_isDoubleCoinClaimed && _lastEarnedCoins > 0) {
      _totalCoins += _lastEarnedCoins;
      _playSfx('coin_gain.mp3');
      _isDoubleCoinClaimed = true;
      _saveData();
      notifyListeners();
    }
  }

  void addBonusCoins(int amount) {
    _totalCoins += amount;
    _playSfx('coin_gain.mp3');
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
    _mismatchTimer?.cancel();
    _isManuallyPaused = true;
    _bgmPlayer.pause();
    notifyListeners();
  }

  void resumeGame() {
    if (!_isGameOver && !_isLocked && !_isTimeUp) {
      _isManuallyPaused = false;
      _startCountdown();
      if (_isMusicEnabled) _bgmPlayer.resume();
      _closeMismatchCards();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _delayedGameOverTimer?.cancel();
    _memorizeTimer?.cancel();
    _mismatchTimer?.cancel();
    for (var player in _sfxPlayers.values) {
      player.dispose();
    }
    _bgmPlayer.dispose();
    super.dispose();
  }
}
