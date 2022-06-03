import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'player_data.g.dart';

// This class stores the player progress presistently.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  int _lives = 5;

  int _level = 1;

  int superpower = 1 ;

  int get lives => _lives;
  set lives(int value) {
    if (value <= 5 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  int _currentScore = 0;
  int temp = 0;
  int get currentScore => _currentScore;
  set currentScore(int value) {
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
    }

    if (_currentScore - temp == 2) {
      temp = _currentScore;
      _level++;
      superpower=1;
    }

    notifyListeners();
  }

  int get level => _level;
  set level(int value) {
    _level=value;
    notifyListeners();
    
  }
}
