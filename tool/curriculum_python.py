"""Python and Java curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(3, 'Python', 'Programming',
        'Syntax • Data Structures • OOP • NumPy', 'terminal')
subject(4, 'Java', 'Programming',
        'OOP • Collections • Exceptions • JVM', 'code')

# ---------------- Python (20 lessons) ----------------

lesson(3, 1, 'Python Basics',
    concept='Python is a high-level, interpreted, dynamically-typed language emphasizing readability with significant whitespace and simple syntax.',
    definition='Python is a general-purpose programming language code with automatic memory management and a large standard library.',
    explanation='Python code is executed line-by-line by the interpreter rather than compiled to machine code. Indentation defines code blocks instead of braces. Variables are created on first assignment without type declarations. This makes Python concise and fast to write.',
    worked='name = "Tommy"   # no type declaration\nage = 20\nprint(f"{name} is {age} years old")\n# Python infers types at runtime',
    eng='Python dominates data science, machine learning, and automation scripting in engineering workflows, from test automation to data analysis.',
    mistakes='Mixing tabs and spaces for indentation; assuming Python is compiled; mutating default arguments (def f(x=[])).',
    practice=['Why is Python called interpreted?', 'How does Python define code blocks?'],
    quiz=[
        q('How does Python delimit code blocks?', ['Curly braces', 'Indentation', 'begin/end', 'Parentheses'], [1], 'Python uses significant whitespace.'),
        q('Is Python statically or dynamically typed?', ['Static', 'Dynamic', 'Both', 'Neither'], [1], 'Python infers types at runtime.'),
    ])

lesson(3, 2, 'Variables',
    concept='Python variables are dynamically-typed names bound to objects. Assignment creates a reference to an object in memory.',
    definition='A Python variable is a name that references an object; the variable itself has no fixed type.',
    explanation='When you write x = 42, Python creates an int object and binds the name x to it. Reassigning x = "hello" rebinds it to a str object. Multiple names can reference the same object. Python uses reference counting and garbage collection for memory management.',
    worked='x = 10        # x references int 10\ny = x         # y references the same object\nx = "hello"   # x now references a str; y is still 10\nprint(y)      # 10',
    eng='Data analysis scripts hold datasets in variable names like df (DataFrame), making exploratory code readable and concise.',
    mistakes='Assuming variables store values directly (they store references); using mutable default arguments; confusing == with is.',
    practice=['What does a Python variable reference?', 'What is the difference between == and is?'],
    quiz=[
        q('What does a Python variable reference?', ['A memory address/object', 'A fixed value', 'A type', 'A pointer only'], [0], 'Variables are names bound to objects.'),
        q('What does "is" compare?', ['Values', 'Object identity', 'Types', 'Lengths'], [1], 'is checks whether two names reference the same object.'),
    ])

lesson(3, 3, 'Data Types',
    concept='Python built-in types include int, float, str, bool, list, tuple, dict, and set — each with distinct properties and methods.',
    definition='Built-in data types are the fundamental objects Python provides for storing and manipulating data.',
    explanation='int and float are numeric; str is immutable text; bool is True/False. list is a mutable ordered sequence; tuple is an immutable sequence; dict stores key-value mappings; set stores unique unordered elements. Choosing the right type affects performance and correctness.',
    worked='numbers = [1, 2, 3]        # list (mutable)\npoint = (4, 5)            # tuple (immutable)\nages = {"Tommy": 20}       # dict\nunique = {1, 2, 3, 3}    # set → {1, 2, 3}',
    eng='Engineering configs use dicts for settings, sets for deduplication of sensor IDs, and tuples for fixed coordinate data.',
    mistakes='Using a list when immutability is needed (list is mutable); modifying a dict while iterating; using mutable objects as dict keys.',
    practice=['What is the difference between a list and a tuple?', 'When would you use a set?'],
    quiz=[
        q('Which type is immutable?', ['list', 'tuple', 'dict', 'set'], [1], 'Tuples cannot be modified after creation.'),
        q('Which type stores key-value pairs?', ['list', 'set', 'dict', 'tuple'], [2], 'dict stores key-value mappings.'),
    ])

lesson(3, 4, 'Operators',
    concept='Python operators include arithmetic (+, -, *, /, //, %, **), comparison (==, !=, <, >), logical (and, or, not), and membership (in).',
    definition='Operators perform operations on values, with / performing true division, // floor division, and ** exponentiation.',
    explanation='Unlike C, Python\'s / always returns a float (true division), while // returns the floor of division. % is modulo. ** raises to a power. Logical operators are words (and, or, not) rather than symbols. The in operator checks membership in sequences.',
    worked='7 / 2    # 3.5 (true division)\n7 // 2   # 3 (floor division)\n2 ** 3   # 8 (exponent)\n5 in [1, 3, 5]  # True',
    eng='Scientific computing uses ** for powers of ten (1e6 vs 10**6) and // for integer binning of measurement ranges.',
    mistakes='Confusing / with //; using = instead of ==; expecting && instead of and.',
    practice=['What is 7 // 2?', 'What does ** do?'],
    quiz=[
        q('What does 7 / 2 return in Python 3?', ['3', '3.5', '4', '3.0 as int'], [1], 'Python 3 true division returns a float.'),
        q('Which operator checks membership?', ['has', 'in', 'contains', 'member'], [1], 'in checks membership in sequences.'),
    ])

lesson(3, 5, 'Conditions',
    concept='if, elif, and else control execution flow based on boolean conditions, with indentation defining blocks.',
    definition='Conditional statements execute code blocks only when their conditions evaluate to True.',
    explanation='Python evaluates conditions top-down: the first True condition runs its block and skips the rest. elif chains additional conditions. else catches everything else. Conditions can combine with and, or, not. Python treats non-zero numbers, non-empty sequences, and non-None values as truthy.',
    worked='temperature = 85\nif temperature > 90:\n    print("Hot")\nelif temperature > 70:\n    print("Warm")   # this runs\nelse:\n    print("Cool")',
    eng='Control systems use conditionals to trigger actions: if temperature > threshold: activate_cooler().',
    mistakes='Using = instead of ==; relying on truthiness unexpectedly; forgetting the colon after conditions.',
    practice=['What is the difference between if and elif?', 'What values are falsy in Python?'],
    quiz=[
        q('What is falsy in Python?', ['1', '0', '"hello"', '[1, 2]'], [1], '0, empty sequences, None, and False are falsy.'),
        q('How many elif clauses can an if statement have?', ['One', 'Two', 'Unlimited', 'None'], [2], 'elif chains are unlimited.'),
    ])

lesson(3, 6, 'Loops',
    concept='Python for loops iterate over sequences; while loops repeat while a condition holds. break, continue, and else refine loop control.',
    definition='Loops repeatedly execute a block: for iterates over iterable objects, while repeats on a condition.',
    explanation='Python\'s for loop iterates directly over items (for item in sequence), not indices. range(n) generates index sequences. while loops check a condition before each iteration. break exits, continue skips to the next iteration, and a loop\'s else runs only if the loop completed without break.',
    worked='for i in range(5):\n    print(i)        # 0 1 2 3 4\nfor name in ["Ada", "Grace"]:\n    print(name)',
    eng='Data pipelines loop over rows in a dataset, applying transformations to each record with for loops.',
    mistakes='Modifying a list while iterating over it; infinite while loops; using range(len(x)) when direct iteration works.',
    practice=['What does range(5) produce?', 'When does a loop\'s else clause run?'],
    quiz=[
        q('What does range(3) produce?', ['[1,2,3]', '[0,1,2]', '[0,1,2,3]', '[1,2]'], [1], 'range(3) yields 0, 1, 2.'),
        q('When does a for loop\'s else run?', ['Always', 'Only if no break occurred', 'Only if break occurred', 'Never'], [1], 'else runs when the loop completes normally.'),
    ])

lesson(3, 7, 'Functions',
    concept='Python functions are defined with def, support default arguments, *args, **kwargs, and can return multiple values as tuples.',
    definition='A function is a reusable block defined with def that accepts parameters and returns values.',
    explanation='Functions are first-class objects in Python — they can be assigned, passed, and returned. Default arguments are evaluated once (avoid mutable defaults). *args collects extra positional arguments; **kwargs collects keyword arguments. Functions without return give None.',
    worked='def greet(name, greeting="Hello"):\n    return f"{greeting}, {name}!"\n\ngreet("Tommy")              # "Hello, Tommy!"\ngreet("Ada", greeting="Hi")  # "Hi, Ada!"',
    eng='Engineering libraries wrap complex math in functions like calculate_stress(force, area) for reuse across analyses.',
    mistakes='Mutable default arguments; shadowing built-in names; not using return when a value is needed.',
    practice=['What are *args and **kwargs?', 'Why are mutable defaults dangerous?'],
    quiz=[
        q('What does a function return if there is no return statement?', ['0', 'None', 'An error', 'Empty string'], [1], 'Functions without return yield None.'),
        q('What does **kwargs collect?', ['Positional args', 'Keyword arguments', 'Return values', 'Exceptions'], [1], '**kwargs collects extra keyword arguments.'),
    ])

lesson(3, 8, 'Lists',
    concept='A list is a mutable, ordered sequence supporting indexing, slicing, appending, and comprehension syntax.',
    definition='A list is a dynamic array of ordered, mutable elements that can hold mixed types.',
    explanation='Lists support O(1) amortized append, O(n) insertion/deletion in the middle, and O(1) indexing. Slicing (list[start:stop:step]) extracts sublists. List comprehensions ([x*2 for x in items]) provide a concise transformation syntax. Lists are the most common Python sequence.',
    worked='temps = [20, 22, 21]\ntemps.append(23)          # add to end\nhot = [t for t in temps if t > 21]  # [22, 21, 23]\navg = sum(temps) / len(temps)',
    eng='Sensor data logging uses lists to accumulate readings, then comprehensions to filter outliers before analysis.',
    mistakes='Copying lists with = (creates alias, not copy); modifying while iterating; using list as dict key.',
    practice=['How do you create a true copy of a list?', 'What does a list comprehension do?'],
    quiz=[
        q('How do you copy a list independently?', ['y = x', 'y = x.copy()', 'y = x[]', 'copy is automatic'], [1], 'Assignment aliases; copy() creates a new list.'),
        q('What is [x for x in range(3)]?', ['[1,2,3]', '[0,1,2]', '[0,1,2,3]', 'Error'], [1], 'The comprehension builds [0, 1, 2].'),
    ])

lesson(3, 9, 'Tuples',
    concept='A tuple is an immutable, ordered sequence — faster than lists and safe as dict keys and set members.',
    definition='A tuple is an immutable sequence of elements, created with parentheses or commas.',
    explanation='Once created, tuples cannot be modified. This immutability makes them hashable (usable as dict keys) and slightly faster than lists. Tuples are used for fixed collections like coordinates, database rows, and multiple return values. The tuple() constructor converts other sequences.',
    worked='point = (3, 7)\nx, y = point          # unpacking\npoint[0] = 5         # TypeError: immutable\ndef minmax(items):\n    return min(items), max(items)  # returns tuple',
    eng='Database query results return tuples; GPS coordinates are stored as (latitude, longitude) tuples.',
    mistakes='Trying to modify a tuple; using tuples for heterogeneous data that needs methods (use a class); single-element tuple needs trailing comma (x,).',
    practice=['Why are tuples faster than lists?', 'How do you create a single-element tuple?'],
    quiz=[
        q('Can a tuple be modified after creation?', ['Yes', 'No', 'Only first element', 'Only with methods'], [1], 'Tuples are immutable.'),
        q('How do you write a single-element tuple?', ['(1)', '(1,)', '[1]', '1,'], [1], 'The trailing comma makes it a tuple.'),
    ])

lesson(3, 10, 'Dictionaries',
    concept='A dict stores key-value pairs with O(1) average lookup, insertion, and deletion via hashing.',
    definition='A dictionary is a mutable mapping of unique keys to values, implemented as a hash table.',
    explanation='Keys must be hashable (immutable types like str, int, tuple). Values can be any type. dict provides get() with defaults, items() for iteration, and comprehensions. Python 3.7+ preserves insertion order. dicts are the workhorse for counting, grouping, and configuration.',
    worked='counts = {"a": 3, "b": 1}\ncounts["c"] = counts.get("c", 0) + 1\nfor key, value in counts.items():\n    print(key, value)',
    eng='Word frequency analysis, JSON parsing, and configuration management all rely on dictionaries.',
    mistakes='Using mutable keys; assuming pre-3.7 dicts are ordered; using [] to check existence (use in or get).',
    practice=['What makes a type hashable?', 'How do you safely increment a count in a dict?'],
    quiz=[
        q('Which can be a dict key?', ['list', 'dict', 'str', 'set'], [2], 'Only hashable (immutable) types can be keys.'),
        q('What is the average lookup time of a dict?', ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'], [1], 'Hash tables give constant-time lookup.'),
    ])

lesson(3, 11, 'Sets',
    concept='A set is an unordered collection of unique elements supporting fast membership tests and mathematical set operations.',
    definition='A set is a mutable, unordered collection of hashable unique elements.',
    explanation='Sets automatically deduplicate. Membership testing (x in s) is O(1). Sets support union (|), intersection (&), difference (-), and symmetric difference (^). frozenset is the immutable, hashable variant. Sets are ideal for deduplication and membership filtering.',
    worked='a = {1, 2, 3, 3}        # {1, 2, 3}\nb = {2, 3, 4}\na & b   # {2, 3} intersection\na | b   # {1, 2, 3, 4} union\n5 in a  # False, O(1)',
    eng='Deduplicating sensor IDs, finding common elements between datasets, and filtering seen items use sets.',
    mistakes='Expecting order from sets; storing unhashable items; using sets for indexed access.',
    practice=['What is the difference between a set and a frozenset?', 'When is a set better than a list?'],
    quiz=[
        q('Are set elements ordered?', ['Yes', 'No', 'Only numbers', 'Only strings'], [1], 'Sets are unordered.'),
        q('Which operation finds common elements?', ['|', '&', '-', '^'], [1], '& is intersection.'),
    ])

lesson(3, 12, 'Strings',
    concept='Python strings are immutable Unicode sequences with rich methods for searching, splitting, joining, and formatting.',
    definition='A string is an immutable sequence of Unicode characters with methods for manipulation and formatting.',
    explanation='Strings support indexing, slicing, and iteration. Methods like split(), join(), strip(), replace(), startswith(), and find() handle common tasks. f-strings (f"...") embed expressions directly. Immutability means methods return new strings rather than modifying in place.',
    worked='text = "  Hello, World!  "\ntext.strip()          # "Hello, World!"\n"a,b,c".split(",")  # ["a", "b", "c"]\nf"Value: {3.14159:.2f}"  # "Value: 3.14"',
    eng='Log parsing uses split() and find() to extract fields; f-strings format report output.',
    mistakes='Expecting string methods to modify in place; concatenating in loops with + (use join); confusing find() (-1) with index() (exception).',
    practice=['How do you join a list of strings?', 'What does find() return when not found?'],
    quiz=[
        q('Are Python strings mutable?', ['Yes', 'No', 'Only with methods', 'Only ASCII'], [1], 'Strings are immutable.'),
        q('What does "a,b".split(",") return?', ['"a,b"', '["a", "b"]', '("a","b")', 'Error'], [1], 'split returns a list of substrings.'),
    ])

lesson(3, 13, 'Classes',
    concept='Python classes bundle data and behavior with methods, attributes, and special methods like __init__ and __str__.',
    definition='A class is a blueprint for objects, defining attributes (data) and methods (behavior) with self as the instance reference.',
    explanation='__init__ is the constructor, called on creation. self refers to the instance. Instance attributes are set in __init__. Special (dunder) methods customize behavior: __str__ for printing, __eq__ for comparison, __len__ for len(). Class attributes are shared; instance attributes are per-object.',
    worked='class Circle:\n    def __init__(self, radius):\n        self.radius = radius\n    def area(self):\n        return 3.14159 * self.radius ** 2\n\nc = Circle(5)\nprint(c.area())  # 78.54',
    eng='Engineering models define classes like Resistor with attributes (resistance, tolerance) and methods (current(voltage)).',
    mistakes='Forgetting self in method definitions; confusing class and instance attributes; not calling super().__init__() in inheritance.',
    practice=['What is self?', 'What does __init__ do?'],
    quiz=[
        q('What does self refer to in a method?', ['The class', 'The instance', 'A static value', 'The module'], [1], 'self is the instance the method is called on.'),
        q('Which method is the constructor?', ['__main__', '__init__', '__new__ only', '__class__'], [1], '__init__ initializes new instances.'),
    ])

lesson(3, 14, 'Exceptions',
    concept='Python exceptions handle errors with try/except/else/finally, allowing graceful recovery from failures.',
    definition='Exception handling catches and responds to runtime errors using try blocks and except clauses.',
    explanation='Code that might fail goes in try. except catches specific exception types (catch broadly with care). else runs if no exception occurred. finally always runs (for cleanup). raise throws exceptions. Custom exceptions derive from Exception.',
    worked='try:\n    result = 10 / 0\nexcept ZeroDivisionError:\n    result = float("inf")\nfinally:\n    print("Done")  # always runs',
    eng='Data pipelines catch parsing exceptions to skip corrupt records and continue processing valid data.',
    mistakes='Bare except: (catches everything including KeyboardInterrupt); swallowing exceptions silently; raising inside except without context.',
    practice=['When does finally run?', 'Why catch specific exceptions?'],
    quiz=[
        q('When does the finally block run?', ['Only on success', 'Only on error', 'Always', 'Never'], [2], 'finally always executes.'),
        q('What does a bare except: clause catch?', ['Nothing', 'All exceptions including system ones', 'Only SyntaxError', 'Only ValueError'], [1], 'Bare except catches everything.'),
    ])

lesson(3, 15, 'File Handling',
    concept='Python file handling uses open() with context managers (with statement) for safe, automatic resource cleanup.',
    definition='File I/O reads and writes files using file objects, with the with statement ensuring files close automatically.',
    explanation='open(path, mode) returns a file object. Modes: "r" read, "w" write (truncates), "a" append, "b" binary. The with statement closes the file even if exceptions occur. read(), readline(), readlines(), write(), and writelines() perform I/O. Path objects from pathlib offer modern path handling.',
    worked='with open("data.txt", "w") as f:\n    f.write("Temperature: 23.5\\n")\n# file automatically closed here\nwith open("data.txt") as f:\n    content = f.read()',
    eng='Data loggers write CSV/JSON files with the with statement, guaranteeing data is flushed even on errors.',
    mistakes='Forgetting to close files (use with); opening in "w" when appending; not handling encoding (specify encoding="utf-8").',
    practice=['Why use the with statement for files?', 'What does mode "a" do?'],
    quiz=[
        q('What does the with statement guarantee?', ['Faster I/O', 'Automatic file closing', 'Binary mode', 'Error handling'], [1], 'with ensures files close.'),
        q('Which mode appends to a file?', ['"r"', '"w"', '"a"', '"x"'], [2], '"a" opens for appending.'),
    ])

lesson(3, 16, 'Modules',
    concept='Python modules are .py files organizing code into reusable units; packages are directories of modules with __init__.py.',
    definition='A module is a file of Python code; importing makes its functions, classes, and variables available.',
    explanation='import module brings in the whole module; from module import name brings specific items. The standard library provides modules for math, os, json, datetime, re, and more. Third-party packages install via pip. __name__ == "__main__" guards code that should only run when executed directly.',
    worked='import math\nmath.sqrt(16)  # 4.0\n\nfrom datetime import datetime\ndatetime.now()\n\nimport json\ndata = json.loads(\'{"key": "value"}\')',
    eng='Engineering scripts import numpy for computation, json for config, and os for file paths — composing modules into tools.',
    mistakes='Circular imports; shadowing standard library modules with your own files; not using virtual environments.',
    practice=['What is the difference between import and from...import?', 'What does if __name__ == "__main__" do?'],
    quiz=[
        q('What is a Python module?', ['A function', 'A .py file of code', 'A class', 'A package'], [1], 'Modules are code files.'),
        q('Which tool installs third-party packages?', ['import', 'pip', 'module', 'package'], [1], 'pip installs packages.'),
    ])

lesson(3, 17, 'Virtual Environments',
    concept='Virtual environments isolate project dependencies, preventing version conflicts between projects.',
    definition='A virtual environment is an isolated Python installation with its own packages, independent of the system Python.',
    explanation='python -m venv myenv creates an environment. Activating it (source myenv/bin/activate on Unix) makes pip install packages locally. This prevents conflicts: project A can use numpy 1.x while project B uses numpy 2.x. requirements.txt records dependencies for reproduction.',
    worked='python -m venv .venv\nsource .venv/bin/activate\npip install numpy\npip freeze > requirements.txt  # record deps',
    eng='Lab computers maintain separate environments for each experiment\'s analysis code, ensuring reproducible results.',
    mistakes='Committing .venv to version control; installing packages globally; not using requirements.txt.',
    practice=['Why use virtual environments?', 'What does pip freeze do?'],
    quiz=[
        q('What creates a virtual environment?', ['python -m venv', 'pip install', 'import env', 'python --isolated'], [0], 'python -m venv creates environments.'),
        q('What does requirements.txt contain?', ['Source code', 'List of dependencies', 'Documentation', 'Tests'], [1], 'It records installed packages.'),
    ])

lesson(3, 18, 'Python for Engineering',
    concept='Python is widely used in engineering for numerical computing, data analysis, automation, and prototyping with libraries like NumPy, SciPy, and Matplotlib.',
    definition='Python for engineering applies the language to technical computation, simulation, and data visualization tasks.',
    explanation='NumPy provides fast array operations; SciPy adds scientific algorithms (integration, optimization, signal processing); Matplotlib creates plots; Pandas handles tabular data. Python\'s readability and library ecosystem make it ideal for rapid prototyping of engineering analyses.',
    worked='import numpy as np\nimport matplotlib.pyplot as plt\n\nt = np.linspace(0, 10, 100)\ny = np.sin(t)\nplt.plot(t, y)\nplt.title("Sine Wave")\nplt.show()',
    eng='Vibration analysis uses NumPy FFT on accelerometer data; control design uses SciPy; results are plotted with Matplotlib.',
    mistakes='Using Python loops over NumPy arrays (vectorize instead); not handling units; ignoring array broadcasting rules.',
    practice=['What does NumPy provide?', 'Why is Python popular in engineering?'],
    quiz=[
        q('Which library provides fast array operations?', ['NumPy', 'os', 'json', 're'], [0], 'NumPy provides n-dimensional arrays.'),
        q('Which library creates plots?', ['SciPy', 'Matplotlib', 'Pandas', 'NumPy'], [1], 'Matplotlib creates visualizations.'),
    ])

lesson(3, 19, 'NumPy Basics',
    concept='NumPy provides the ndarray — a fast, homogeneous, multidimensional array with vectorized operations and broadcasting.',
    definition='NumPy (Numerical Python) is a library for efficient numerical computation on arrays of uniform type.',
    explanation='ndarrays are contiguous, typed, and support element-wise operations without Python loops (vectorization). Broadcasting applies operations across arrays of different shapes. NumPy underpins nearly all scientific Python. Key functions: array(), zeros(), ones(), arange(), linspace(), and mathematical ufuncs.',
    worked='import numpy as np\na = np.array([1, 2, 3])\nb = np.array([4, 5, 6])\na + b        # [5, 7, 9] element-wise\na * 2        # [2, 4, 6] scalar broadcast\nnp.dot(a, b) # 32',
    eng='Finite element analysis, signal processing, and machine learning all build on NumPy arrays for performance.',
    mistakes='Mixing lists and arrays unexpectedly; assuming * is matrix multiplication (use @); not understanding broadcasting.',
    practice=['What is vectorization?', 'What does broadcasting do?'],
    quiz=[
        q('What is a NumPy ndarray?', ['A list', 'A typed multidimensional array', 'A dict', 'A string'], [1], 'ndarrays are typed, contiguous arrays.'),
        q('Which operator performs matrix multiplication in NumPy?', ['*', '@', '**', 'x'], [1], '@ is matrix multiplication.'),
    ])

lesson(3, 20, 'Data Processing',
    concept='Data processing in Python transforms raw data into insights using filtering, aggregation, grouping, and visualization.',
    definition='Data processing is the pipeline of cleaning, transforming, and analyzing data to extract useful information.',
    explanation='A typical pipeline: load data (CSV/JSON), clean (handle missing values, remove duplicates), transform (normalize, compute features), analyze (statistics, aggregation), and visualize (plots). Pandas DataFrames excel at tabular processing; NumPy handles numerical arrays.',
    worked='import pandas as pd\ndf = pd.read_csv("sensors.csv")\ndf = df.dropna()                    # clean\ndf["temp_c"] = (df["temp_f"] - 32) * 5/9  # transform\nsummary = df.describe()           # analyze',
    eng='Test engineers process thousands of sensor readings: clean outliers, compute statistics, and plot trends to validate designs.',
    mistakes='Not handling missing values; modifying DataFrames without copies; ignoring data types on load.',
    practice=['What is a DataFrame?', 'Why clean data before analysis?'],
    quiz=[
        q('Which library handles tabular data?', ['NumPy', 'Pandas', 'Matplotlib', 'json'], [1], 'Pandas provides DataFrames.'),
        q('What does dropna() do?', ['Fills zeros', 'Removes missing values', 'Sorts data', 'Duplicates rows'], [1], 'dropna removes rows with missing values.'),
    ])

# ---------------- Java (16 lessons) ----------------

lesson(4, 1, 'Java Basics',
    concept='Java is a compiled, object-oriented, platform-independent language running on the Java Virtual Machine (JVM).',
    definition='Java is a statically-typed, class-based language compiled to bytecode that runs on any device with a JVM.',
    explanation='Java source compiles to bytecode (.class files), which the JVM interprets or JIT-compiles to machine code. "Write once, run anywhere" comes from the JVM abstracting the hardware. Java enforces OOP: everything lives in classes. It is strongly typed with automatic garbage collection.',
    worked='public class Hello {\n    public static void main(String[] args) {\n        System.out.println("Hello, Java!");\n    }\n}\n// Compile: javac Hello.java  →  Run: java Hello',
    eng='Android apps, enterprise backends, and embedded systems (Java Card) run on Java\'s portable, managed runtime.',
    mistakes='Confusing Java with JavaScript; expecting C-style pointers; not understanding the JVM.',
    practice=['What is bytecode?', 'What does the JVM do?'],
    quiz=[
        q('Java code is compiled to:', ['Machine code', 'Bytecode', 'Source code', 'Assembly'], [1], 'Java compiles to JVM bytecode.'),
        q('What does JVM stand for?', ['Java Variable Machine', 'Java Virtual Machine', 'Java Verified Module', 'Java Visual Mode'], [1], 'JVM is the Java Virtual Machine.'),
    ])

lesson(4, 2, 'Variables',
    concept='Java variables are statically typed with primitive types (int, double, char, boolean) and reference types (objects, arrays).',
    definition='A Java variable is a named, typed storage location declared with a specific type that cannot change.',
    explanation='Primitive types store values directly (int, double, char, boolean, etc.). Reference types store addresses of objects. Java requires explicit type declaration. Variables have scope (local, instance, static) and must be initialized before use. final makes variables constant.',
    worked='int age = 20;              // primitive\ndouble gpa = 3.85;\nfinal int MAX = 100;     // constant\nString name = "Tommy";   // reference type',
    eng='Embedded Java uses primitive types for efficiency; enterprise code uses reference types for objects.',
    mistakes='Using uninitialized variables; confusing primitives with their wrapper classes; reassigning final variables.',
    practice=['What is the difference between a primitive and a reference type?', 'What does final do?'],
    quiz=[
        q('Which is a primitive type in Java?', ['String', 'Integer', 'int', 'Object'], [2], 'int is primitive; Integer is its wrapper.'),
        q('What does final do to a variable?', ['Makes it static', 'Makes it constant', 'Makes it public', 'Makes it null'], [1], 'final prevents reassignment.'),
    ])

lesson(4, 3, 'Data Types',
    concept='Java provides eight primitive types with fixed sizes: byte, short, int, long, float, double, char, boolean.',
    definition='Primitive data types in Java have fixed sizes and ranges, independent of the underlying platform.',
    explanation='byte (8-bit), short (16-bit), int (32-bit), long (64-bit) for integers; float (32-bit) and double (64-bit) for decimals; char (16-bit Unicode); boolean (true/false). Fixed sizes ensure platform independence. Wrapper classes (Integer, Double) add object capabilities and collections support.',
    worked='byte b = 127;          // -128 to 127\nint i = 2000000000;    // ~2 billion\nlong l = 9000000000000L; // 64-bit\ndouble d = 3.14159;\nchar c = \'A\';\nboolean flag = true;',
    eng='Choosing int vs long for counters prevents overflow in high-throughput data acquisition systems.',
    mistakes='Overflowing int ranges; using float for precise decimal (use double or BigDecimal); assuming char is ASCII.',
    practice=['What is the range of a byte?', 'When would you use long instead of int?'],
    quiz=[
        q('How many bits is a Java int?', ['16', '32', '64', '8'], [1], 'int is 32-bit.'),
        q('Which type is most precise for decimals?', ['float', 'double', 'int', 'BigDecimal only'], [1], 'double offers more precision than float.'),
    ])

lesson(4, 4, 'Operators',
    concept='Java operators mirror C: arithmetic, relational, logical, bitwise, and assignment, with strict type checking.',
    definition='Java operators perform operations on operands with well-defined precedence and type promotion rules.',
    explanation='Arithmetic (+, -, *, /, %) follows standard precedence. Integer division truncates. Relational operators return boolean. Logical operators (&&, ||, !) work on booleans. Bitwise operators work on integers. The ternary operator (?:) provides inline conditionals. Type promotion widens smaller types in mixed expressions.',
    worked='int a = 7, b = 2;\na / b        // 3 (integer division)\na % b        // 1\nboolean ok = (a > b) && (b > 0);  // true\nint max = (a > b) ? a : b;        // ternary',
    eng='Bitwise operators configure hardware registers in Android native code and embedded Java.',
    mistakes='Integer division truncation; = vs ==; operator precedence surprises with & and |.',
    practice=['What is 7 / 2 in Java?', 'What does the ternary operator do?'],
    quiz=[
        q('What is 7 / 2 in Java?', ['3.5', '3', '4', '3.0'], [1], 'Integer division truncates.'),
        q('Which operator is the ternary conditional?', ['??', '?:', '::', '->'], [1], '?: is the ternary operator.'),
    ])

lesson(4, 5, 'Conditions',
    concept='Java uses if, else if, else, and switch for conditional execution, with strict boolean conditions.',
    definition='Conditional statements in Java execute code blocks based on boolean expressions.',
    explanation='if/else if/else chains evaluate conditions in order. switch matches a variable against constant cases (int, char, String since Java 7, enums). Java conditions must be boolean — unlike C, integers are not truthy. break prevents fall-through in switch.',
    worked='int score = 85;\nif (score >= 90) {\n    grade = "A";\n} else if (score >= 80) {\n    grade = "B";\n} else {\n    grade = "C";\n}',
    eng='State machines in embedded Java use switch on state enums to dispatch behavior.',
    mistakes='Using non-boolean conditions; forgetting break in switch; assignment in conditions.',
    practice=['Can you use an int as a condition in Java?', 'What is fall-through in switch?'],
    quiz=[
        q('Can you write if (x) where x is an int in Java?', ['Yes', 'No', 'Only if x > 0', 'Only in loops'], [1], 'Java conditions must be boolean.'),
        q('What does break do in a switch?', ['Exits program', 'Prevents fall-through', 'Skips iteration', 'Continues'], [1], 'break exits the switch.'),
    ])

lesson(4, 6, 'Loops',
    concept='Java provides for, while, do-while, and enhanced for (for-each) loops for iteration.',
    definition='Java loops repeat code blocks: for counted iteration, while condition-based, do-while guaranteed-once, and for-each over collections.',
    explanation='The classic for loop has init, condition, and update. The enhanced for (for (Type item : collection)) iterates collections and arrays without indices. while checks before each iteration; do-while checks after. break and continue work as in C.',
    worked='for (int i = 0; i < 5; i++) {\n    System.out.print(i);\n}\nfor (String name : names) {\n    System.out.println(name);\n}',
    eng='Data processing loops iterate over collections of sensor readings with for-each for clean, index-free code.',
    mistakes='Off-by-one errors; infinite loops; modifying collections during for-each iteration.',
    practice=['When do you use for-each?', 'What is the difference between while and do-while?'],
    quiz=[
        q('Which loop is best for iterating a collection?', ['for', 'while', 'for-each', 'do-while'], [2], 'for-each iterates collections cleanly.'),
        q('How many times does do-while execute at minimum?', ['0', '1', '2', 'Depends'], [1], 'do-while runs at least once.'),
    ])

lesson(4, 7, 'Methods',
    concept='Java methods are defined within classes with a return type, name, parameters, and access modifiers.',
    definition='A method is a named block of code within a class that performs a task, optionally accepting parameters and returning a value.',
    explanation='Methods are the primary unit of behavior in Java. Access modifiers (public, private, protected) control visibility. static methods belong to the class; instance methods belong to objects. Method overloading allows same-name methods with different parameters. varargs (Type... args) accept variable arguments.',
    worked='public int add(int a, int b) {\n    return a + b;\n}\npublic static double average(double... values) {\n    double sum = 0;\n    for (double v : values) sum += v;\n    return sum / values.length;\n}',
    eng='Utility classes (Math, Collections) provide static methods for common operations without object creation.',
    mistakes='Forgetting return types; overloading on return type; confusing static and instance methods.',
    practice=['What is method overloading?', 'What does static mean for a method?'],
    quiz=[
        q('Can methods be overloaded by return type alone?', ['Yes', 'No', 'Only static', 'Only private'], [1], 'Overloading requires different parameters.'),
        q('What does a static method belong to?', ['An object', 'The class', 'A package', 'A thread'], [1], 'static methods belong to the class.'),
    ])

lesson(4, 8, 'Classes',
    concept='Java classes are blueprints for objects, bundling fields (state) and methods (behavior) with access control.',
    definition='A class is a user-defined type that encapsulates data and behavior, forming the basis of Java\'s object-oriented model.',
    explanation='Every Java program consists of classes. Fields hold state; methods define behavior. Constructors initialize objects. Access modifiers enforce encapsulation. Java supports single inheritance but multiple interface implementation. The this keyword references the current object.',
    worked='public class Student {\n    private String name;\n    private int age;\n    public Student(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    public String getName() { return name; }\n}',
    eng='Enterprise systems model domain entities (User, Order, Product) as classes with encapsulated state.',
    mistakes='Public fields breaking encapsulation; missing constructors; confusing class with object.',
    practice=['What is a constructor?', 'Why use private fields?'],
    quiz=[
        q('What is the default access for class members if unspecified?', ['public', 'private', 'protected', 'package-private'], [3], 'Default is package-private.'),
        q('What does this refer to?', ['The class', 'The current object', 'A static field', 'The parent'], [1], 'this references the current instance.'),
    ])

lesson(4, 9, 'Objects',
    concept='Objects are instances of classes created with new, each with independent state but shared class code.',
    definition='An object is a runtime instance of a class, occupying heap memory with its own field values.',
    explanation='new ClassName() allocates memory and calls the constructor. Objects are accessed through references. Multiple references can point to the same object. The heap stores objects; the stack stores references and primitives. Garbage collection reclaims unreachable objects automatically.',
    worked='Student s1 = new Student("Tommy", 20);\nStudent s2 = new Student("Ada", 22);\nSystem.out.println(s1.getName());  // "Tommy"\ns1 and s2 have independent name/age fields',
    eng='Each connected device in an IoT platform is an object with its own state (ID, status, telemetry).',
    mistakes='Assuming assignment copies objects (it copies references); memory leaks from lingering references; null pointer exceptions.',
    practice=['What does new do?', 'What is a NullPointerException?'],
    quiz=[
        q('What does new Student() do?', ['Declares a class', 'Creates an object on the heap', 'Imports a package', 'Calls a method'], [1], 'new allocates and constructs an object.'),
        q('What is a NullPointerException?', ['Memory full', 'Accessing a null reference', 'Stack overflow', 'Type error'], [1], 'It occurs when dereferencing null.'),
    ])

lesson(4, 10, 'Inheritance',
    concept='Java inheritance lets a subclass extend a superclass, inheriting fields and methods while adding or overriding behavior.',
    definition='Inheritance is a mechanism where a subclass acquires the properties and behaviors of a superclass using extends.',
    explanation='The subclass inherits non-private members of the superclass. super calls the superclass constructor or methods. @Override marks overridden methods. Java supports single inheritance for classes but multiple inheritance for interfaces. Inheritance models "is-a" relationships.',
    worked='class Animal {\n    void speak() { System.out.println("..."); }\n}\nclass Dog extends Animal {\n    @Override\n    void speak() { System.out.println("Woof"); }\n}',
    eng='Android UI components inherit from View, customizing rendering while reusing event handling.',
    mistakes='Using inheritance for "has-a" (use composition); hiding instead of overriding; deep hierarchies.',
    practice=['What is the difference between extends and implements?', 'What does @Override do?'],
    quiz=[
        q('Java supports multiple inheritance for:', ['Classes', 'Interfaces', 'Both', 'Neither'], [1], 'Classes: single; interfaces: multiple.'),
        q('Which keyword calls the superclass constructor?', ['this', 'super', 'extends', 'parent'], [1], 'super invokes the superclass constructor.'),
    ])

lesson(4, 11, 'Interfaces',
    concept='Java interfaces define contracts — sets of methods that implementing classes must provide, enabling polymorphism.',
    definition='An interface is a reference type containing abstract methods (and default/static methods since Java 8) that classes implement.',
    explanation='Interfaces specify what a class can do, not how. A class implements multiple interfaces. Since Java 8, interfaces can have default and static method implementations. Interfaces enable loose coupling: code depends on the interface, not the concrete class.',
    worked='interface Drawable {\n    void draw();\n    default void describe() {\n        System.out.println("A drawable object");\n    }\n}\nclass Circle implements Drawable {\n    public void draw() { /* ... */ }\n}',
    eng='Hardware abstraction layers define interfaces (Sensor, Display) so application code works with any implementation.',
    mistakes='Implementing an interface without all methods; confusing interface with abstract class; using interfaces for constants only.',
    practice=['What is the difference between an interface and an abstract class?', 'Can a class implement multiple interfaces?'],
    quiz=[
        q('Can a Java class implement multiple interfaces?', ['No', 'Yes', 'Only two', 'Only one'], [1], 'Java allows multiple interface implementation.'),
        q('What must a class do when implementing an interface?', ['Extend it', 'Implement all abstract methods', 'Declare it final', 'Nothing'], [1], 'All abstract methods must be implemented.'),
    ])

lesson(4, 12, 'Polymorphism',
    concept='Java polymorphism allows one interface to have many implementations, with the JVM selecting the method at runtime.',
    definition='Polymorphism is the ability of an object to take many forms, achieved through method overriding and dynamic method dispatch.',
    explanation='A superclass reference can point to subclass objects. When a method is called, the JVM invokes the object\'s actual type\'s implementation (dynamic dispatch). This enables extensible code: new subclasses work with existing code that uses the superclass type.',
    worked='Animal a = new Dog();  // superclass reference\na.speak();  // "Woof" — Dog\'s method runs\nAnimal b = new Cat();\nb.speak();  // "Meow" — Cat\'s method runs',
    eng='Plugin systems register implementations of a common interface; the core calls interface methods without knowing concrete types.',
    mistakes='Expecting compile-time method selection; hiding static methods (not polymorphic); casting without instanceof checks.',
    practice=['What is dynamic dispatch?', 'Are static methods polymorphic?'],
    quiz=[
        q('When is the method implementation chosen in polymorphism?', ['Compile time', 'Runtime', 'Link time', 'Never'], [1], 'Dynamic dispatch selects at runtime.'),
        q('Are static methods polymorphic?', ['Yes', 'No', 'Only final', 'Only private'], [1], 'Static methods are not overridden.'),
    ])

lesson(4, 13, 'Collections',
    concept='The Java Collections Framework provides List, Set, Map, and Queue interfaces with implementations like ArrayList, HashSet, and HashMap.',
    definition='The Collections Framework is a unified architecture for storing and manipulating groups of objects.',
    explanation='List (ArrayList, LinkedList) is an ordered sequence allowing duplicates. Set (HashSet, TreeSet) stores unique elements. Map (HashMap, TreeMap) stores key-value pairs. Queue (LinkedList, PriorityQueue) holds elements for processing. Collections provide sorting, searching, and thread-safe wrappers.',
    worked='List<String> names = new ArrayList<>();\nnames.add("Tommy");\nSet<Integer> ids = new HashSet<>();\nMap<String, Integer> ages = new HashMap<>();\nages.put("Tommy", 20);',
    eng='Server applications use ConcurrentHashMap for thread-safe caching and PriorityQueue for task scheduling.',
    mistakes='Using raw types (always parameterize); choosing ArrayList for frequent middle insertion; assuming HashSet order.',
    practice=['When would you use a LinkedList over an ArrayList?', 'What is the difference between HashSet and TreeSet?'],
    quiz=[
        q('Which List implementation is backed by an array?', ['LinkedList', 'ArrayList', 'Vector', 'Stack'], [1], 'ArrayList uses a dynamic array.'),
        q('Which Set keeps elements sorted?', ['HashSet', 'TreeSet', 'LinkedHashSet', 'ArraySet'], [1], 'TreeSet keeps sorted order.'),
    ])

lesson(4, 14, 'Exceptions',
    concept='Java exceptions handle errors via try/catch/finally, with checked exceptions enforced at compile time and unchecked for runtime errors.',
    definition='Exception handling in Java manages runtime errors through a hierarchy of throwable objects.',
    explanation='Checked exceptions (IOException, SQLException) must be caught or declared. Unchecked exceptions (NullPointerException, ArithmeticException) derive from RuntimeException. try/catch/finally structure handles errors; try-with-resources auto-closes resources. throw raises; throws declares.',
    worked='try (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {\n    String line = br.readLine();\n} catch (IOException e) {\n    System.err.println("Read error: " + e.getMessage());\n}',
    eng='Enterprise services catch specific exceptions to return meaningful error responses while logging details.',
    mistakes='Catching Throwable or Exception broadly; empty catch blocks; using exceptions for control flow.',
    practice=['What is the difference between checked and unchecked exceptions?', 'What does try-with-resources do?'],
    quiz=[
        q('Which is a checked exception?', ['NullPointerException', 'IOException', 'ArithmeticException', 'ArrayIndexOutOfBoundsException'], [1], 'IOException is checked.'),
        q('What does try-with-resources guarantee?', ['Faster code', 'Automatic resource closing', 'No exceptions', 'Thread safety'], [1], 'Resources close automatically.'),
    ])

lesson(4, 15, 'File Handling',
    concept='Java file I/O uses streams (InputStream/OutputStream for bytes, Reader/Writer for characters) and NIO for modern file operations.',
    definition='Java file handling reads and writes files through stream classes and the NIO.2 Path/Files API.',
    explanation='Streams process data sequentially: FileInputStream/FileOutputStream for bytes, FileReader/Writer for characters. BufferedReader adds line reading and buffering. NIO.2 (Path, Files) provides modern operations: Files.readAllLines(), Files.write(), Files.exists(). Always close resources or use try-with-resources.',
    worked='Path path = Paths.get("data.txt");\nList<String> lines = Files.readAllLines(path);\nFiles.write(path, List.of("line1", "line2"), StandardOpenOption.APPEND);',
    eng='Log processors read large files line-by-line with BufferedReader to avoid loading everything into memory.',
    mistakes='Not closing streams; reading binary as characters; ignoring charset (specify UTF-8).',
    practice=['What is the difference between a stream and a reader?', 'How do you append to a file?'],
    quiz=[
        q('Which class reads text files line by line efficiently?', ['FileInputStream', 'BufferedReader', 'DataInputStream', 'ObjectInputStream'], [1], 'BufferedReader buffers character input.'),
        q('Which NIO class represents a file path?', ['File', 'Path', 'Stream', 'Channel'], [1], 'Path represents file paths in NIO.2.'),
    ])

lesson(4, 16, 'Java OOP Practice',
    concept='Java OOP mastery comes from designing class hierarchies, using interfaces for flexibility, and applying design patterns.',
    definition='OOP practice in Java involves designing and implementing systems using objects, inheritance, polymorphism, and encapsulation.',
    explanation='Effective Java OOP: program to interfaces, favor composition over inheritance, keep classes small, use design patterns (Factory, Observer, Strategy). Practice projects: a banking system with Account hierarchy, a library management system, a chat application with Observer pattern.',
    worked='Project: Banking system\n- Account (abstract) → SavingsAccount, CheckingAccount\n- Transaction interface with implementations\n- Bank class managing accounts via List<Account>\n- Polymorphic withdraw/deposit behavior',
    eng='Enterprise applications are built on layered OOP design: entities, services, repositories, controllers.',
    mistakes='Anemic domain models (classes with only getters); god classes; tight coupling.',
    practice=['Design a class hierarchy for a vehicle rental system.', 'Implement the Observer pattern for a stock price monitor.'],
    quiz=[
        q('What does "program to an interface" mean?', ['Use interface types for flexibility', 'Avoid classes', 'Use only abstract classes', 'Write interfaces for everything'], [1], 'Interface types enable swapping implementations.'),
        q('Which pattern notifies observers of state changes?', ['Factory', 'Observer', 'Singleton', 'Builder'], [1], 'Observer notifies dependents of changes.'),
    ])

formula('Programming', 'Java Memory Model', 'Heap + Stack + Metaspace', 'Heap: objects; Stack: frames; Metaspace: classes', 'JVM memory tuning')
formula('Programming', 'Big-O Notation', 'O(f(n))', 'f(n): growth function', 'Algorithm complexity analysis')

reference('Python', 'Basics', 'Hello World', 'print("Hello, World!")\n\nname = "Tommy"\nage = 20\nprint(f"{name} is {age} years old")')
reference('Python', 'Variables', 'Variable Assignment', 'x = 10\ny = 3.14\nname = "Tommy"\nis_valid = True\n\nprint(type(x))  # <class \'int\'>')
reference('Python', 'Control Flow', 'If-Else Statement', 'temperature = 85\n\nif temperature > 90:\n    print("Hot")\nelif temperature > 70:\n    print("Warm")\nelse:\n    print("Cool")')
reference('Python', 'Loops', 'For Loop', 'for i in range(5):\n    print(i)\n\nnames = ["Ada", "Grace", "Tommy"]\nfor name in names:\n    print(f"Hello, {name}!")')
reference('Python', 'Functions', 'Function Definition', 'def add(a, b):\n    return a + b\n\ndef greet(name, greeting="Hello"):\n    return f"{greeting}, {name}!"\n\nprint(add(3, 4))\nprint(greet("Tommy"))')
reference('Python', 'Lists', 'List Operations', 'numbers = [1, 2, 3, 4, 5]\nnumbers.append(6)\nnumbers.insert(0, 0)\n\nsquares = [n ** 2 for n in numbers]\nprint(squares)')
reference('Python', 'Dictionaries', 'Dictionary Usage', 'ages = {"Tommy": 20, "Ada": 22}\nages["Grace"] = 21\n\nfor name, age in ages.items():\n    print(f"{name}: {age}")')
reference('Python', 'Classes', 'Class Definition', 'class Circle:\n    def __init__(self, radius):\n        self.radius = radius\n\n    def area(self):\n        return 3.14159 * self.radius ** 2\n\nc = Circle(5)\nprint(f"Area: {c.area():.2f}")')
reference('Python', 'File Handling', 'Read and Write Files', '# Write to file\nwith open("data.txt", "w") as f:\n    f.write("Hello, File!\\n")\n\n# Read from file\nwith open("data.txt", "r") as f:\n    content = f.read()\n    print(content)')
reference('Java', 'Basics', 'Hello World', 'public class Hello {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}')
reference('Java', 'Variables', 'Variable Declaration', 'public class Variables {\n    public static void main(String[] args) {\n        int age = 20;\n        double gpa = 3.85;\n        String name = "Tommy";\n        boolean isStudent = true;\n\n        System.out.println(name + " is " + age);\n    }\n}')
reference('Java', 'Control Flow', 'If-Else Statement', 'int score = 85;\nString grade;\n\nif (score >= 90) {\n    grade = "A";\n} else if (score >= 80) {\n    grade = "B";\n} else {\n    grade = "C";\n}\nSystem.out.println("Grade: " + grade);')
reference('Java', 'Loops', 'For Loop', 'for (int i = 1; i <= 5; i++) {\n    System.out.print(i + " ");\n}\nSystem.out.println();\n\nString[] names = {"Ada", "Grace", "Tommy"};\nfor (String name : names) {\n    System.out.println("Hello, " + name);\n}')
reference('Java', 'Classes', 'Class Definition', 'public class Student {\n    private String name;\n    private int age;\n\n    public Student(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n\n    public String getName() {\n        return name;\n    }\n\n    public int getAge() {\n        return age;\n    }\n}')
reference('Java', 'Inheritance', 'Extending Classes', 'class Animal {\n    void speak() {\n        System.out.println("Animal sound");\n    }\n}\n\nclass Dog extends Animal {\n    @Override\n    void speak() {\n        System.out.println("Woof!");\n    }\n}')
reference('Java', 'Collections', 'ArrayList Usage', 'import java.util.ArrayList;\nimport java.util.List;\n\nList<String> names = new ArrayList<>();\nnames.add("Tommy");\nnames.add("Ada");\n\nfor (String name : names) {\n    System.out.println(name);\n}')
reference('Java', 'File Handling', 'Read File', 'import java.io.BufferedReader;\nimport java.io.FileReader;\nimport java.io.IOException;\n\ntry (BufferedReader br = new BufferedReader(new FileReader("data.txt"))) {\n    String line;\n    while ((line = br.readLine()) != null) {\n        System.out.println(line);\n    }\n} catch (IOException e) {\n    e.printStackTrace();\n}')
