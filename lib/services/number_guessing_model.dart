import 'dart:math';

import 'package:angular2/core.dart';
import 'package:logging/logging.dart';

@Injectable()
class NumberGuessingModel {
  final Logger _log;

  int _min;             // lowest number in random range
  int _max;             // highest number in random range

  int _target;          // the number to be guessed
  int _guesses;         // number of guesses made
  int _lastGuess;       // the player's last guess
  int _deviation;       // deviation between _guess and _target

  NumberGuessingModel(Logger this._log) {
    _log.info("$runtimeType()");
  }

  void newGame({int min: 1, int max: 10}) {
    _log.info("$runtimeType::newGame()");

    _min = min;
    _max = max;

    // set random number for the player to guess
    _target = new Random().nextInt(_max) + _min;

    _guesses = 0;
    _lastGuess = null;
    _deviation = null;
  }

  int makeGuess(int guess) {
    _log.info("$runtimeType::makeGuess()");

    _lastGuess = guess;
    _guesses++;
    _deviation = _target - _lastGuess;

    return _deviation;
  }

  int get min => _min;
  int get max => _max;
  int get target => _target;
  int get guesses => _guesses;
  int get lastGuess => _lastGuess;
  int get deviation => _deviation;
}