I've written before about using [Dart, Angular 2, and Polymer Together](https://dart.academy/dart-angular-2-and-polymer-together/), but that tutorial only demonstrated the use of a handful of simple [Polymer elements](https://elements.polymer-project.org), like [paper-header-panel](https://elements.polymer-project.org/elements/paper-header-panel), [paper-toolbar](https://elements.polymer-project.org/elements/paper-toolbar), [paper-icon-button](https://elements.polymer-project.org/elements/paper-icon-button), and the [flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/) goodies of [iron-flex-layout](https://elements.polymer-project.org/elements/iron-flex-layout). That's all great stuff, and I scarcely write an app without those things, but what about something more complicated, like elements that handle user input?

[Polymer](https://www.polymer-project.org/) and [Angular 2](https://angular.io) each have their own form validation routines, their own version of data binding. How can we make these things work together? In this article, I'll talk about a few approaches, then show you the simplest way to make [paper-input](https://elements.polymer-project.org/elements/paper-input) and [paper-button](https://elements.polymer-project.org/elements/paper-button), the workhorses of Polymer forms, cooperate with Angular's validation and data-binding structures.

> *Note:* If you'd like, you can check out my simple [number guessing game](https://github.com/montyr75/number_guessing_) on GitHub that uses this article's techniques. Sometimes it's better to see it in action.

The code was tested with Dart SDK 1.15.0, Polymer Dart 1.0.0-rc.15, and Angular 2.0.0-beta.11.

## Forms in Polymer
There's a great tutorial about creating a Polymer [Checkout Form with Autofill](https://dart.academy/polymer-dart-code-lab-checkout-form-with-autofill/) that I highly recommend, but we should very briefly look at that library's style and discuss one possibly approach to integrating it with an Angular app.

### Your Own Form Element
One way to solve the Polymer/Angular discrepancies is to hide them from each other. Polymer's form controls work great in the context of a Polymer element, so you could create a custom element with Polymer, couch the form within it, and spit out custom events for Angular to handle. This way, Angular might send data into your form element with bindings, and it can receive data from it via events, all the while having no idea what's going on inside the Polymer bubble you've created.

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

Now, to use this form in your Angular app, you just do something like this:

**my_angular_app.html**

    <div>
      <employee-form (new-employee)="onNewEmployee($event)">
      </employee-form>
    </div>

**my_angular_app.dart**

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

Pretty straightforward if you're familiar with Angular 2. When the custom Polymer element fires a `new-employee` event, the app's instance method `onNewEmployee()` is called, and it's passed the original Polymer event by way of Angular's special `$event` syntax. The event in this case still has the stench of JavaScript on it. The Polymer library is provided for use by Dart with a thin Dart wrapper around its essential JavaScript nature, so `onNewEmployee()` first needs to convert the `event` to a Dart object before it's easy to get to the `detail` field, which contains the event's payload. But other than that bit of unseemly business, there isn't any special handling that needs to be done with this approach.

But what about that `ViewEncapsulation.Native` stuff? Oh, yeah. Any time you're mixing Polymer and Angular together, it is necessary to force both to use real Shadow DOM component encapsulation. [Dart, Angular 2, and Polymer Together](https://dart.academy/dart-angular-2-and-polymer-together/) has more on that if you're interested in a deeper dive.

If you're content to use Polymer's validation routines, which are excellent, and you're comfortable wrapping your forms in a custom Polymer component, this approach will work well. There are other ways, though, that involve greater integration.

## Forms in Angular 2
I'm sure you've already read all about creating [forms in Angular 2](https://angular.io/docs/dart/latest/guide/forms.html), but let's run through the basics here anyway.

### Transformers
If that heading got you all excited to watch giant CGI robots blasting off each other's limbs to make Michael Bay even more money, you might not be logical enough to be a programmer. Of course, we're talking about [Dart's code transformers](https://www.dartlang.org/tools/pub/assets-and-transformers.html) here. You can configure the Angular transformer to automatically make core and form directives available in your components:

**pubspec.yaml**

    transformers:
    - angular2:
        platform_directives:
        - 'package:angular2/common.dart#CORE_DIRECTIVES'
        - 'package:angular2/common.dart#FORM_DIRECTIVES'
        entry_points: web/main.dart
    
With these `platform_directives` entries, you don't have to bother explicitly including common directives in your `@Component` declarations.

**no need for this `directives`** entry

    @Component(selector: 'guess-form',
        templateUrl: 'guess_form.html',
        directives: const [NgModel, NgControl, NgIf]
    )

### Plain Ol' Inputs
Without Polymer controls, your Angular form component's template might look something like this:

**guess_form.html**

    <form #guessForm="ngForm">
      <input type="text" [(ngModel)]="guess" ngControl="guessInput">    
      <button [disabled]="!guessForm.form.valid" (click)="makeGuess()">
        Guess
      </button>
    </form>

