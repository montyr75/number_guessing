I've written before about using [Dart, Angular 2, and Polymer Together](https://dart.academy/dart-angular-2-and-polymer-together/), but that tutorial only demonstrated the use of a handful of simple [Polymer elements](https://elements.polymer-project.org), like [paper-header-panel](https://elements.polymer-project.org/elements/paper-header-panel), [paper-toolbar](https://elements.polymer-project.org/elements/paper-toolbar), [paper-icon-button](https://elements.polymer-project.org/elements/paper-icon-button), and the [flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/) goodies of [iron-flex-layout](https://elements.polymer-project.org/elements/iron-flex-layout). That's all great stuff, and I scarcely write an app without those things, but what about something more complicated, like elements that handle user input?

[Polymer](https://www.polymer-project.org/) and [Angular 2](https://angular.io) each have their own form validation routines, their own version of data binding. How can we make these things work together? In this article, I'll talk about a few approaches, then show you the simplest way to make [paper-input](https://elements.polymer-project.org/elements/paper-input) and [paper-button](https://elements.polymer-project.org/elements/paper-button), the workhorses of Polymer forms, cooperate with Angular's validation and data-binding structures.

> *Note:* If you'd like, you can check out my simple [number guessing game](https://github.com/montyr75/number_guessing_) on GitHub that uses this article's techniques. Sometimes it's better to see it in action.

The code was tested with Dart SDK 1.15.0, Polymer Dart 1.0.0-rc.15, and Angular 2.0.0-beta.11.

## Forms in Polymer
There's a great tutorial about creating a Polymer [Checkout Form with Autofill](https://dart.academy/polymer-dart-code-lab-checkout-form-with-autofill/) that I highly recommend, but we should very briefly look at Polymer's form style here and discuss one possible approach to integrating it with an Angular app.

### Your Own Form Element
One way to solve the Polymer/Angular discrepancies is to hide them from each other. Polymer's form controls work great in the context of a Polymer element, so you could create a custom element with Polymer, couch the form within it, and spit out custom events for Angular to handle. This way, Angular might send data into your form element with bindings, and it can receive data from it via events, all while having no idea what's going on inside the Polymer bubble you've created.

What might such a thing look like? Well, if you were to create a form that simply asked for an employee's name, the custom Polymer element might look like this:

**employee_form.html**

    <dom-module id="employee-form">
      <template>
        <form id="form" is="iron-form">
          <paper-input name="name" label="Name" required>
                       value="{{employeeName}}"
          </paper-input>
          <paper-button on-tap="submit">Pay</paper-button>
        </form>
      </template>
    </dom-module>

**employee_form.dart**

    @HtmlImport('employee_form.html')
    library my_project_.lib.checkout_form;
    
    import 'dart:html';
    import 'package:polymer/polymer.dart';
    import 'package:web_components/web_components.dart';
    
    @PolymerRegister('checkout-form')
    class EmployeeForm extends PolymerElement {
    
      @property
      String employeeName;
    
      EmployeeForm.created() : super.created();
    
      @reflectable
      void submit(Event event, var detail) {
        fire("new-employee", detail: employeeName);
      }
    }

We won't go into great detail about how Polymer forms work. The point here is that within the confines of a custom Polymer element, it's easy to make them work well. The `<paper-input`'s `value` attribute sets up a two-way data binding connection with the `employeeName` property of EmployeeForm, so anything the user types is automatically mirrored there. Clicking the `<paper-button>` calls EmployeeForm's `submit()` method, which fires a custom event called `new-employee` with the new employee's name as the payload.

Now, to use this form in your Angular app, you could do something like this:

**my\_angular\_app.html**

    <div>
      <employee-form (new-employee)="onNewEmployee($event)">
      </employee-form>
    </div>

**my\_angular\_app.dart**

    import 'package:angular2/angular2.dart';
    import 'package:polymer/polymer.dart';
    import 'employee_form.dart';
    
    @Component(selector: 'my-angular-app',
        encapsulation: ViewEncapsulation.Native,
        templateUrl: 'my_angular_app.html'
    )
    class MyAngularApp {
      String name;
    
      MyAngularApp();
    
      void onNewEmployee(event) {
        name = convertToDart(event).detail;
      }
    }

Pretty straightforward if you're familiar with Angular 2. When the custom Polymer element fires a `new-employee` event, the app's instance method `onNewEmployee()` is called, and it's passed the original Polymer event by way of Angular's special `$event` syntax. The event in this case still has the stench of JavaScript on it. The Polymer library is provided for use by Dart with a thin Dart wrapper around its essential JavaScript nature, so `onNewEmployee()` first needs to convert `event` to a Dart object before it's easy to get to the `detail` field, which contains the event's payload. But other than that bit of unseemly business, there isn't any special handling that needs to be done with this approach.

But what about that `ViewEncapsulation.Native` stuff? Oh, yeah. Any time you're mixing Polymer and Angular together, it is necessary to force both to use real Shadow DOM component encapsulation. [Dart, Angular 2, and Polymer Together](https://dart.academy/dart-angular-2-and-polymer-together/) has more on that if you're interested in a deeper dive.

If you're content to use Polymer's validation routines, which are excellent, and you're comfortable wrapping your forms in a custom Polymer component, this approach will work well. There are other ways, though, that involve greater integration.

## Forms in Angular 2
I'm sure you've already read all about creating [forms in Angular 2](https://angular.io/docs/dart/latest/guide/forms.html), but let's run through the basics here anyway.

### Transformers
If that heading got you all excited to watch giant CGI robots blasting off each other's limbs to make Michael Bay even more money, you might not be smart enough to be a programmer. Of course, we're talking about [Dart's code transformers](https://www.dartlang.org/tools/pub/assets-and-transformers.html) here. You can configure the Angular transformer to automatically make core and form directives available in your components:

**pubspec.yaml**

    transformers:
    - angular2:
        platform_directives:
        - 'package:angular2/common.dart#CORE_DIRECTIVES'
        - 'package:angular2/common.dart#FORM_DIRECTIVES'
        entry_points: web/main.dart
    
With these `platform_directives` entries, you don't have to bother explicitly including common directives in your `@Component` declarations:

**no need for this `directives`** entry

    @Component(selector: 'guess-form',
        templateUrl: 'guess_form.html',
        directives: const [NgModel, NgControl, NgIf]
    )

### Plain Ol' Browser Controls
Without Polymer controls, your Angular form component's template for a number guessing game might look something like this:

**guess_form.html**

    <form #guessForm="ngForm" (ngSubmit)="submit()">
      <input type="text"
             [(ngModel)]="guess" ngControl="guessInputCtrl"
             required pattern="[0-9]">    
      <button type="submit" [disabled]="!guessForm.form.valid">
        Guess
      </button>
    </form>

So this is pretty good. By way of `NgModel` and two-way binding, the form component's `guess` property and the `<input>`'s `value` property will always be in sync. There's even some validation going on here: In order for `guessForm.form.valid` to be `true`, the `<input>` can't be empty (`required`), and only numeric characters are allowed (`pattern="[0-9]"`). Activating the `<button>` will cause the `NgForm` to fire off an `ngSubmit` event, and that will run the component's `submit()` method.

HTML's `<input>` element is a bit limited, though. For instance, what if we don't want to allow illegal characters to be typed at all? And what about validation-related styling? All of that would need to be handled manually in this scenario. In fact, Angular provides no styling of any kind, so the controls look pretty stupid. Sure, you could use something like [Bootstrap](http://getbootstrap.com/) to jazz things up, but site-wide CSS files are starting to feel a little awkward in apps built with components&mdash;with Shadow DOM in place, it may not work at all. You could end up having to include all of Bootstrap in every component.

## Polymer to the Rescue
Built-in styling with [Material Design](https://www.google.com/design/spec/material-design)? It's there. Advanced validation features? Yep, those too. Ripple effects and cool animation? All there.

Let's assume you're sold on the advantages of using Polymer controls in your Angular form. Do they work? Are there problems? The answer to both questions is "Yes."

### Problems
Out of the box, Polymer's paper elements aren't designed to interact with `NgForm`, `NgControl`, or even `NgModel`. So if you just replace your controls with a `<paper-input>` and a `<paper-button>`, you'll find that nothing behaves as you'd like. No two-way binding, no validation integration with the form, no `ngSubmit` event, and your dog will stop coming when you call. Exceptions will be thrown! It's a mess.

A standard developer would give up right there and go cry to Bootstrap, but we 10x developers persevere in the face of adversity, right?
 
### Solutions
It turns out that the Angular devs have given us what we need to fix most of this stuff, and it's a directive called `NgDefaultControl`. To my knowledge, there really isn't any official documentation on this directive yet, but if you find something, let me know. Essentially, it provides an element with a standard `value` accessor, and that helps `NgModel` and `NgControl` do their thing.

**guess_form.html**

    <style>
      paper-input {
        width: 50px;
        text-align: center;
        margin-right: 5px;
      }
    
      paper-button {
        text-transform: none;
        cursor: default;
      }
    </style>
    
    <form #guessForm="ngForm" class="layout horizontal center center-justified">
      <paper-input #guessInput type="text" ngDefaultControl
                   [(ngModel)]="guess" ngControl="guessInputCtrl"
                   required allowed-pattern="[0-9]" maxlength="3"
                   (keyup.enter)="submit(true)">
      </paper-input>
    
      <paper-button raised [disabled]="!guessForm.form.valid"
                    (click)="submit()">
        Guess
      </paper-button>
    </form>

[The game](https://github.com/montyr75/number_guessing_) uses a form component template much like this one. The `<form>` is laid out using Polymer's iron-flex-layout classes, and there's a little bit of styling to keep things tame.

For the most part, we're back in business, thanks to the `ngDefaultControl` attribute on `<paper-input>`. One thing we don't get back is the `ngSubmit` event, but we don't really need it, as we can simply call `submit()` in response to control events. The `<paper-input>`'s `allowed-pattern` and `maxlength` attributes stop the user from entering anything crazy, and if we wanted to, we could add `autoValidate` to make it self-apply styling for bad values. Note the use of `(keyup.enter)` on the input control, a great Angular shorthand for responding to the <kbd>Enter</kbd> key.

And here's the component class:

**guess_form.dart**

    import 'dart:async';
    
    import 'package:angular2/angular2.dart';
    import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
    import 'package:polymer_elements/paper_input.dart';
    import 'package:polymer_elements/paper_button.dart';
    
    @Component(selector: 'guess-form',
        encapsulation: ViewEncapsulation.Native,
        templateUrl: 'guess_form.html'
    )
    class GuessForm {
      String guess;
      @Input() int guesses = 0;
      @Output() EventEmitter<int> guessed = new EventEmitter<int>();
    
      @ViewChild('guessForm') NgForm guessForm;
      @ViewChild('guessInput') ElementRef guessInput;
    
      GuessForm();
    
      void submit([bool enter = false]) {
        if (guessForm.form.valid) {
          guessed.emit(int.parse(guess, onError: (_) => null));
    
          guess = null;
    
          if (!enter) {
            setFocus();
          }
        }
      }
    
      void setFocus() {
        // allow bindings to propagate before setting focus
        Timer.run(() => guessInput.nativeElement.focus());
      }
    }

We import all the Polymer stuff we need, force Shadow DOM on with `ViewEncapsulation.Native`, and from there it's a pretty standard Angular "controller." The idea behind encapsulating the form in a component is that we can hide the details of acquiring user input from the main program. All the validation and such happens here, and only when we have a valid guess do we `emit()` an event out to the rest of the app.

The application can use the form like this:

    <guess-form #guessForm (guessed)="onGuess($event)"></guess-form>

Nice and clean.

## Conclusion
It takes a bit of detective work to make the Polymer library and the Angular 2 framework work together, but I think it's well worth it, especially with sites like [customelements.io](https://customelements.io/) out there. Nearly 2000 elements on that site as I write this. (Incidentally, be on the lookout for an upcoming article on how you can prepare those elements for use with Dart.) I've done a bunch of the work for you already, so what have you got to lose? Get out there and use _all_ the tools!