"""C Programming and C++ curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(1, 'C Programming', 'Programming',
        'C • Variables • Pointers • Memory', 'code')
subject(2, 'C++', 'Programming',
        'OOP • Classes • STL • Templates', 'terminal')

# ---------------- C Programming (20 lessons) ----------------

lesson(1, 1, 'Introduction to C',
    concept='C is a procedural, compiled programming language developed at Bell Labs in 1972. It gives fine-grained control over memory and hardware while remaining portable across platforms.',
    definition='C is a general-purpose, structured programming language that provides low-level access to memory through pointers and manual memory management.',
    explanation='C programs are compiled directly to machine code, making them fast and efficient. The language is small in syntax but powerful: it forms the foundation of operating systems, embedded systems, and performance-critical software. Every C program starts execution at the main() function.',
    worked='A minimal C program:\n#include <stdio.h>\nint main() {\n    printf("Hello, World!\\n");\n    return 0;\n}\nThe #include directive pulls in the standard I/O library, main() is the entry point, and return 0 signals successful execution to the operating system.',
    eng='C is the language of choice for firmware, kernels (Linux is written in C), and microcontrollers where every byte of memory and every CPU cycle matters.',
    mistakes='Forgetting the semicolon at the end of statements; confusing assignment (=) with comparison (==); omitting #include <stdio.h> before using printf.',
    practice=['What is the entry point of every C program?', 'Why is C considered a middle-level language?'],
    quiz=[
        q('Which function is the entry point of a C program?', ['main()', 'start()', 'init()', 'begin()'], [0], 'Every C program begins execution at main().'),
        q('C was originally developed at which company?', ['Microsoft', 'Bell Labs', 'IBM', 'Apple'], [1], 'Dennis Ritchie created C at Bell Labs in 1972.'),
    ])

lesson(1, 2, 'Variables',
    concept='A variable is a named location in memory that stores a value of a specific type. In C, variables must be declared before use.',
    definition='A variable is a named storage location with a fixed data type that determines its size in memory and the operations allowed on it.',
    explanation='Declaring a variable (e.g., int age = 20;) tells the compiler to reserve memory for an integer and associate the name "age" with that location. C is statically typed: the type is fixed at compile time and cannot change.',
    worked='int count = 10;      // 4 bytes (typically)\nfloat price = 19.99;  // 4 bytes\ngrade = \'A\';          // 1 byte\nEach declaration reserves memory sized for its type and stores the initial value there.',
    eng='In embedded C, choosing int16_t instead of int can halve RAM usage on a microcontroller with only 2 KB of SRAM.',
    mistakes='Using a variable before declaration; assuming uninitialized variables contain zero (they contain garbage); redeclaring a variable in the same scope.',
    practice=['What happens if you use an uninitialized variable in C?', 'How much memory does a char typically occupy?'],
    quiz=[
        q('What is the value of an uninitialized local int variable in C?', ['0', 'Garbage value', 'NULL', 'It causes a compile error'], [1], 'Uninitialized locals contain whatever was previously in that memory.'),
        q('Which keyword declares a variable that cannot be modified?', ['static', 'const', 'volatile', 'register'], [1], 'const makes a variable read-only after initialization.'),
    ])

lesson(1, 3, 'Data Types',
    concept='C provides fundamental data types — char, int, float, double — plus modifiers (short, long, signed, unsigned) that adjust their size and range.',
    definition='Data types define the size, range, and representation of values a variable can hold.',
    explanation='A char is 1 byte (values -128 to 127 or 0 to 255). An int is typically 4 bytes. float and double represent floating-point numbers with ~6 and ~15 decimal digits of precision. Modifiers like unsigned double the positive range by removing negative values.',
    worked='unsigned int x = 4000000000;  // valid: unsigned extends range\nlong long big = 9000000000000;   // at least 64 bits\nChoosing the right type prevents overflow and saves memory.',
    eng='Sensor data from a 12-bit ADC (0–4095) fits in an unsigned short, saving memory on data-logging devices.',
    mistakes='Using float for money (rounding errors — use integer cents); assuming int is always 4 bytes; overflowing unsigned types silently.',
    practice=['Why should you not use float for financial calculations?', 'What is the difference between float and double?'],
    quiz=[
        q('Which type typically offers the most precision?', ['float', 'double', 'int', 'char'], [1], 'double provides roughly twice the precision of float.'),
        q('What does the unsigned modifier do?', ['Makes values read-only', 'Removes negative range, doubling positive range', 'Increases memory usage', 'Allows decimal values'], [1], 'unsigned restricts values to non-negative numbers.'),
    ])

lesson(1, 4, 'Operators',
    concept='C provides arithmetic (+, -, *, /, %), relational (==, !=, <, >), logical (&&, ||, !), bitwise (&, |, ^, ~, <<, >>), and assignment operators (=, +=, etc.).',
    definition='Operators are symbols that perform operations on operands, with precedence determining evaluation order.',
    explanation='Arithmetic operators work on numbers. The modulo operator % returns the remainder of division. Logical operators combine boolean conditions. Bitwise operators manipulate individual bits. Assignment operators like += combine an operation with assignment.',
    worked='int a = 10, b = 3;\na / b   // 3 (integer division truncates)\na % b   // 1 (remainder)\na > b && b > 0  // true (logical AND)\na << 1  // 20 (left shift multiplies by 2)',
    eng='Bitwise operators are essential in embedded systems for setting, clearing, and toggling individual hardware register bits efficiently.',
    mistakes='Using = instead of == in conditions; confusing && with &; integer division truncating when a float result is needed.',
    practice=['What is 7 % 3?', 'What does << 1 do to a number?'],
    quiz=[
        q('What is the result of 7 / 2 in C when both are integers?', ['3.5', '3', '4', '2'], [1], 'Integer division truncates the fractional part.'),
        q('Which operator returns the remainder of division?', ['/', '%', 'mod', '&'], [1], 'The % operator computes the remainder.'),
    ])

lesson(1, 5, 'Input and Output',
    concept='C uses stdio.h functions printf() for formatted output and scanf() for formatted input, operating on the standard streams stdin and stdout.',
    definition='Formatted I/O reads and writes data using format specifiers that describe how values are converted between memory representation and text.',
    explanation='printf() writes formatted text to stdout using format specifiers like %d (int), %f (float), %c (char), %s (string). scanf() reads from stdin, requiring the address-of operator & for non-pointer variables. Mismatched format specifiers cause undefined behavior.',
    worked='int age;\nprintf("Enter age: ");\nscanf("%d", &age);\nprintf("You are %d years old\\n", age);\nThe & passes the variable\'s address so scanf can write into it.',
    eng='Command-line tools and diagnostic firmware use printf-style logging over UART serial to report sensor readings and system state.',
    mistakes='Forgetting & in scanf for non-pointer types; mismatching format specifiers with argument types; not checking scanf\'s return value.',
    practice=['Why does scanf need & before the variable name?', 'What does %d represent in printf?'],
    quiz=[
        q('Which function reads formatted input in C?', ['printf()', 'scanf()', 'gets()', 'cin'], [1], 'scanf() reads formatted input from stdin.'),
        q('What does the format specifier %f represent?', ['int', 'char', 'float/double', 'string'], [2], '%f formats floating-point values.'),
    ])

lesson(1, 6, 'Conditional Statements',
    concept='if, else if, and else execute different code blocks based on boolean conditions. The switch statement selects among many constant cases.',
    definition='Conditional statements control program flow by executing code only when specified conditions are true.',
    explanation='An if statement evaluates a condition; if true, its block runs. else if chains additional conditions. The switch statement compares one expression against multiple constant cases and is cleaner than long if-else chains for discrete values.',
    worked='int score = 85;\nif (score >= 90) {\n    grade = \'A\';\n} else if (score >= 80) {\n    grade = \'B\';\n} else {\n    grade = \'C\';\n}\nOnly the first matching branch executes.',
    eng='State machines in embedded firmware use switch-case to dispatch behavior based on the current device state (IDLE, RUNNING, ERROR).',
    mistakes='Using = instead of == in conditions; forgetting break in switch cases (fall-through); dangling else ambiguity.',
    practice=['What is the purpose of break in a switch statement?', 'When would you use else if instead of multiple ifs?'],
    quiz=[
        q('What happens if you omit break in a switch case?', ['Nothing', 'Execution falls through to the next case', 'The program crashes', 'The compiler errors'], [1], 'Without break, execution continues into subsequent cases.'),
        q('Which keyword handles the default case in a switch?', ['else', 'default', 'case', 'otherwise'], [1], 'default handles values not matched by any case.'),
    ])

lesson(1, 7, 'Loops',
    concept='C provides for, while, and do-while loops for repetition. for is ideal for counted iteration, while for condition-based loops, and do-while when the body must run at least once.',
    definition='Loops repeatedly execute a block of code while a condition holds or for a fixed number of iterations.',
    explanation='A for loop bundles initialization, condition, and update in one line. A while loop checks the condition before each iteration. A do-while loop checks after, guaranteeing at least one execution. break exits a loop immediately; continue skips to the next iteration.',
    worked='for (int i = 0; i < 5; i++) {\n    printf("%d ", i);  // prints 0 1 2 3 4\n}\nint n = 0;\ndo {\n    n++;\n} while (n < 3);  // runs 3 times',
    eng='Firmware super-loops use while(1) to poll sensors and handle events continuously, with break used only for fatal error handling.',
    mistakes='Infinite loops from missing updates (for (int i=0; i<5;)); off-by-one errors (i <= 5 vs i < 5); modifying the loop variable inside the body.',
    practice=['When is do-while preferred over while?', 'What does the continue statement do?'],
    quiz=[
        q('Which loop guarantees at least one execution?', ['for', 'while', 'do-while', 'switch'], [2], 'do-while checks its condition after the body.'),
        q('What does break do inside a loop?', ['Skips one iteration', 'Exits the loop entirely', 'Restarts the loop', 'Pauses the loop'], [1], 'break immediately terminates the nearest enclosing loop.'),
    ])

lesson(1, 8, 'Functions',
    concept='A function is a named, reusable block of input parameters and a return value. Functions enable modular, testable code.',
    definition='A function is a self-contained block of code that performs a specific task, optionally accepting parameters and returning a value.',
    explanation='Functions are declared with a return type, name, and parameter list. They promote code reuse and separation of concerns. C uses pass-by-value: functions receive copies of arguments, so modifying parameters does not affect the caller\'s variables (unless pointers are used).',
    worked='int add(int a, int b) {\n    return a + b;\n}\nint result = add(3, 4);  // result = 7\nThe function receives copies of 3 and 4, computes their sum, and returns it.',
    eng='Embedded code is organized into hardware abstraction layer (HAL) functions like gpio_set(pin, high) so application logic stays portable across microcontrollers.',
    mistakes='Forgetting the return type (defaults to int in old C); not declaring functions before use; ignoring return values.',
    practice=['What is pass-by-value?', 'Why use functions instead of copying code?'],
    quiz=[
        q('How does C pass arguments to functions by default?', ['By reference', 'By value', 'By pointer', 'By name'], [1], 'C passes copies of arguments by value.'),
        q('What does void as a return type mean?', ['Returns zero', 'Returns nothing', 'Returns a null pointer', 'Is invalid syntax'], [1], 'void indicates the function returns no value.'),
    ])

lesson(1, 9, 'Arrays',
    concept='An array is a contiguous block of memory holding elements of the same type, accessed by zero-based index.',
    definition='An array is a fixed-size collection of same-type elements stored in contiguous memory locations.',
    explanation='Array indices start at 0. The array name acts as a pointer to the first element. C does not bounds-check array access, so reading or writing past the end causes undefined behavior. Multidimensional arrays are arrays of arrays.',
    worked='int temps[5] = {20, 22, 21, 23, 24};\nint sum = 0;\nfor (int i = 0; i < 5; i++) sum += temps[i];\nsum = 110. Valid indices are 0 through 4.',
    eng='ADC sample buffers are arrays: volatile uint16_t samples[256] stores a window of sensor readings for digital signal processing.',
    mistakes='Accessing index equal to the array size (off-by-one); assuming arrays know their own size; confusing array declaration with pointer declaration.',
    practice=['What is the valid index range for an array of size 10?', 'How do you find the sum of all array elements?'],
    quiz=[
        q('What is the first index of a C array?', ['1', '0', '-1', 'Depends on declaration'], [1], 'C arrays are zero-indexed.'),
        q('What happens if you access arr[10] on an array of size 10?', ['Returns 0', 'Undefined behavior', 'Returns the last element', 'Compile error'], [1], 'Out-of-bounds access is undefined behavior in C.'),
    ])

lesson(1, 10, 'Strings',
    concept='C strings are null-terminated character arrays. The string.h library provides functions like strlen, strcpy, strcat, and strcmp.',
    definition='A string in C is a sequence of characters terminated by a null byte (\\0), stored in a char array.',
    explanation='Because strings are just char arrays, the null terminator \\0 marks the end. String functions rely on this terminator; forgetting it causes buffer overreads. Modern C code prefers bounded functions (strncpy, strncat) to prevent buffer overflows.',
    worked='char name[6] = "Tommy";  // {\'T\',\'o\',\'m\',\'m\',\'y\',\'\\0\'}\nstrlen(name)  // 5 (excludes \\0)\nstrcpy(greeting, name);  // copies including \\0',
    eng='UART command parsers in firmware compare incoming strings with strcmp to match commands like "LED ON" and dispatch actions.',
    mistakes='Forgetting space for the null terminator; using strcpy without bounds checking; comparing strings with == instead of strcmp.',
    practice=['Why must C strings end with \\0?', 'What does strlen return for "hello"?'],
    quiz=[
        q('How does C mark the end of a string?', ['Newline', 'Null byte \\0', 'Space', 'Period'], [1], 'The null terminator \\0 marks string end.'),
        q('Which function compares two strings?', ['strcpy', 'strcmp', 'strlen', 'strcat'], [1], 'strcmp compares strings lexicographically.'),
    ])

lesson(1, 11, 'Pointers',
    concept='A pointer is a variable that stores a memory address. Pointers enable direct memory manipulation, dynamic allocation, and efficient array/string handling.',
    definition='A pointer is a variable whose value is the memory address of another variable or allocated block.',
    explanation='The & operator yields a variable\'s address; the * operator dereferences a pointer to access the value at that address. Pointer arithmetic moves by the size of the pointed-to type. Pointers are the mechanism behind C\'s pass-by-reference emulation and dynamic memory.',
    worked='int x = 42;\nint *p = &x;   // p holds x\'s address\nprintf("%d", *p);  // 42 (dereference)\n*p = 100;           // x is now 100',
    eng='Microcontroller registers are accessed through memory-mapped pointers: *(volatile uint32_t*)0x40020000 = 0x1; writes directly to a hardware register.',
    mistakes='Dereferencing uninitialized or NULL pointers; pointer arithmetic on wrong types; memory leaks from unfreed allocations.',
    practice=['What does the * operator do to a pointer?', 'What is the difference between *p and &p?'],
    quiz=[
        q('What does the & operator return?', ['The value of a variable', 'The address of a variable', 'A pointer copy', 'The size of a variable'], [1], '& returns the address of its operand.'),
        q('What does dereferencing a NULL pointer cause?', ['Returns 0', 'Undefined behavior / crash', 'Returns NULL', 'Compile error'], [1], 'Dereferencing NULL is undefined behavior, typically a segfault.'),
    ])

lesson(1, 12, 'Structures',
    concept='A structure (struct) groups variables of different types under one name, creating a custom composite data type.',
    definition='A structure is a user-defined type that aggregates named members of potentially different types into a single unit.',
    explanation='Structs let you model real-world entities with multiple attributes. Members are accessed with the dot operator (.) or arrow (->) through a pointer. Structs can be nested, passed to functions, and allocated dynamically.',
    worked='struct Point { int x; int y; };\nstruct Point p1 = {3, 7};\np1.x = 10;  // modify member\nstruct Point *ptr = &p1;\nptr->y = 20;  // arrow through pointer',
    eng='Sensor data packets are structs: struct Reading { uint32_t timestamp; float temperature; float humidity; } bundles related telemetry into one unit.',
    mistakes='Confusing struct declaration with typedef; comparing structs with == (compare members instead); forgetting the struct keyword in C (use typedef).',
    practice=['How do you access a struct member through a pointer?', 'What is the difference between . and ->?'],
    quiz=[
        q('Which operator accesses a struct member through a pointer?', ['.', '->', '::', '*'], [1], 'The arrow operator -> dereferences and accesses in one step.'),
        q('Can a struct contain members of different types?', ['No', 'Yes', 'Only if same size', 'Only pointers'], [1], 'Structs aggregate members of different types.'),
    ])

lesson(1, 13, 'Unions',
    concept='A union is a special data type where all members share the same memory location — only one member can hold a value at a time.',
    definition='A union is a user-defined type whose members overlap in memory, with size equal to the largest member.',
    explanation='Unions save memory when only one of several alternatives is needed at a time. Writing one member overwrites the others. Unions are often combined with a type tag (discriminated union) to track which member is valid.',
    worked='union Data { int i; float f; char str[20]; };\nunion Data d;\nd.i = 10;      // d.f and d.str now invalid\nd.f = 3.14;    // d.i is overwritten\nsizeof(d) == 20 (largest member)',
    eng='Protocol parsers use unions to reinterpret the same byte buffer as different message formats without extra memory copies.',
    mistakes='Reading a member other than the last one written (undefined); assuming members are independent; forgetting unions share memory.',
    practice=['When would you use a union instead of a struct?', 'What determines the size of a union?'],
    quiz=[
        q('How is memory allocated for union members?', ['Separately', 'All members share the same memory', 'Only the first member', 'Dynamically'], [1], 'Union members overlap in memory.'),
        q('What is the size of a union?', ['Sum of all members', 'Size of the largest member', 'Size of the first member', 'Always 8 bytes'], [1], 'A union is as large as its biggest member.'),
    ])

lesson(1, 14, 'Dynamic Memory',
    concept='Dynamic memory allocation uses malloc, calloc, realloc, and free from stdlib.h to request heap memory at runtime.',
    definition='Dynamic allocation reserves memory from the heap during program execution, with the programmer responsible for releasing it.',
    explanation='malloc allocates uninitialized bytes; calloc allocates zeroed memory in count×size units; realloc resizes an existing block; free releases memory. Every allocation must be matched with free to avoid leaks. Dereferencing freed memory (use-after-free) is undefined behavior.',
    worked='int *arr = malloc(5 * sizeof(int));\nif (arr == NULL) { /* handle failure */ }\nfor (int i = 0; i < 5; i++) arr[i] = i * i;\nfree(arr);  // release when done\narr = NULL; // avoid dangling pointer',
    eng='Embedded systems often avoid heap fragmentation by using static pools instead of malloc, but Linux-based embedded devices use dynamic allocation freely.',
    mistakes='Forgetting to free (memory leak); using memory after free; not checking malloc\'s return for NULL; double-free.',
    practice=['What is a memory leak?', 'What is the difference between malloc and calloc?'],
    quiz=[
        q('Which function releases dynamically allocated memory?', ['delete', 'free', 'release', 'clear'], [1], 'free() releases heap memory in C.'),
        q('What does malloc return if allocation fails?', ['0', 'NULL', '-1', 'Garbage pointer'], [1], 'malloc returns NULL on failure.'),
    ])

lesson(1, 15, 'File Handling',
    concept='C file I/O uses FILE pointers with fopen, fclose, fread, fwrite, fprintf, and fscanf to read and write files on disk.',
    definition='File handling persists data to storage by opening files, performing formatted or binary I/O, and closing them to flush buffers.',
    explanation='fopen opens a file with a mode ("r", "w", "a", "rb", etc.) and returns a FILE*. Formatted functions (fprintf/fscanf) work like printf/scannf but on files. Binary functions (fread/fwrite) transfer raw bytes. Always close files with fclose to flush and release resources.',
    worked='FILE *f = fopen("data.txt", "w");\nif (f != NULL) {\n    fprintf(f, "Temperature: %.2f\\n", 23.5);\n    fclose(f);\n}',
    eng='Data loggers write sensor readings to SD card files in CSV format using fprintf, creating records that survive power cycles.',
    mistakes='Not checking fopen\'s return for NULL; forgetting fclose; opening in write mode when you meant append; reading past EOF.',
    practice=['What does the "a" mode do in fopen?', 'Why must you close files after opening them?'],
    quiz=[
        q('Which function opens a file in C?', ['open()', 'fopen()', 'file()', 'read()'], [1], 'fopen() returns a FILE pointer.'),
        q('What does the "w" mode do?', ['Read only', 'Overwrite/create for writing', 'Append', 'Binary read'], [1], '"w" truncates or creates the file for writing.'),
    ])

lesson(1, 16, 'Bitwise Operations',
    concept='Bitwise operators (&, |, ^, ~, <<, >>) manipulate individual bits, enabling efficient flag handling, masking, and arithmetic optimization.',
    definition='Bitwise operations perform logical operations on each bit of integer operands independently.',
    explanation='AND (&) masks bits, OR (|) sets bits, XOR (^) toggles bits, NOT (~) inverts all bits, and shifts (<<, >>) move bits left or right. These operations map directly to CPU instructions and are extremely fast.',
    worked='unsigned char flags = 0b00001101;\nflags |= (1 << 3);   // set bit 3\nflags &= ~(1 << 0);  // clear bit 0\nflags ^= (1 << 2);   // toggle bit 2\nif (flags & (1 << 3)) { /* bit 3 is set */ }',
    eng='Setting a GPIO pin on an STM32: GPIOA->ODR |= (1 << 5); compiles to a single atomic bit-set instruction.',
    mistakes='Confusing bitwise & with logical &&; shifting into the sign bit of signed integers; forgetting operator precedence (== binds tighter than &).',
    practice=['How do you set bit 4 of a variable?', 'How do you check if bit 2 is set?'],
    quiz=[
        q('Which operator sets a specific bit?', ['&', '|', '^', '~'], [1], 'OR with a mask sets bits.'),
        q('What does x << 2 compute?', ['x / 4', 'x * 4', 'x ^ 2', 'x & 2'], [1], 'Left shift by 2 multiplies by 2^2 = 4.'),
    ])

lesson(1, 17, 'Memory Management',
    concept='C memory is divided into stack (local variables, automatic), heap (dynamic allocation), global/static (program lifetime), and code segments.',
    definition='Memory management in C involves understanding where variables live, their lifetime, and who is responsible for allocating and freeing them.',
    explanation='Stack memory is automatically managed: local variables are created on function entry and destroyed on exit. Heap memory is manually managed with malloc/free. Static and global variables persist for the program\'s lifetime. Understanding these regions prevents leaks, dangling pointers, and stack overflows.',
    worked='void demo() {\n    int local = 5;        // stack: dies on return\n    static int count = 0; // static: persists\n    int *heap = malloc(sizeof(int)); // heap: manual\n    free(heap);\n}',
    eng='Bare-metal firmware places the stack in SRAM and the heap in a reserved region; stack overflow detection uses canary values or MPU guards.',
    mistakes='Returning pointers to local variables; stack overflow from large local arrays; assuming heap memory is zeroed (use calloc).',
    practice=['What happens to a local variable when its function returns?', 'Where do static variables live?'],
    quiz=[
        q('Where are local variables stored?', ['Heap', 'Stack', 'Code segment', 'Register always'], [1], 'Local variables live on the stack.'),
        q('What is a dangling pointer?', ['A NULL pointer', 'A pointer to freed memory', 'A pointer to a local variable', 'An uninitialized pointer'], [1], 'A dangling pointer references memory that has been freed.'),
    ])

lesson(1, 18, 'Common C Errors',
    concept='Frequent C errors include segmentation faults, buffer overflows, uninitialized variables, memory leaks, and off-by-one errors.',
    definition='Common C errors fall into compile-time errors (syntax, type mismatches) and runtime errors (invalid memory access, logic errors).',
    explanation='Segmentation faults occur from dereferencing invalid pointers. Buffer overflows happen when writing past array bounds. Uninitialized variables contain garbage. Memory leaks accumulate when malloc is not paired with free. Defensive programming — checking returns, initializing variables, using bounds-checked functions — prevents most issues.',
    worked='// Common bug: off-by-one\nfor (int i = 0; i <= n; i++) sum += arr[i];  // arr[n] is out of bounds\n// Fix: i < n\n// Common bug: uninitialized pointer\nint *p; *p = 5;  // crash — p points nowhere',
    eng='Safety-critical firmware runs static analyzers (MISRA-C checkers) that flag these error classes before code ever reaches hardware.',
    mistakes='Ignoring compiler warnings; assuming arrays are bounds-checked; using gets() (removed from C11 for being unsafe).',
    practice=['What causes a segmentation fault?', 'How can you prevent buffer overflows?'],
    quiz=[
        q('What causes a segmentation fault in C?', ['Dereferencing an invalid pointer', 'Using too many variables', 'Missing semicolons', 'Slow loops'], [0], 'Invalid memory access causes segfaults.'),
        q('Which function was removed from C11 due to buffer overflow risk?', ['printf', 'gets', 'scanf', 'malloc'], [1], 'gets() has no bounds checking and was removed.'),
    ])

lesson(1, 19, 'Debugging',
    concept='Debugging C code uses tools like gdb, printf tracing, static analysis, and valgrind to find and fix defects.',
    definition='Debugging is the process of identifying, isolating, and fixing defects in code using systematic observation and tooling.',
    explanation='gdb allows setting breakpoints, stepping through code, and inspecting variables. printf debugging inserts tracing statements. Static analyzers find bugs without running code. Valgrind detects memory leaks and invalid accesses. A systematic approach — reproduce, isolate, fix, verify — is more effective than random changes.',
    worked='gdb ./program\n(gdb) break main\n(gdb) run\n(gdb) next        # step over\n(gdb) print x      # inspect variable\n(gdb) backtrace   # call stack',
    eng='Embedded developers use JTAG/SWD debuggers with hardware breakpoints to debug firmware on live microcontrollers where printf is unavailable.',
    mistakes='Changing code without understanding the bug; not reproducing the issue first; debugging optimized builds without symbols.',
    practice=['What does a breakpoint do?', 'What is printf debugging?'],
    quiz=[
        q('Which tool detects memory leaks in C?', ['gdb', 'valgrind', 'make', 'gcc'], [1], 'Valgrind tracks allocations and reports leaks.'),
        q('What does gdb\'s "break" command do?', ['Fixes bugs', 'Pauses execution at a point', 'Removes code', 'Speeds up the program'], [1], 'Breakpoints pause execution for inspection.'),
    ])

lesson(1, 20, 'C Programming Practice',
    concept='Mastery of C comes from writing programs that combine multiple concepts: control flow, functions, arrays, pointers, and file I/O.',
    definition='Practice consolidates knowledge by building complete programs that integrate language features into working solutions.',
    explanation='Effective practice progresses from small exercises (factorial, prime check) to integrated projects (student grade manager with file persistence). Each project should use functions for modularity, structs for data, pointers for efficiency, and files for persistence.',
    worked='Project: Student grade manager\n- struct Student { char name[50]; int scores[5]; float avg; }\n- Functions: add_student(), compute_average(), save_to_file()\n- Uses arrays of structs, file I/O, and pointer-based sorting',
    eng='Firmware projects like a temperature logger combine ADC reading (pointers to registers), circular buffers (arrays), and SD card logging (file I/O) in one program.',
    mistakes='Writing everything in main(); skipping error handling; not testing edge cases (empty input, max values).',
    practice=['Write a program that reverses a string in place using pointers.', 'Write a program that counts word frequency in a text file.'],
    quiz=[
        q('What is the best way to learn C effectively?', ['Reading only', 'Writing complete programs', 'Watching videos', 'Memorizing syntax'], [1], 'Active practice builds mastery.'),
        q('Which project combines arrays, structs, and file I/O?', ['Hello world', 'Student grade manager', 'Single printf', 'Empty main'], [1], 'A grade manager integrates multiple concepts.'),
    ])

# ---------------- C++ (18 lessons) ----------------

lesson(2, 1, 'Introduction to C++',
    concept='C++ is a multi-paradigm language extending C with object-oriented programming, templates, and the Standard Template Library (STL).',
    definition='C++ is a compiled, statically-typed language supporting procedural, object-oriented, and generic programming.',
    explanation='C++ adds classes, inheritance, polymorphism, templates, and exceptions to C. It maintains C\'s performance while adding abstraction mechanisms. Modern C++ (C++11 and later) adds smart pointers, lambdas, and move semantics for safer, more expressive code.',
    worked='#include <iostream>\nint main() {\n    std::cout << "Hello, C++!" << std::endl;\n    return 0;\n}',
    eng='Game engines, high-frequency trading systems, and performance-critical infrastructure rely on C++ for zero-cost abstractions.',
    mistakes='Using raw pointers instead of smart pointers; ignoring C++11+ features; compiling C code as C++ without changes.',
    practice=['What paradigms does C++ support?', 'How does C++ differ from C?'],
    quiz=[
        q('C++ extends which language?', ['Java', 'C', 'Python', 'Assembly'], [1], 'C++ began as "C with classes".'),
        q('Which header provides C++ stream output?', ['<stdio.h>', '<iostream>', '<ostream>', '<console>'], [1], 'iostream provides std::cout.'),
    ])

lesson(2, 2, 'Variables and Data Types',
    concept='C++ supports all C types plus bool, string (std::string), and auto type deduction, with stricter type safety than C.',
    definition='C++ data types include fundamental types (int, double, char, bool), compound types (arrays, pointers, references), and user-defined types (classes, enums).',
    explanation='C++ adds bool for boolean values and std::string for safe, dynamic strings. The auto keyword deduces types from initializers. References (&) provide aliases to existing variables without pointer syntax. C++ is stricter about implicit conversions than C.',
    worked='auto price = 19.99;        // deduced as double\nstd::string name = "Tommy"; // safe string\nint& ref = count;            // reference alias\nbool valid = true;',
    eng='Robotics code uses std::string for command parsing and auto for complex iterator types, reducing bugs from type mismatches.',
    mistakes='Confusing references with pointers; using C-style strings when std::string is safer; narrowing conversions in initialization.',
    practice=['What does auto do?', 'What is the difference between a reference and a pointer?'],
    quiz=[
        q('Which type represents true/false in C++?', ['int', 'bool', 'char', 'bit'], [1], 'bool is the boolean type.'),
        q('What does auto do in C++?', ['Makes variables constant', 'Deduces type from initializer', 'Allocates dynamically', 'Declares arrays'], [1], 'auto deduces the type from the initializer.'),
    ])

lesson(2, 3, 'Functions',
    concept='C++ functions support overloading, default arguments, pass-by-reference, and inline hints — improvements over C functions.',
    definition='A C++ function is a named block that can be overloaded (same name, different parameters), accept default arguments, and pass parameters by reference.',
    explanation='Function overloading allows multiple functions with the same name but different parameter lists. Default arguments let callers omit trailing parameters. Pass-by-reference (&) avoids copying and allows modification of arguments. inline suggests the compiler replace calls with the function body.',
    worked='int add(int a, int b) { return a + b; }\ndouble add(double a, double b) { return a + b; }  // overload\nvoid scale(int& x, int factor) { x *= factor; }  // by reference',
    eng='Math libraries overload operators and functions so the same code works with ints, floats, and custom matrix types.',
    mistakes='Overloading on return type only (illegal); default arguments in the definition (belong in declaration); passing large objects by value.',
    practice=['What is function overloading?', 'Why pass by reference instead of value?'],
    quiz=[
        q('Can two functions differ only by return type?', ['Yes', 'No', 'Only if inline', 'Only in classes'], [1], 'Overloading requires different parameter lists.'),
        q('How do you pass a parameter by reference in C++?', ['*', '&', '->', 'ref'], [1], '& declares a reference parameter.'),
    ])

lesson(2, 4, 'Classes',
    concept='A class is a user-defined type bundling data (members) and behavior (methods) with access control (public, private, protected).',
    definition='A class is a blueprint for objects that encapsulates state and operations, forming the foundation of object-oriented programming in C++.',
    explanation='Classes group related variables and functions. public members are accessible anywhere; private members are accessible only within the class; protected members are accessible in derived classes. This encapsulation hides implementation details and exposes a controlled interface.',
    worked='class Circle {\nprivate:\n    double radius;\npublic:\n    Circle(double r) : radius(r) {}\n    double area() const { return 3.14159 * radius * radius; }\n};',
    eng='Hardware abstraction layers define classes like GpioPin with private register addresses and public methods set()/read(), hiding hardware complexity.',
    mistakes='Leaving data members public (breaking encapsulation); forgetting the semicolon after the class definition; confusing class with object.',
    practice=['What is encapsulation?', 'What is the difference between a class and an object?'],
    quiz=[
    q('Which access specifier hides members from outside code?', ['public', 'private', 'protected', 'internal'], [1], 'private restricts access to the class itself.'),
        q('A class is a:', ['Variable', 'Blueprint for objects', 'Function', 'Namespace'], [1], 'Classes define the structure; objects are instances.'),
    ])

lesson(2, 5, 'Objects',
    concept='An object is an instance of a class — a concrete entity with its own state created from the class blueprint.',
    definition='An object is a runtime instance of a class, occupying memory with its own copy of member variables.',
    explanation='Objects are created by declaring a variable of a class type or with new. Each object has independent member variables. Objects interact by calling each other\'s public methods. The this pointer inside a method refers to the current object.',
    worked='Circle c1(5.0);        // object on stack\nCircle* c2 = new Circle(3.0);  // object on heap\ndouble a = c1.area();       // 78.54\ndelete c2;                   // free heap object',
    eng='Each sensor driver object (e.g., TemperatureSensor) encapsulates its own calibration data and I2C address while sharing the same class code.',
    mistakes='Forgetting delete for new (memory leak); confusing class static members with object members; slicing derived objects.',
    practice=['How do you create an object on the heap?', 'What is the this pointer?'],
    quiz=[
        q('How is an object created on the heap in C++?', ['new', 'malloc only', 'stack()', 'create'], [0], 'new allocates and constructs heap objects.'),
        q('What does the this pointer refer to?', ['The class', 'The current object', 'The parent', 'A static member'], [1], 'this points to the current object instance.'),
    ])

lesson(2, 6, 'Constructors',
    concept='A constructor is a special member function that initializes objects when they are created. C++ supports default, parameterized, copy, and move constructors.',
    definition='A constructor is a member function with the same name as the class that runs automatically on object creation to initialize state.',
    explanation='The default constructor takes no arguments. Parameterized constructors accept initialization values. Copy constructors duplicate an object. Move constructors (C++11) transfer resources from temporary objects. Member initializer lists initialize members before the body runs.',
    worked='class Point {\n    int x, y;\npublic:\n    Point() : x(0), y(0) {}              // default\n    Point(int x, int y) : x(x), y(y) {}  // parameterized\n};',
    eng='Resource-managing classes (file handles, network sockets) use constructors to acquire resources and destructors to release them (RAII).',
    mistakes='Forgetting to initialize members (garbage values); not defining a default constructor when needed; expensive operations in initializer lists.',
    practice=['What is a copy constructor?', 'What is RAII?'],
    quiz=[
        q('When does a constructor run?', ['On object creation', 'On program exit', 'On function call', 'Manually'], [0], 'Constructors run automatically at creation.'),
        q('What is the initializer list after the constructor colon for?', ['Nothing', 'Initializing members before the body', 'Declaring parameters', 'Inheritance only'], [1], 'Initializer lists directly initialize members.'),
    ])

lesson(2, 7, 'Inheritance',
    concept='Inheritance lets a derived class reuse and extend a base class, establishing an "is-a" relationship between types.',
    definition='Inheritance is a mechanism where a new class (derived) acquires properties and behaviors from an existing class (base).',
    explanation='The derived class inherits base members and can add new ones or override existing ones. Access specifiers control inheritance visibility: public inheritance preserves access levels. Constructors of the base run before the derived. Inheritance models hierarchical relationships.',
    worked='class Animal {\npublic:\n    void speak() { std::cout << "..."; }\n};\nclass Dog : public Animal {\npublic:\n    void speak() { std::cout << "Woof"; }  // override\n};',
    eng='GUI frameworks use inheritance: Button and Slider derive from a common Widget base, sharing event handling while customizing rendering.',
    mistakes='Using inheritance for "has-a" relationships (use composition); hiding base methods unintentionally; deep inheritance hierarchies.',
    practice=['What is the difference between inheritance and composition?', 'What does "is-a" mean?'],
    quiz=[
        q('Inheritance models which relationship?', ['has-a', 'is-a', 'uses-a', 'contains-a'], [1], 'Inheritance models "is-a" (Dog is an Animal).'),
        q('Which keyword makes a derived class?', ['extends', ':', 'inherits', 'using'], [1], 'class Dog : public Animal declares inheritance.'),
    ])

lesson(2, 8, 'Polymorphism',
    concept='Polymorphism allows objects of different classes to be treated uniformly through a common interface, with the correct method selected at runtime.',
    definition='Polymorphism is the ability to present the same interface for different underlying forms, achieved in C++ via virtual functions and overriding.',
    explanation='A virtual function in the base class can be overridden in derived classes. Calling through a base pointer or reference dispatches to the derived implementation (dynamic dispatch). Pure virtual functions (= 0) make a class abstract — it cannot be instantiated.',
    worked='class Shape {\npublic:\n    virtual double area() const = 0;  // pure virtual\n};\nclass Circle : public Shape {\n    double area() const override { return 3.14159 * r * r; }\n};',
    eng='Plugin architectures store base-class pointers (e.g., IPlugin*) and call virtual methods, allowing new plugin types without changing core code.',
    mistakes='Forgetting virtual on the base method (static dispatch); slicing derived objects into base values; calling virtual functions in constructors.',
    practice=['What makes a function virtual?', 'What is an abstract class?'],
    quiz=[
        q('Which keyword enables runtime polymorphism in C++?', ['static', 'virtual', 'const', 'inline'], [1], 'virtual enables dynamic dispatch.'),
        q('What does = 0 after a virtual function mean?', ['Returns zero', 'Pure virtual — must be overridden', 'Default implementation', 'Deleted function'], [1], 'Pure virtual functions make the class abstract.'),
    ])

lesson(2, 9, 'Encapsulation',
    concept='Encapsulation bundles data with the methods that operate on it and restricts direct access to internal state through access specifiers.',
    definition='Encapsulation is the bundling of data and behavior into a single unit with controlled access to internal state.',
    explanation='Private members hide implementation details. Public getter and setter methods control how external code reads and modifies state, enabling validation and invariants. Encapsulation reduces coupling: internal changes don\'t affect code that uses the class.',
    worked='class BankAccount {\nprivate:\n    double balance;\npublic:\n    void deposit(double amount) {\n        if (amount > 0) balance += amount;\n    }\n    double getBalance() const { return balance; }\n};',
    eng='Driver classes encapsulate hardware registers: users call sensor.read() while the class hides volatile pointer arithmetic and timing details.',
    mistakes='Public data members; setters without validation; getters returning references to private members.',
    practice=['Why use getters and setters instead of public members?', 'What invariant can encapsulation protect?'],
    quiz=[
        q('Which access level best supports encapsulation?', ['public', 'private', 'global', 'friend'], [1], 'private hides internal state.'),
        q('What is the benefit of encapsulation?', ['Faster code', 'Controlled access and maintainability', 'Less memory', 'Automatic threading'], [1], 'Encapsulation protects invariants and reduces coupling.'),
    ])

lesson(2, 10, 'Templates',
    concept='Templates enable generic programming: writing code that works with any type, with the compiler generating type-specific versions.',
    definition='A template is a blueprint for generating functions or classes parameterized by types or values.',
    explanation='Function templates deduce types from arguments. Class templates take explicit type parameters. Templates are resolved at compile time, so they add no runtime cost. The STL is built entirely on templates (vector<T>, sort<T>, etc.).',
    worked='template <typename T>\nT maximum(T a, T b) {\n    return (a > b) ? a : b;\n}\nint m = maximum(3, 7);        // T = int\ndouble d = maximum(1.5, 2.5); // T = double',
    eng='Embedded template libraries provide type-safe, zero-overhead abstractions like StaticVector<T, N> that replace dynamic containers in safety-critical code.',
    mistakes='Assuming templates work like runtime generics (they\'re compile-time); putting template definitions in .cpp files (must be in headers); overusing templates for simple cases.',
    practice=['When are templates instantiated?', 'What is the difference between typename and class in templates?'],
    quiz=[
        q('When are C++ templates resolved?', ['Runtime', 'Compile time', 'Link time', 'Never'], [1], 'Templates are instantiated at compile time.'),
        q('What does template <typename T> declare?', ['A class', 'A generic type parameter', 'A function', 'A macro'], [1], 'typename T declares a type parameter.'),
    ])

lesson(2, 11, 'STL — Standard Template Library',
    concept='The STL provides reusable, tested containers (vector, map, set), algorithms (sort, find), and iterators that work across containers.',
    definition='The STL is a library of generic containers, algorithms, and iterators following consistent design principles.',
    explanation='Containers store data (vector for dynamic arrays, map for key-value pairs, set for unique sorted values). Algorithms operate on containers through iterators without knowing the container type. Iterators generalize pointers, providing a uniform traversal interface.',
    worked='#include <vector>\n#include <algorithm>\nstd::vector<int> v = {5, 2, 8, 1};\nstd::sort(v.begin(), v.end());  // {1, 2, 5, 8}\nauto it = std::find(v.begin(), v.end(), 5);',
    eng='Data processing pipelines use STL containers and algorithms to filter, sort, and transform sensor data with minimal custom code.',
    mistakes='Using raw arrays when vector fits; invalidating iterators by modifying containers; ignoring algorithm complexity.',
    practice=['What is an iterator?', 'When would you use a map instead of a vector?'],
    quiz=[
        q('Which STL container stores key-value pairs?', ['vector', 'map', 'set', 'list'], [1], 'std::map stores key-value pairs.'),
        q('What does std::sort need to sort?', ['Only arrays', 'Begin and end iterators', 'A size only', 'Pointers only'], [1], 'Algorithms work on iterator ranges.'),
    ])

lesson(2, 12, 'Vectors',
    concept='std::vector is a dynamic array that grows automatically, providing contiguous storage with O(1) amortized push_back.',
    definition='std::vector is a sequence container representing a dynamic array that can change size, storing elements contiguously.',
    explanation='vector manages its own memory: it allocates capacity, grows geometrically (usually doubling) when full, and provides random access. Elements are contiguous, so vector is cache-friendly. reserve() preallocates to avoid reallocations.',
    worked='std::vector<int> scores;\nscores.push_back(85);\nscores.push_back(92);\nfor (size_t i = 0; i < scores.size(); i++)\n    std::cout << scores[i];',
    eng='Sample buffers use std::vector<float> for FFT input, benefiting from contiguous memory and automatic growth.',
    mistakes='Using push_back in loops without reserve (repeated reallocations); storing pointers to elements across growth; confusing size() with capacity().',
    practice=['What is the difference between size() and capacity()', 'Why is vector contiguous?'],
    quiz=[
        q('How does vector grow when full?', ['It doesn\'t', 'Allocates a larger buffer and copies', 'Throws immediately', 'Uses linked nodes'], [1], 'Vector reallocates with geometric growth.'),
        q('What is the time complexity of push_back (amortized)?', ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'], [1], 'Amortized constant time due to geometric growth.'),
    ])

lesson(2, 13, 'Maps',
    concept='std::map stores sorted key-value pairs with O(log n) lookup; std::unordered_map provides O(1) average lookup via hashing.',
    definition='A map is an associative container storing unique keys mapped to values, ordered by key (map) or hashed (unordered_map).',
    explanation='std::map is typically a red-black tree: keys stay sorted, operations are O(log n). std::unordered_map uses a hash table: average O(1) lookup but no ordering. Use map when you need ordered traversal; unordered_map when lookup speed matters most.',
    worked='std::map<std::string, int> ages;\nages["Tommy"] = 20;\nages["Ada"] = 22;\nauto it = ages.find("Tommy");  // O(log n)',
    eng='Configuration systems use maps to store settings (name → value) with guaranteed ordering for display and serialization.',
    mistakes='Using operator[] to check existence (it inserts!); assuming unordered_map iteration order; storing large keys.',
    practice=['What is the difference between map and unordered_map?', 'Why does operator[] insert missing keys?'],
    quiz=[
        q('What structure backs std::map?', ['Hash table', 'Red-black tree', 'Array', 'Linked list'], [1], 'map is a balanced binary search tree.'),
        q('Which map variant offers O(1) average lookup?', ['map', 'unordered_map', 'set', 'vector'], [1], 'unordered_map uses hashing.'),
    ])

lesson(2, 14, 'Pointers and Smart Pointers',
    concept='C++ smart pointers (unique_ptr, shared_ptr, weak_ptr) automatically manage memory, preventing leaks and dangling pointers.',
    definition='Smart pointers are RAII wrapper classes that own and automatically release dynamically allocated memory.',
    explanation='unique_ptr has exclusive ownership — it deletes the object when it goes out of scope and cannot be copied. shared_ptr uses reference counting for shared ownership. weak_ptr observes a shared_ptr without affecting the count, breaking cycles. Modern C++ prefers smart pointers over raw new/delete.',
    worked='std::unique_ptr<Circle> c = std::make_unique<Circle>(5.0);\nstd::shared_ptr<Shape> s = std::make_shared<Circle>(3.0);\n// no manual delete needed',
    eng='Resource-heavy objects (file handles, network connections) are managed with unique_ptr, guaranteeing cleanup even when exceptions occur.',
    mistakes='Mixing raw new with smart pointers; circular shared_ptr references (memory leak); using shared_ptr when unique_ptr suffices.',
    practice=['What is the difference between unique_ptr and shared_ptr?', 'What problem does weak_ptr solve?'],
    quiz=[
        q('Which smart pointer has exclusive ownership?', ['shared_ptr', 'unique_ptr', 'weak_ptr', 'auto_ptr'], [1], 'unique_ptr is move-only with sole ownership.'),
        q('What does shared_ptr use to track ownership?', ['Stack depth', 'Reference counting', 'Garbage collection', 'Manual flags'], [1], 'shared_ptr counts references.'),
    ])

lesson(2, 15, 'Memory Management',
    concept='C++ memory management combines stack (automatic), heap (smart pointers), and static storage, with RAII as the core idiom.',
    definition='C++ memory management uses RAII (Resource Acquisition Is Initialization) to tie resource lifetime to object lifetime.',
    explanation='RAII means resources are acquired in constructors and released in destructors. Stack objects clean up automatically. Heap objects are managed by smart pointers. This makes code exception-safe: stack unwinding destroys objects and releases resources even when exceptions propagate.',
    worked='void process() {\n    std::unique_ptr<Buffer> buf = std::make_unique<Buffer>(1024);\n    // use buf\n}  // buf deleted automatically here, even if an exception occurs',
    eng='Firmware and game engines use custom allocators (pool, stack allocators) with RAII wrappers for deterministic, fragmentation-free memory.',
    mistakes='Manual new/delete in modern code; returning raw pointers from factories; ignoring exception safety.',
    practice=['What is RAII?', 'Why prefer stack allocation?'],
    quiz=[
        q('What does RAII stand for?', ['Random Access Is Initialization', 'Resource Acquisition Is Initialization', 'Runtime Allocation Is Immediate', 'Reference And Instance Integrity'], [1], 'RAII ties resources to object lifetime.'),
        q('When is a stack object destroyed?', ['At program end', 'When it goes out of scope', 'Never', 'On delete'], [1], 'Stack objects are destroyed at scope exit.'),
    ])

lesson(2, 16, 'Exception Handling',
    concept='C++ exceptions (try, catch, throw) separate error handling from normal logic, propagating errors up the call stack.',
    definition='Exception handling is a mechanism for transferring control to a handler when an error condition occurs.',
    explanation='throw raises an exception. try blocks contain code that might throw. catch blocks handle specific exception types. Exceptions unwind the stack, destroying local objects. Catch by const reference. Use exceptions for exceptional conditions, not normal control flow.',
    worked='double divide(double a, double b) {\n    if (b == 0) throw std::invalid_argument("Division by zero");\n    return a / b;\n}\ntry { divide(1, 0); }\ncatch (const std::exception& e) { std::cout << e.what(); }',
    eng='Parsing libraries throw typed exceptions (ParseError, ValidationError) that UI layers catch to display user-friendly messages.',
    mistakes='Catching by value (slicing); throwing in destructors; using exceptions for normal flow; empty catch blocks.',
    practice=['Why catch by const reference?', 'What happens to local objects when an exception is thrown?'],
    quiz=[
        q('Which keyword raises an exception?', ['try', 'catch', 'throw', 'finally'], [2], 'throw raises an exception.'),
        q('How should exceptions be caught?', ['By value', 'By const reference', 'By pointer only', 'By macro'], [1], 'Catch by const reference avoids slicing.'),
    ])

lesson(2, 17, 'File Handling',
    concept='C++ file I/O uses streams: ifstream for input, ofstream for output, fstream for both, with RAII-based automatic closing.',
    definition='C++ file handling uses stream classes that wrap file operations with type-safe extraction and insertion operators.',
    explanation='ifstream/ofstream/fstream open files in their constructors and close them in destructors (RAII). The >> and << operators provide formatted I/O. Files can be opened in modes (in, out, app, binary). Always verify the stream state after opening.',
    worked='#include <fstream>\nstd::ofstream out("data.txt");\nif (out.is_open()) {\n    out << "Temperature: " << 23.5 << "\\n";\n}  // closed automatically',
    eng='Configuration and logging systems use ofstream to write structured data files that persist across program restarts.',
    mistakes='Not checking if the file opened; forgetting to flush/close explicitly (destructor handles it); mixing text and binary modes.',
    practice=['What stream reads files?', 'How does RAII help with file handling?'],
    quiz=[
        q('Which class reads from files?', ['ofstream', 'ifstream', 'fstream', 'iostream'], [1], 'ifstream is the input file stream.'),
        q('When does an ofstream close its file?', ['Never', 'When the object is destroyed', 'Only on close()', 'At program start'], [1], 'The destructor closes the file.'),
    ])

lesson(2, 18, 'OOP Practice',
    concept='C++ mastery comes from designing class hierarchies that model real problems with encapsulation, inheritance, and polymorphism.',
    definition='OOP practice involves designing and implementing class systems that solve problems using object-oriented principles.',
    explanation='Good OOP design favors composition over inheritance, programs to interfaces (abstract base classes), and keeps classes small and focused. Practice projects: a shape hierarchy with virtual area(), a bank account system with inheritance, a game entity component system.',
    worked='Project: Shape hierarchy\n- Abstract Shape with virtual area() and perimeter()\n- Circle, Rectangle, Triangle derived classes\n- std::vector<std::unique_ptr<Shape>> collection\n- Polymorphic iteration computing total area',
    eng='Game engines model entities as objects with component inheritance, enabling code reuse across character types.',
    mistakes='God classes with too many responsibilities; deep inheritance trees; exposing internals.',
    practice=['Design a class hierarchy for vehicles.', 'Implement a simple bank account system with inheritance.'],
    quiz=[
        q('What principle favors composing objects over inheriting?', ['Encapsulation', 'Composition over inheritance', 'Polymorphism', 'Abstraction'], [1], 'Favor composition over inheritance.'),
        q('What is a god class?', ['A small class', 'A class with too many responsibilities', 'An abstract class', 'A template class'], [1], 'God classes violate single responsibility.'),
    ])

formula('Programming', 'Time Complexity (Big O)', 'T(n) = O(f(n))', 'T(n): operations for input size n', 'Algorithm analysis and comparison')
formula('Programming', 'Space Complexity', 'S(n) = O(g(n))', 'S(n): memory for input size n', 'Memory usage analysis')

reference('C', 'Basics', 'Hello World', '#include <stdio.h>\n\nint main() {\n    printf("Hello, World!\\n");\n    return 0;\n}')
reference('C', 'Variables', 'Variable Declaration', '#include <stdio.h>\n\nint main() {\n    int age = 20;\n    float gpa = 3.85;\n    char grade = \'A\';\n    printf("Age: %d, GPA: %.2f, Grade: %c\\n", age, gpa, grade);\n    return 0;\n}')
reference('C', 'Control Flow', 'If-Else Statement', '#include <stdio.h>\n\nint main() {\n    int score = 85;\n    if (score >= 90) {\n        printf("Grade: A\\n");\n    } else if (score >= 80) {\n        printf("Grade: B\\n");\n    } else {\n        printf("Grade: C\\n");\n    }\n    return 0;\n}')
reference('C', 'Loops', 'For Loop', '#include <stdio.h>\n\nint main() {\n    for (int i = 1; i <= 10; i++) {\n        printf("%d ", i);\n    }\n    printf("\\n");\n    return 0;\n}')
reference('C', 'Functions', 'Function Definition', '#include <stdio.h>\n\nint add(int a, int b) {\n    return a + b;\n}\n\nint main() {\n    int result = add(5, 3);\n    printf("Sum: %d\\n", result);\n    return 0;\n}')
reference('C', 'Arrays', 'Array Iteration', '#include <stdio.h>\n\nint main() {\n    int numbers[] = {10, 20, 30, 40, 50};\n    int sum = 0;\n    for (int i = 0; i < 5; i++) {\n        sum += numbers[i];\n    }\n    printf("Sum: %d\\n", sum);\n    return 0;\n}')
reference('C', 'Pointers', 'Pointer Basics', '#include <stdio.h>\n\nint main() {\n    int value = 42;\n    int *ptr = &value;\n    printf("Value: %d\\n", *ptr);\n    *ptr = 100;\n    printf("New value: %d\\n", value);\n    return 0;\n}')
reference('C', 'Structures', 'Struct Definition', '#include <stdio.h>\n\nstruct Student {\n    char name[50];\n    int age;\n    float gpa;\n};\n\nint main() {\n    struct Student s1 = {"Tommy", 20, 3.85};\n    printf("Name: %s, Age: %d, GPA: %.2f\\n", s1.name, s1.age, s1.gpa);\n    return 0;\n}')
reference('C++', 'Basics', 'Hello World', '#include <iostream>\n\nint main() {\n    std::cout << "Hello, C++!" << std::endl;\n    return 0;\n}')
reference('C++', 'Classes', 'Class Definition', '#include <iostream>\n#include <string>\n\nclass Student {\nprivate:\n    std::string name;\n    int age;\npublic:\n    Student(std::string n, int a) : name(n), age(a) {}\n    void display() {\n        std::cout << name << " is " << age << " years old." << std::endl;\n    }\n};\n\nint main() {\n    Student s("Tommy", 20);\n    s.display();\n    return 0;\n}')
reference('C++', 'Inheritance', 'Derived Class', '#include <iostream>\n\nclass Animal {\npublic:\n    virtual void speak() {\n        std::cout << "Animal sound" << std::endl;\n    }\n};\n\nclass Dog : public Animal {\npublic:\n    void speak() override {\n        std::cout << "Woof!" << std::endl;\n    }\n};\n\nint main() {\n    Animal* a = new Dog();\n    a->speak();\n    delete a;\n    return 0;\n}')
reference('C++', 'STL', 'Vector Usage', '#include <iostream>\n#include <vector>\n#include <algorithm>\n\nint main() {\n    std::vector<int> nums = {5, 2, 8, 1, 9};\n    std::sort(nums.begin(), nums.end());\n    for (int n : nums) {\n        std::cout << n << " ";\n    }\n    std::cout << std::endl;\n    return 0;\n}')
reference('C++', 'Templates', 'Function Template', '#include <iostream>\n\ntemplate <typename T>\nT maximum(T a, T b) {\n    return (a > b) ? a : b;\n}\n\nint main() {\n    std::cout << maximum(3, 7) << std::endl;\n    std::cout << maximum(3.14, 2.71) << std::endl;\n    return 0;\n}')
