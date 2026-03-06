import 'dart:async';
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

  int? _firstFlippedIndex; 
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

  // --- YENİ: GÜNLÜK ÇARK ZAMAN KONTROLÜ ---
  String _lastFreeSpinDate = ""; // "YYYY-MM-DD" formatında tutulacak
  
  bool get canSpinFree {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lastFreeSpinDate != today; // Eğer bugünün tarihi yoksa bedava çevirebilir
  }

  int get memorizeTimeMilliseconds => max(1000, 4000 - ((_currentLevel - 1) * 200));

  final List<Color> _colors = [
    const Color(0xFFFFD54F), const Color(0xFFEF5350), const Color(0xFF42A5F5),
    const Color(0xFFAB47BC), const Color(0xFF66BB6A), const Color(0xFFFFA726),
  ];

  final List<IconData> _icons = [
    Icons.star_rounded, Icons.favorite_rounded, Icons.diamond_rounded,
    Icons.hexagon_rounded, Icons.change_history_rounded, Icons.square_rounded,
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
    _lastFreeSpinDate = prefs.getString('lastFreeSpinDate') ?? ""; // Hafızadan tarihi çek
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_totalScore > _highScore) {
      _highScore = _totalScore;
      await prefs.setInt('highScore', _highScore);
    }
    if (_currentLevel > _highestLevel) {
      _highestLevel = _currentLevel;
      await prefs.setInt('highestLevel', _highestLevel);
    }
    await prefs.setInt('totalCoins', _totalCoins);
    await prefs.setStringList('ownedThemes', _ownedThemes);
    await prefs.setString('currentTheme', _currentTheme);
    await prefs.setString('lastFreeSpinDate', _lastFreeSpinDate); // Tarihi kaydet
  }

  // --- ÇARK ÖDÜLÜNÜ KASAYA EKLEME ---
  void applySpinReward(int reward, bool isFreeSpin) {
    if (reward > 0) {
      _totalCoins += reward;
    }
    
    // Eğer bedava çevirdiyse, bugünün tarihini kaydet ki bugün bir daha bedava çeviremesin
    if (isFreeSpin) {
      _lastFreeSpinDate = DateTime.now().toIso8601String().split('T')[0];
    }
    
    _saveData();
    notifyListeners();
  }

  bool buyTheme(String themeId, int price) {
    if (_totalCoins >= price && !_ownedThemes.contains(themeId)) {
      _totalCoins -= price;
      _ownedThemes.add(themeId);
      if (_isVibrationEnabled) HapticFeedback.mediumImpact();
      _saveData();
      notifyListeners();
      return true; 
    }
    if (_isVibrationEnabled) HapticFeedback.heavyImpact();
    return false; 
  }

  void equipTheme(String themeId) {
    if (_ownedThemes.contains(themeId)) {
      _currentTheme = themeId;
      if (_isVibrationEnabled) HapticFeedback.lightImpact();
      _saveData();
      notifyListeners();
    }
  }

  void buyCoinPackage(int amount) {
    _totalCoins += amount;
    if (_isVibrationEnabled) HapticFeedback.vibrate(); 
    _saveData();
    notifyListeners();
  }

  void toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    if (_isVibrationEnabled) HapticFeedback.lightImpact(); 
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
    _matchesFound = 0;
    _isGameOver = false;
    _firstFlippedIndex = null;
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
      if (_isVibrationEnabled) HapticFeedback.mediumImpact(); 
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

  void _generateCards() {
    int idCounter = 0;
    List<CardModel> tempCards = [];

    for (int i = 0; i < 6; i++) {
      tempCards.add(CardModel(id: idCounter++, color: _colors[i], icon: _icons[i], isFlipped: true));
      tempCards.add(CardModel(id: idCounter++, color: _colors[i], icon: _icons[i], isFlipped: true));
      
      int nextIconIndex = (i + 1) % 6; 
      tempCards.add(CardModel(id: idCounter++, color: _colors[i], icon: _icons[nextIconIndex], isFlipped: true));
      tempCards.add(CardModel(id: idCounter++, color: _colors[i], icon: _icons[nextIconIndex], isFlipped: true));
    }
    tempCards.shuffle(); 
    _cards = tempCards;
  }

  void onCardTapped(int index) {
    if (_isLocked || _isGameOver || _cards[index].isFlipped || _cards[index].isMatched) return;

    if (_isVibrationEnabled) HapticFeedback.lightImpact(); 
    _cards[index].isFlipped = true;
    notifyListeners();

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _checkForMatch(index);
    }
  }

  Future<void> _checkForMatch(int secondIndex) async {
    _isLocked = true; 
    int firstIndex = _firstFlippedIndex!;

    bool isMatch = (_cards[firstIndex].color == _cards[secondIndex].color) && 
                   (_cards[firstIndex].icon == _cards[secondIndex].icon);

    if (isMatch) {
      if (_isVibrationEnabled) HapticFeedback.mediumImpact(); 
      await Future.delayed(const Duration(milliseconds: 500));
      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _matchesFound++;

      if (_matchesFound == 12) {
        _gameOver();
      }
    } else {
      if (_isVibrationEnabled) HapticFeedback.heavyImpact(); 
      await Future.delayed(const Duration(milliseconds: 1000));
      _cards[firstIndex].isFlipped = false;
      _cards[secondIndex].isFlipped = false;
    }

    _firstFlippedIndex = null;
    if (!_isGameOver) {
      _isLocked = false; 
    }
    notifyListeners();
  }

  void _gameOver() {
    _isGameOver = true;
    _stopwatch.stop();
    _gamesPlayed++; 
    _isDoubleCoinClaimed = false; 

    if (_isVibrationEnabled) HapticFeedback.vibrate(); 
    
    _lastLevelScore = calculateScore();
    _totalScore += _lastLevelScore;
    
    int stars = calculateStars();
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