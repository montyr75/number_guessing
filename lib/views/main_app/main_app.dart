import 'dart:async';

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
    directives: const [GuessForm],
    styleUrls: const ['bootstrap.min.css']
)
class MainApp implements AfterViewInit {
  final Logger _log;

  NumberGuessingModel model;

  @ViewChild('guessForm') GuessForm guessForm;

  MainApp(Logger this._log, NumberGuessingModel this.model) {
    _log.info("$runtimeType()");
  }

  void ngAfterViewInit() {
    _log.info("$runtimeType::ngAfterViewInit()");

    // delay to avoid "Expression has changed" Angular exception
    Timer.run(newGame);
  }

  void newGame() {
    _log.info("$runtimeType::newGame()");

    model.newGame();
    guessForm.setFocus();

    _log.info("Picked: ${model.target}");
  }

  void onGuess(int guess) {
    _log.info("$runtimeType::onGuess()");

    model.makeGuess(guess);
  }
}