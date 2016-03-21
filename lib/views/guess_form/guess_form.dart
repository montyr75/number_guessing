import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/paper_badge.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_button.dart';

@Component(selector: 'guess-form',
    encapsulation: ViewEncapsulation.Native,
    templateUrl: 'guess_form.html'
)
class GuessForm {
  final Logger _log;

  String guess;
  @Input() int guesses = 0;
  @Output() EventEmitter<int> guessed = new EventEmitter<int>();

  @ViewChild('guessForm') NgForm guessForm;
  @ViewChild('guessInput') ElementRef guessInput;

  GuessForm(Logger this._log) {
    _log.info("$runtimeType()");
  }

  void submit([bool enter = false]) {
    _log.info("$runtimeType::makeGuess() -- $guess");

    if (guessForm.form.valid) {
      guessed.emit(int.parse(guess, onError: (_) => null));

      guess = null;

      if (!enter) {
        setFocus();
      }
    }
  }

  void setFocus() {
    _log.info("$runtimeType::setFocus()");

    // allow bindings to propagate before setting focus
    Timer.run(() => guessInput.nativeElement.focus());
  }
}