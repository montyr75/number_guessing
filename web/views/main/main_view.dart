library main_view;

import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';
import '../../utils/filters.dart';
import 'package:polymer_expressions/filter.dart';

// @CustomTag metatag ties MainView class to <main-view> HTML elements
// an instance of MainView will be created for each use of the <main-view> HTML element
@CustomTag('main-view')
class MainView extends PolymerElement {

  // constants
  @observable int MIN_NUM = 1;
  @observable int MAX_NUM = 10;
  static const String DEFAULT_MESSAGE_STATE = "label-default";
  static const String ERROR_MESSAGE_STATE = "label-danger";
  static const String WIN_MESSAGE_STATE = "label-success";

  // strings
  static const String ENTER_GUESS = "Enter a guess.";
  static const String WIN = "You win! Fuckin' studly mind-reader, you.";
  static const String LOW = "Ummmm, no. That guess is too low.";
  static const String HIGH = "Whoa, settle down there, pardner! Too high!";
  static const String INPUT_ERROR = "What the...? That's not a whole number, turd bomb!";
  static const String GUESS = "Guess";
  static const String PLAY_AGAIN = "Play Again";

  // game data
  int _randomNumber;      // the number to be guessed

  // UI data
  @observable int guessInput;           // the user's guess
  @observable String gameStateMessage;  // text to display to user regarding game's state
  @observable String messageState;      // CSS class to apply to game state message display
  @observable String btnText;           // the label of the game's only button
  @observable String btnState;          // CSS class to apply to the game's button
  @observable bool disableInput;        // when true, input box is disabled
  @observable int guesses;              // to count the user's guesses
  @observable String lastGuess;         // store the user's last guess for display purposes

  // filters and transformers can be referenced as fields
  final Transformer asInteger = new StringToInt();

  // Polymer elements are instantiated with the .created named constructor
  MainView.created() : super.created();

  // this function is called when the Polymer element enters the view
  // the @override metatag marks it (optionally) as an overridden inherited function
  @override void enteredView() {
    super.enteredView();
    print("MainView::enteredView()");

    newGame();
  }

  void newGame() {
    print("MainView::newGame()");

    // set default values
    guesses = 0;
    lastGuess = '';
    gameStateMessage = ENTER_GUESS;
    messageState = DEFAULT_MESSAGE_STATE;
    btnText = GUESS;
    disableInput = false;

    // need to relinquish control to Dart event loop before "disableInput" change will take effect
    async((_) => resetInput());

    // set random number for the user to guess
    _randomNumber = new Random().nextInt(MAX_NUM) + MIN_NUM;

    print("Picked: $_randomNumber");
  }

  // Polymer event handlers always have this signature
  void buttonClicked(Event event, var detail, Element target) {
    print("MainView::buttonClicked()");

    // if the user clicks the button, do the appropriate thing
    switch (btnText) {
      case GUESS: processGuess(); break;
      case PLAY_AGAIN: newGame(); break;
    }
  }

  void processGuess() {
    print("MainView::processGuess()");

    // throw error if there's a problem with input
    // our asInteger Transformer returns null if the input is not a valid integer
    if (guessInput == null) {
      gameStateMessage = INPUT_ERROR;
      messageState = ERROR_MESSAGE_STATE;
      resetInput();
      return;
    }

    // count this guess and update the count display in the UI
    guesses++;

    // display the last guess made in the UI
    lastGuess = guessInput.toString();

    // check for win
    if (guessInput == _randomNumber) {
      gameStateMessage = "$WIN It was $_randomNumber.";
      messageState = WIN_MESSAGE_STATE;
      btnText = PLAY_AGAIN;
      disableInput = true;
      $['guess-btn'].focus();
      return;
    }
    else if (guessInput < _randomNumber) {
      gameStateMessage = LOW;
    }
    else if (guessInput > _randomNumber) {
      gameStateMessage = HIGH;
    }

    // clear and set keyboard focus on the input box
    resetInput();

    // since we just had a valid guess, make sure we're not in an error state
    messageState = DEFAULT_MESSAGE_STATE;
  }

  void resetInput() {
    // get a reference to element with "guess-input" ID, then clear its value and set keyboard focus on it
    $['guess-input'] as InputElement
      ..value = ""
      ..focus();

    guessInput = null;
  }

  // prevent a <form> submit from reloading the app
  void submit(Event event, var detail, Element target) {
    event.preventDefault();
  }

  // this lets the global CSS bleed through into the Shadow DOM of this element
  bool get applyAuthorStyles => true;
}

