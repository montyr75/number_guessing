import 'dart:html';
import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_material.dart';

import '../../services/number_guessing_model.dart';
import '../guess_form/guess_form.dart';

@Component(selector: 'main-app',
    encapsulation: ViewEncapsulation.Native,
    templateUrl: 'main_app.html',
    providers: const [NumberGuessingModel],
    directives: const [GuessForm]
)
class MainApp {
  final Logger _log;

  // strings
  static const String ENTER_GUESS = "Enter a guess.";
  static const String WIN = "You win! You guessed the number.";
  static const String LOW = "Ummmm, no. That guess is too low.";
  static const String HIGH = "Whoa! Too high!";
  static const String INPUT_ERROR = "What the...? That's not a whole number!";

  // model
  NumberGuessingModel model;

  // UI
  String message;

  MainApp(Logger this._log, NumberGuessingModel this.model) {
    _log.info("$runtimeType()");

    newGame();
  }

  void newGame() {
    _log.info("$runtimeType::newGame()");

    // set default values
    model.newGame();
    message = ENTER_GUESS;

    _log.info("Picked: ${model.target}");
  }

  void onGuess(int guess) {
    _log.info("$runtimeType::onGuess()");

    model.makeGuess(guess);

    // throw error if there's a problem with input
    // our asInteger Transformer returns null if the input is not a valid integer
//    if (guessInput == null) {
//      gameStateMessage = INPUT_ERROR;
//      messageState = ERROR_MESSAGE_STATE;
//      resetInput();
//      return;
//    }
//
//    // check for win
//    if (guessInput == _randomNumber) {
//      gameStateMessage = "$WIN It was $_randomNumber.";
//      messageState = WIN_MESSAGE_STATE;
//      btnText = PLAY_AGAIN;
//      disableInput = true;
//      $['guess-btn'].focus();
//      return;
//    }
//    else if (guessInput < _randomNumber) {
//      gameStateMessage = LOW;
//    }
//    else if (guessInput > _randomNumber) {
//      gameStateMessage = HIGH;
//    }
//
//    // clear and set keyboard focus on the input box
//    resetInput();
//
//    // since we just had a valid guess, make sure we're not in an error state
//    messageState = DEFAULT_MESSAGE_STATE;
  }
}