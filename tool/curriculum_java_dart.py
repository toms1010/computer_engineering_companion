"""Dart / Flutter curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(5, 'Dart / Flutter', 'Programming',
        'Dart • Widgets • State • Async', 'smart_toy')

lesson(5, 1, 'Dart Basics',
    concept='Dart is a client-optimized, statically-typed language for building apps on any platform, created by Google and powering Flutter.',
    definition='Dart is a programming language optimized for UI development with sound null safety, JIT for development, and AOT compilation for production.',
    explanation='Dart code runs on the Dart VM (JIT during development for hot reload) or compiles to native machine code (AOT for release). It is strongly typed with type inference (var, dynamic, final, const). Dart supports both OOP and functional styles. Flutter uses Dart for all app code.',
    worked='void main() {\n  var name = "Tommy";   // inferred as String\n  final age = 20;       // single assignment\n  const pi = 3.14159;   // compile-time constant\n  print("$name is $age");\n}',
    eng='Flutter apps for iOS, Android, web, and desktop are written entirely in Dart, sharing one codebase across platforms.',
    mistakes='Confusing final and const; using dynamic to avoid types; not understanding JIT vs AOT.',
    practice=['What is the difference between final and const?', 'How does Dart achieve hot reload?'],
    quiz=[
        q('What framework uses Dart?', ['React', 'Flutter', 'Angular', 'Vue'], [1], 'Flutter is Google\'s UI toolkit using Dart.'),
        q('What does AOT compilation produce?', ['Bytecode', 'Native machine code', 'Source code', 'JavaScript only'], [1], 'AOT compiles to native code.'),
    ])

lesson(5, 2, 'Variables',
    concept='Dart variables use var (type inference), explicit types, final (runtime constant), and const (compile-time constant).',
    definition='A Dart variable is a typed storage location; var infers the type, final allows single assignment, const is a compile-time constant.',
    explanation='var name = "Tommy" infers String and locks the type. final values are set once at runtime. const values are compile-time constants, enabling canonicalization. Dart\'s type system is sound: types are checked at compile time and runtime. late defers initialization.',
    worked='var count = 0;          // int\nString name = "Ada";  // explicit\ndouble price = 9.99;\nfinal now = DateTime.now();  // runtime constant\nconst maxRetries = 3;         // compile-time',
    eng='Flutter widget fields are final (immutable widgets); const constructors enable widget tree optimizations.',
    mistakes='Using var when a type is clearer; reassigning final; not using const for compile-time values.',
    practice=['When should you use const?', 'What does late do?'],
    quiz=[
        q('Which keyword declares a compile-time constant?', ['final', 'const', 'var', 'static'], [1], 'const is compile-time.'),
        q('What does var do?', ['Makes dynamic', 'Infers the type', 'Declares final', 'Imports a type'], [1], 'var infers the type from the initializer.'),
    ])

lesson(5, 3, 'Null Safety',
    concept='Dart sound null safety prevents null reference errors at compile time by distinguishing nullable (?) and non-nullable types.',
    definition='Null safety is a Dart feature where types are non-nullable by default; nullable types require ? and explicit null handling.',
    explanation='String name; cannot be null. String? nickname; can be null. Accessing nullable values requires null-aware operators: ?. (safe access), ?? (default), ! (null assertion), and ?[] (null-aware index). Flow analysis promotes nullable variables to non-null after null checks.',
    worked='String? name;\nprint(name?.length);   // null if name is null\nprint(name ?? "Guest"); // default value\nif (name != null) {\n  print(name.length);  // promoted to non-null\n}',
    eng='Flutter code uses ?. for optional widget properties and ?? for default values, eliminating null crashes in production.',
    mistakes='Overusing ! (null assertion); not handling nullable returns; assuming API data is non-null.',
    practice=['What does ?. do?', 'What is the difference between ? and !?'],
    quiz=[
        q('What does String? mean?', ['Non-nullable', 'Nullable', 'Constant', 'Private'], [1], '? marks a nullable type.'),
        q('What does the ?? operator do?', ['Asserts non-null', 'Provides a default for null', 'Checks equality', 'Casts types'], [1], '?? returns the right value if the left is null.'),
    ])

lesson(5, 4, 'Functions',
    concept='Dart functions are first-class objects supporting optional named, positional, and default parameters, plus arrow syntax.',
    definition='A function is a reusable block that can be assigned to variables, passed as arguments, and returned from other functions.',
    explanation='Dart supports optional positional parameters ([int? x]) and named parameters ({required int x, int y = 0}). Named parameters improve readability at call sites. Arrow functions (=> expr) return a single expression. Functions can be nested, anonymous (closures), and assigned to variables.',
    worked='int add(int a, int b) => a + b;\n\nvoid greet({required String name, String greeting = "Hello"}) {\n  print("$greeting, $name!");\n}\n\ngreet(name: "Tommy");',
    eng='Flutter callbacks (onPressed: () {}) are functions passed as parameters, enabling event-driven UI code.',
    mistakes='Forgetting required on named parameters; using optional positional when named is clearer; not typing callbacks.',
    practice=['What is the difference between named and positional parameters?', 'What is a closure?'],
    quiz=[
        q('Which marks a required named parameter?', ['@required', 'required', 'must', 'needed'], [1], 'Dart 2.12+ uses the required keyword.'),
        q('What does => expr do?', ['Returns void', 'Returns the expression', 'Declares async', 'Creates a class'], [1], 'Arrow syntax returns the expression.'),
    ])

lesson(5, 5, 'Classes',
    concept='Dart classes support constructors, fields, methods, getters/setters, and factory constructors with single inheritance.',
    definition='A class is a blueprint for objects with state (fields) and behavior (methods), supporting encapsulation and inheritance.',
    explanation='Dart classes use this for instance members. Constructors can be generative, named (ClassName.named()), or factory. Getters and setters are first-class. Fields are private when prefixed with _. Dart supports mixins (with) for code reuse across class hierarchies.',
    worked='class Point {\n  final double x, y;\n  const Point(this.x, this.y);\n  double get distanceFromOrigin =>\n      sqrt(x * x + y * y);\n  Point operator +(Point other) =>\n      Point(x + other.x, y + other.y);\n}',
    eng='Flutter widgets are immutable classes; state is managed in separate State classes with mutable fields.',
    mistakes='Using public fields when getters are needed; confusing factory with generative constructors; not using const constructors.',
    practice=['What is a factory constructor?', 'What does the with keyword do?'],
    quiz=[
        q('What does the with keyword enable?', ['Inheritance', 'Mixins', 'Interfaces', 'Generics'], [1], 'with applies mixins.'),
        q('How are private fields marked in Dart?', ['private', '_', 'hidden', '#'], [1], 'Underscore prefix makes library-private.'),
    ])

lesson(5, 6, 'Collections',
    concept='Dart provides List, Set, and Map collection literals with rich methods and collection-if/for syntax.',
    definition='Dart collections are typed data structures: List (ordered), Set (unique), Map (key-value), with literal syntax and functional methods.',
    explanation='List<int> nums = [1, 2, 3]; Set<String> tags = {"a", "b"}; Map<String, int> ages = {"Tommy": 20}. Methods like map(), where(), fold(), and reduce() enable functional transformations. Collection-if and collection-for embed logic in literals. Spread (...) and null-aware spread (...) merge collections.',
    worked='final squares = [for (var i = 0; i < 5; i++) i * i];\nfinal evens = nums.where((n) => n.isEven).toList();\nfinal merged = [...list1, ...list2];',
    eng='Flutter builds widget lists with collection-for: [for (final item in items) ItemWidget(item)].',
    mistakes='Using List when Set fits; not using const for literal collections; modifying unmodifiable lists.',
    practice=['What does collection-if do?', 'When would you use a Set?'],
    quiz=[
        q('Which collection stores unique elements?', ['List', 'Set', 'Map', 'Queue'], [1], 'Set stores unique elements.'),
        q('What does the spread operator (...) do?', ['Copies deeply', 'Expands a collection', 'Sorts', 'Filters'], [1], 'Spread expands elements into a literal.'),
    ])

lesson(5, 7, 'Futures',
    concept='A Future represents a value that will be available later, enabling asynchronous operations without blocking.',
    definition='A Future<T> is a placeholder for a value of type T that completes at some point, either with a value or an error.',
    explanation='Futures model async work: network calls, file I/O, timers. then() chains callbacks; catchError() handles errors; wait() blocks (avoid in UI). Futures complete on the event loop. async/await (next lesson) provides synchronous-style syntax over Futures.',
    worked='Future<String> fetchUser() async {\n  await Future.delayed(Duration(seconds: 1));\n  return "Tommy";\n}\nfetchUser().then(print).catchError(print);',
    eng='Flutter apps fetch API data with Futures, showing loading indicators while waiting and updating UI on completion.',
    mistakes='Blocking the UI with wait(); not handling errors; nesting then() callbacks (use async/await).',
    practice=['What is a Future?', 'How do you handle Future errors?'],
    quiz=[
        q('What does a Future represent?', ['A synchronous value', 'A value available later', 'A stream', 'A widget'], [1], 'Futures complete asynchronously.'),
        q('Which method chains a callback to a Future?', ['then', 'catch', 'wait', 'async'], [0], 'then registers a completion callback.'),
    ])

lesson(5, 8, 'Async/Await',
    concept='async and await provide synchronous-style syntax for asynchronous code, making Futures readable and composable.',
    definition='async marks a function as asynchronous (returning a Future); await pauses execution until a Future completes.',
    explanation='An async function returns a Future immediately. await suspends the function (without blocking the thread) until the awaited Future completes, then resumes. This eliminates callback chains. Errors propagate as Future errors, catchable with try/catch. Multiple awaits run sequentially; Future.wait() runs concurrently.',
    worked='Future<void> loadData() async {\n  try {\n    final user = await fetchUser();\n    final posts = await fetchPosts(user.id);\n    print(posts);\n  } catch (e) {\n    print("Error: $e");\n  }\n}',
    eng='Flutter data loading uses async/await in initState or button handlers, keeping UI responsive during network calls.',
    mistakes='Using await in non-async functions; sequential awaits when concurrent is needed; forgetting try/catch.',
    practice=['What does await do?', 'How do you run Futures concurrently?'],
    quiz=[
        q('What does await do?', ['Blocks the thread', 'Suspends until a Future completes', 'Creates a Future', 'Cancels a Future'], [1], 'await suspends without blocking.'),
        q('Which function runs Futures concurrently?', ['await', 'Future.wait', 'then', 'async'], [1], 'Future.wait runs multiple Futures in parallel.'),
    ])

lesson(5, 9, 'Streams',
    concept='A Stream is a sequence of asynchronous events over time, like Futures that can emit multiple values.',
    definition='A Stream<T> delivers a series of T values or errors over time, with listeners receiving each event.',
    explanation='Streams power event-driven code: user input, WebSocket messages, timers. A StreamSubscription listens; pause(), resume(), and cancel() control flow. Stream transformers (map, where, distinct) process events. Single-subscription streams allow one listener; broadcast streams allow many.',
    worked='final stream = Stream.periodic(\n    Duration(seconds: 1), (i) => i);\nfinal sub = stream.listen(print);\n// Later: sub.cancel();',
    eng='Flutter uses Streams for real-time data: sensor readings, chat messages, and search-as-you-type.',
    mistakes='Not canceling subscriptions (memory leaks); using single-subscription streams for multiple listeners; not handling stream errors.',
    practice=['What is the difference between a Future and a Stream?', 'How do you cancel a Stream subscription?'],
    quiz=[
        q('How many values can a Stream emit?', ['One', 'Multiple', 'None', 'Two'], [1], 'Streams emit sequences of events.'),
        q('What method stops listening to a Stream?', ['stop', 'cancel', 'close', 'pause'], [1], 'subscription.cancel() stops listening.'),
    ])

lesson(5, 10, 'Flutter Widgets',
    concept='Everything in Flutter is a widget — a description of part of the user interface. Widgets compose into trees.',
    definition='A widget is an immutable description of a UI element; Flutter rebuilds the widget tree to reflect state changes.',
    explanation='Widgets are lightweight configuration objects. The widget tree describes the UI; the element tree manages state and lifecycle; the render tree handles layout and painting. StatelessWidget is immutable; StatefulWidget delegates mutable state to a State object. Composition over inheritance builds complex UIs from simple widgets.',
    worked='class Greeting extends StatelessWidget {\n  final String name;\n  const Greeting({super.key, required this.name});\n  @override\n  Widget build(BuildContext context) {\n    return Text("Hello, $name!");\n  }\n}',
    eng='Mobile apps are built by composing widgets: a screen is a Scaffold containing a Column of Text, Image, and Button widgets.',
    mistakes='Creating widgets with heavy logic in build(); not using const constructors; deep widget trees without extraction.',
    practice=['What is the difference between StatelessWidget and StatefulWidget?', 'What does build() return?'],
    quiz=[
        q('What does everything in Flutter consist of?', ['Activities', 'Widgets', 'Views', 'Fragments'], [1], 'Everything is a widget.'),
        q('Which widget holds mutable state?', ['StatelessWidget', 'StatefulWidget', 'Widget', 'Element'], [1], 'StatefulWidget manages state via State.'),
    ])

lesson(5, 11, 'Layouts',
    concept='Flutter layout widgets (Row, Column, Stack, Container, Padding) position and size child widgets within the widget tree.',
    definition='Layout widgets control how child widgets are arranged: Row (horizontal), Column (vertical), Stack (overlapping), and Container (decorated box).',
    explanation='Row and Column use mainAxis (primary direction) and crossAxis (perpendicular) alignment. Expanded and Flexible control space distribution. Stack layers children with Positioned. Container combines padding, margin, decoration, and constraints. Layout is constrained top-down: parents pass constraints, children choose sizes.',
    worked='Column(\n  mainAxisAlignment: MainAxisAlignment.center,\n  children: [\n    Text("Title"),\n    SizedBox(height: 16),\n    ElevatedButton(\n      onPressed: () {},\n      child: Text("Press"),\n    ),\n  ],\n)',
    eng='Responsive UIs combine Row/Column with Expanded and MediaQuery to adapt layouts to screen sizes.',
    mistakes='Unbounded height in Column inside Row; not using Expanded for flexible space; fixed sizes that overflow.',
    practice=['What is the difference between Expanded and Flexible?', 'How does Stack position children?'],
    quiz=[
      q('Which widget arranges children horizontally?', ['Column', 'Row', 'Stack', 'Container'], [1], 'Row is horizontal.'),
        q('What does Expanded do?', ['Adds padding', 'Fills remaining space', 'Centers content', 'Scrolls'], [1], 'Expanded fills available space.'),
    ])

lesson(5, 12, 'Navigation',
    concept='Flutter navigation uses a Navigator with a stack of routes: push to navigate, pop to return, named routes for structure.',
    definition='Navigation in Flutter manages a stack of screens (routes) with push, pop, and named-route APIs.',
    explanation='Navigator.push() adds a route to the stack; Navigator.pop() removes it. MaterialPageRoute provides platform-appropriate transitions. Named routes (routes: {}) map names to screens for deep linking. go_router and Navigator 2.0 offer declarative navigation for complex apps.',
    worked='Navigator.push(\n  context,\n  MaterialPageRoute(\n    builder: (_) => DetailScreen(id: 42),\n  ),\n);\n// Back: Navigator.pop(context);',
    eng='Multi-screen apps (list → detail → edit) use Navigator stacks; deep links map URLs to named routes.',
    mistakes='Not popping routes (stack leaks); passing large objects through routes (use IDs); ignoring back-button behavior.',
    practice=['What does Navigator.pop() do?', 'What is a named route?'],
    quiz=[
        q('What does Navigator.push() do?', ['Removes a screen', 'Adds a screen to the stack', 'Replaces all screens', 'Exits the app'], [1], 'push adds a route.'),
        q('Which package offers declarative routing?', ['http', 'go_router', 'provider', 'riverpod'], [1], 'go_router is declarative.'),
    ])

lesson(5, 13, 'State Management',
    concept='State management solutions (setState, Provider, Riverpod, Bloc) handle data that changes over time and must update the UI.',
    definition='State management is the pattern for storing, updating, and distributing mutable data across a Flutter app.',
    explanation='setState works for local widget state. Provider and Riverpod use InheritedWidget to expose app-wide state. Bloc separates business logic from UI with streams. Riverpod (used in this app) offers compile-safe, testable providers with automatic disposal. Choose based on app complexity.',
    worked='// Riverpod example\nfinal counterProvider = StateNotifierProvider<Counter, int>(\n  (ref) => Counter(),\n);\nclass Counter extends StateNotifier<int> {\n  Counter() : super(0);\n  void increment() => state++;\n}',
    eng='Production apps use Riverpod/Bloc for predictable state: user auth, cached data, and UI state survive widget rebuilds.',
    mistakes='Using setState for app-wide state; not disposing controllers; over-engineering simple state.',
    practice=['When is setState sufficient?', 'What problem does Riverpod solve?'],
    quiz=[
        q('Which is best for local widget state?', ['Bloc', 'setState', 'Riverpod', 'Redux'], [1], 'setState suits local state.'),
        q('What does Riverpod provide?', ['Compile-safe providers', 'Database access', 'Networking', 'Animations'], [0], 'Riverpod offers compile-safe dependency injection.'),
    ])

lesson(5, 14, 'Forms',
    concept='Flutter forms use TextFormField with controllers and validation to collect and verify user input.',
    definition='A form collects user input through text fields, with validation ensuring data meets requirements before submission.',
    explanation='Form widgets group fields with a GlobalKey<FormState>. TextFormField provides decoration, keyboard types, and validator functions. Controllers (TextEditingController) read and set field values. onSaved collects valid data. AutovalidateMode controls when validation runs.',
    worked='final _formKey = GlobalKey<FormState>();\nForm(\n  key: _formKey,\n  child: Column(children: [\n    TextFormField(\n      decoration: InputDecoration(labelText: "Email"),\n      validator: (v) => v!.contains("@") ? null : "Invalid email",\n    ),\n  ]),\n)',
    eng='Login and settings screens use forms with validation to ensure correct email formats and required fields.',
    mistakes='Not validating input; not disposing controllers; reading controllers after dispose.',
    practice=['What does a validator return for valid input?', 'How do you read a text field\'s value?'],
    quiz=[
        q('What does a validator return when input is valid?', ['true', 'null', 'false', 'empty string'], [1], 'null means valid.'),
        q('Which widget groups form fields?', ['Column', 'Form', 'Container', 'Scaffold'], [1], 'Form manages field state.'),
    ])

lesson(5, 15, 'Local Storage',
    concept='Flutter local storage options include SharedPreferences (key-value), sqflite (SQLite), and path_provider (file paths).',
    definition='Local storage persists data on device: SharedPreferences for simple values, sqflite for relational data, files for blobs.',
    explanation='SharedPreferences stores primitives (String, int, bool, double, List<String>) asynchronously. sqflite provides full SQLite for structured data with queries and transactions. path_provider gives app directories. Hive and Isar offer NoSQL alternatives. Choose by data complexity.',
    worked='final prefs = await SharedPreferences.getInstance();\nprefs.setString("username", "Tommy");\nfinal name = prefs.getString("username");',
    eng='This app uses sqflite for notes, bookmarks, and progress, and SharedPreferences for theme and profile settings.',
    mistakes='Storing large data in SharedPreferences; not handling async initialization; not closing databases.',
    practice=['When would you use sqflite over SharedPreferences?', 'What does path_provider provide?'],
    quiz=[
        q('Which stores key-value primitives?', ['sqflite', 'SharedPreferences', 'Hive', 'File'], [1], 'SharedPreferences stores simple values.'),
        q('Which provides full SQLite in Flutter?', ['shared_preferences', 'sqflite', 'path_provider', 'hive'], [1], 'sqflite wraps SQLite.'),
    ])

lesson(5, 16, 'Flutter Architecture',
    concept='Flutter architecture separates concerns: UI (widgets), state (providers), services (logic), and data (repositories).',
    definition='Flutter architecture organizes code into layers: presentation, business logic, and data, with dependencies flowing inward.',
    explanation='Clean architecture in Flutter: widgets (UI) depend on providers (state), which depend on services (domain logic), which depend on repositories (data). This separation makes code testable, maintainable, and swappable. This app follows this pattern with Riverpod providers between UI and services.',
    worked='// Layer flow\nWidget → Provider → Service → Repository → SQLite\n// UI never touches SQLite directly',
    eng='Production Flutter apps enforce layer boundaries so UI changes don\'t affect business logic and data sources can be swapped.',
    mistakes='Putting SQL in widgets; business logic in build(); circular dependencies between layers.',
    practice=['Why separate UI from data layers?', 'What role do providers play?'],
    quiz=[
        q('Which layer do widgets belong to?', ['Data', 'Presentation', 'Domain', 'Repository'], [1], 'Widgets are presentation.'),
        q('What is the benefit of layered architecture?', ['Faster compilation', 'Testability and maintainability', 'Smaller apps', 'Less code'], [1], 'Layers enable testing and swapping.'),
    ])

formula('Programming', 'Dart Null Safety', 'T? = T | null', 'T: any type', 'Null-safe type system')
formula('Programming', 'Flutter Widget Tree', 'UI = f(state)', 'UI: rendered interface; state: data', 'Declarative UI framework')

reference('Dart', 'Basics', 'Hello World', 'void main() {\n  print("Hello, World!");\n\n  var name = "Tommy";\n  var age = 20;\n  print("$name is $age years old");\n}')
reference('Dart', 'Variables', 'Variable Types', 'void main() {\n  var count = 10;        // int\n  double price = 9.99;\n  String name = "Tommy";\n  bool isValid = true;\n  final pi = 3.14159;\n  const maxRetries = 3;\n\n  print("$count, $price, $name, $isValid");\n}')
reference('Dart', 'Functions', 'Function Definition', 'int add(int a, int b) => a + b;\n\nvoid greet({required String name, String greeting = "Hello"}) {\n  print("$greeting, $name!");\n}\n\nvoid main() {\n  print(add(3, 4));\n  greet(name: "Tommy");\n}')
reference('Dart', 'Classes', 'Class Definition', 'class Point {\n  final double x, y;\n\n  const Point(this.x, this.y);\n\n  double get distanceFromOrigin =>\n      sqrt(x * x + y * y);\n\n  Point operator +(Point other) =>\n      Point(x + other.x, y + other.y);\n}\n\nvoid main() {\n  final p = Point(3, 4);\n  print(p.distanceFromOrigin);  // 5.0\n}')
reference('Dart', 'Async', 'Async/Await', 'Future<String> fetchUser() async {\n  await Future.delayed(Duration(seconds: 1));\n  return "Tommy";\n}\n\nvoid main() async {\n  try {\n    final user = await fetchUser();\n    print(user);\n  } catch (e) {\n    print("Error: $e");\n  }\n}')
reference('Flutter', 'Widgets', 'Stateless Widget', 'import \'package:flutter/material.dart\';\n\nclass Greeting extends StatelessWidget {\n  final String name;\n\n  const Greeting({super.key, required this.name});\n\n  @override\n  Widget build(BuildContext context) {\n    return Text(\n      "Hello, $name!",\n      style: Theme.of(context).textTheme.headlineMedium,\n    );\n  }\n}')
reference('Flutter', 'Layouts', 'Column and Row', 'import \'package:flutter/material.dart\';\n\nclass LayoutDemo extends StatelessWidget {\n  const LayoutDemo({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return Column(\n      mainAxisAlignment: MainAxisAlignment.center,\n      children: [\n        Row(\n          mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n          children: [\n            Icon(Icons.star),\n            Icon(Icons.favorite),\n          ],\n        ),\n        SizedBox(height: 16),\n        Text("Flutter Layout"),\n      ],\n    );\n  }\n}')
reference('Flutter', 'State', 'Stateful Widget', 'import \'package:flutter/material.dart\';\n\nclass Counter extends StatefulWidget {\n  const Counter({super.key});\n\n  @override\n  State<Counter> createState() => _CounterState();\n}\n\nclass _CounterState extends State<Counter> {\n  int count = 0;\n\n  @override\n  Widget build(BuildContext context) {\n    return Column(\n      children: [\n        Text("Count: $count"),\n        ElevatedButton(\n          onPressed: () => setState(() => count++),\n          child: Text("Increment"),\n        ),\n      ],\n    );\n  }\n}')
reference('Flutter', 'Navigation', 'Push and Pop', 'import \'package:flutter/material.dart\';\n\n// Navigate to detail\nNavigator.push(\n  context,\n  MaterialPageRoute(\n    builder: (_) => DetailScreen(id: 42),\n  ),\n);\n\n// Go back\nNavigator.pop(context);')
