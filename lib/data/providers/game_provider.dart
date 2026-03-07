import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_model.dart'; 

class GameProvider extends ChangeNotifier {
  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  bool _isLocked = true; 
  bool get isLocked => _isLocked;

  // COMBO SİSTEMİ: Kilitlenmeyi önler, oyuncu hızlıca arka arkaya kart açabilir
  final List<int> _currentFlippedCards = []; 
  
  int _matchesFound = 0;   
  
  final Stopwatch _stopwatch = Stopwatch();
  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;

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

  // --- YILDIZ HAFIZASI ---
  Map<String, int> _levelStars = {}; 
  
  int getStarsForLevel(int level) {
    return _levelStars[level.toString()] ?? 0;
  }

  // Hafıza süresi 20 karta göre sabit ve dengeli
  int get memorizeTimeMilliseconds => max(1500, 4000 - ((_currentLevel - 1) * 100));

  // EFSANE RENK PALETİN
  final List<Color> _colors = [
    const Color(0xFFFFD54F), const Color(0xFFEF5350), const Color(0xFF42A5F5),
    const Color(0xFFAB47BC), const Color(0xFF66BB6A), const Color(0xFFFFA726),
    const Color(0xFF26C6DA), const Color(0xFFEC407A), const Color(0xFF8D6E63),
    const Color(0xFF78909C),
  ];

  // TOK İKONLARIN (details_rounded = içi dolu üçgen)
  final List<IconData> _icons = [
    Icons.star_rounded, Icons.favorite_rounded, Icons.diamond_rounded,
    Icons.hexagon_rounded, Icons.details_rounded, Icons.square_rounded, 
    Icons.circle, Icons.shield_rounded, Icons.cloud_rounded, Icons.anchor_rounded,
  ];

  GameProvider() {
    _loadSavedData(); 
    startGame();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    _highestLevel = prefs.getInt('highestLevel') ?? 1;
    _totalCoins = prefs.getInt('totalCoins') ?? 0;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true;
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    _ownedThemes = prefs.getStringList('ownedThemes') ?? ['classic'];
    _currentTheme = prefs.getString('currentTheme') ?? 'classic';
    _lastFreeSpinDate = prefs.getString('lastFreeSpinDate') ?? ""; 
    
    final starsString = prefs.getString('levelStars');
    if (starsString != null) {
      _levelStars = Map<String, int>.from(json.decode(starsString));
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_totalScore > _highScore) {
      _highScore = _totalScore;
      await prefs.setInt('highScore', _highScore);
    }
    
    // --- BUG ÇÖZÜMÜ: YENİ SEVİYENİN KİLİDİNİ KIRMA ---
    if (_currentLevel >= _highestLevel) {
      _highestLevel = _currentLevel + 1;
      await prefs.setInt('highestLevel', _highestLevel);
    }
    
    await prefs.setInt('totalCoins', _totalCoins);
    await prefs.setStringList('ownedThemes', _ownedThemes);
    await prefs.setString('currentTheme', _currentTheme);
    await prefs.setString('lastFreeSpinDate', _lastFreeSpinDate); 
    
    await prefs.setString('levelStars', json.encode(_levelStars));
  }

  void applySpinReward(int reward, bool isFreeSpin) {
    if (reward > 0) _totalCoins += reward;
    if (isFreeSpin) _lastFreeSpinDate = DateTime.now().toIso8601String().split('T')[0];
    _saveData();
    notifyListeners();
  }

  bool buyTheme(String themeId, int price) {
    if (_totalCoins >= price && !_ownedThemes.contains(themeId)) {
      _totalCoins -= price;
      _ownedThemes.add(themeId);
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
    notifyListeners();
  }

  void startGame() {
    _cards.clear();
    _currentFlippedCards.clear();
    _matchesFound = 0;
    _isGameOver = false;
    _stopwatch.reset();
    _isLocked = true; 

    _generateCards();
    notifyListeners();

    Timer(Duration(milliseconds: memorizeTimeMilliseconds), () {
      for (var card in _cards) {
        card.isFlipped = false;
      }
      _isLocked = false; 
      _stopwatch.start(); 
      notifyListeners();
    });
  }

  void playSpecificLevel(int level) {
    _currentLevel = level;
    startGame();
  }

  void restartGame() {
    _currentLevel = 1;
    _totalScore = 0;
    startGame();
  }

  void nextLevel() {
    _currentLevel++;
    startGame();
  }

  // --- ZORLUK MANTIĞI: Sabit 20 Kart, Değişen Çeşitlilik ---
  void _generateCards() {
    int idCounter = 0;
    List<CardModel> tempCards = [];
    Random random = Random();
    List<Map<String, dynamic>> uniqueCombos = [];

    int uniqueVariety = 4; // Level 1-10: Sadece 4 çeşit
    if (_currentLevel > 10 && _currentLevel <= 25) {
      uniqueVariety = 7;   // Level 11-25: 7 çeşit
    } else if (_currentLevel > 25) {
      uniqueVariety = 10;  // Level 26+: 10 çeşit
    }

    while (uniqueCombos.length < uniqueVariety) {
      Color c = _colors[random.nextInt(_colors.length)];
      IconData ic = _icons[random.nextInt(_icons.length)];
      bool exists = uniqueCombos.any((cmb) => cmb['color'] == c && cmb['icon'] == ic);
      if (!exists) {
        uniqueCombos.add({'color': c, 'icon': ic});
      }
    }

    List<Map<String, dynamic>> finalPairsToCreate = [];
    for (int i = 0; i < 10; i++) {
      finalPairsToCreate.add(uniqueCombos[i % uniqueVariety]);
    }

    for (var combo in finalPairsToCreate) {
      tempCards.add(CardModel(id: idCounter++, color: combo['color'], icon: combo['icon'], isFlipped: true));
      tempCards.add(CardModel(id: idCounter++, color: combo['color'], icon: combo['icon'], isFlipped: true));
    }

    tempCards.shuffle(random); 
    _cards = tempCards;
  }

  // COMBO DESTEKLİ DOKUNMA SİSTEMİ
  void onCardTapped(int index) {
    if (_isLocked || _isGameOver || _cards[index].isFlipped || _cards[index].isMatched) return;

    // KART ÇEVİRİRKEN TİTREŞİM YOK!
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
    bool isMatch = (_cards[firstIndex].color == _cards[secondIndex].color) && 
                   (_cards[firstIndex].icon == _cards[secondIndex].icon);

    if (isMatch) {
      // SADECE EŞLEŞTİĞİNDE TİTREŞİM YAPAR!
      if (_isVibrationEnabled) HapticFeedback.mediumImpact(); 
      
      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _matchesFound++;

      if (_matchesFound == 10) { 
        _gameOver();
      }
      notifyListeners();
    } else {
      await Future.delayed(const Duration(milliseconds: 1000));
      _cards[firstIndex].isFlipped = false;
      _cards[secondIndex].isFlipped = false;
      notifyListeners();
    }
  }

  void _gameOver() {
    _isGameOver = true;
    _stopwatch.stop();
    _gamesPlayed++; 
    _isDoubleCoinClaimed = false; 

    _lastLevelScore = calculateScore();
    _totalScore += _lastLevelScore;
    
    int stars = calculateStars();
    
    int previousStars = _levelStars[_currentLevel.toString()] ?? 0;
    if (stars > previousStars) {
      _levelStars[_currentLevel.toString()] = stars; 
    }

    if (stars == 3) {
      _lastEarnedCoins = 5;
    } else if (stars == 2) _lastEarnedCoins = 3;
    else if (stars == 1) _lastEarnedCoins = 1;
    else _lastEarnedCoins = 0;

    _totalCoins += _lastEarnedCoins;

    _saveData(); 
    notifyListeners();
  }

  void claimDoubleCoins() {
    if (!_isDoubleCoinClaimed && _lastEarnedCoins > 0) {
      _totalCoins += _lastEarnedCoins; 
      _isDoubleCoinClaimed = true;
      _saveData();
      notifyListeners();
    }
  }

  void addBonusCoins(int amount) {
    _totalCoins += amount;
    _saveData();
    notifyListeners();
  }

  int calculateScore() {
    int penalty = elapsedSeconds * 100;
    return max(0, 10000 - penalty); 
  }

  int calculateStars() {
    if (elapsedSeconds <= 30) return 3;
    if (elapsedSeconds <= 60) return 2;
    if (elapsedSeconds <= 90) return 1;
    return 0;
  }

  void pauseGame() {
    _stopwatch.stop();
    notifyListeners();
  }

  void resumeGame() {
    if (!_isGameOver && !_isLocked) {
      _stopwatch.start();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopwatch.stop(); 
    super.dispose();
  }
}