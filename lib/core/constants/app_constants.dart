class AppConstants {
  static const appName = 'Computer Engineering Companion';
  static const databaseName = 'engineering_companion.db';
  static const databaseVersion = 1;
  static const subjects = <Map<String, String>>[
    {
      'name': 'Programming',
      'category': 'Programming',
      'description': 'C • C++ • Python • Java',
      'icon': 'code'
    },
    {
      'name': 'Computer Architecture',
      'category': 'Hardware',
      'description': 'CPU • Memory • Instruction sets',
      'icon': 'memory'
    },
    {
      'name': 'Operating Systems',
      'category': 'Programming',
      'description': 'Processes • Memory • Filesystems',
      'icon': 'dns'
    },
    {
      'name': 'Computer Networks',
      'category': 'Networking',
      'description': 'OSI • TCP/IP • Subnetting',
      'icon': 'lan'
    },
    {
      'name': 'Digital Logic',
      'category': 'Hardware',
      'description': 'Gates • Boolean algebra • K-maps',
      'icon': 'account_tree'
    },
    {
      'name': 'Electronics',
      'category': 'Electronics',
      'description': 'Circuits • Components • Signals',
      'icon': 'bolt'
    },
    {
      'name': 'Embedded Systems',
      'category': 'Hardware',
      'description': 'GPIO • UART • Timers',
      'icon': 'developer_board'
    },
    {
      'name': 'Data Communications',
      'category': 'Networking',
      'description': 'Encoding • Media • Protocols',
      'icon': 'settings_input_antenna'
    },
    {
      'name': 'Signals and Systems',
      'category': 'Mathematics',
      'description': 'Transforms • Sampling • Filters',
      'icon': 'show_chart'
    },
    {
      'name': 'Engineering Mathematics',
      'category': 'Mathematics',
      'description': 'Calculus • Discrete math • Statistics',
      'icon': 'functions'
    },
  ];
  static const programmingLanguages = [
    'C',
    'C++',
    'Python',
    'Java',
    'Dart',
    'Embedded C'
  ];
}
