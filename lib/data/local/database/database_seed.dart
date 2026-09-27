import '../../../core/constants/app_constants.dart';

const seedQuestions = <Map<String, Object>>[
  {
    'id': 1,
    'subjectId': 3,
    'prompt': 'Which scheduler can preempt a running process?',
    'options': ['FCFS', 'SRTF', 'Non-preemptive SJF', 'FIFO'],
    'answers': [1],
    'type': 'multiple_choice',
    'explanation': 'SRTF is the preemptive version of SJF.'
  },
  {
    'id': 2,
    'subjectId': 4,
    'prompt': 'TCP provides reliable, ordered delivery.',
    'options': ['True', 'False'],
    'answers': [0],
    'type': 'true_false',
    'explanation': 'TCP uses acknowledgements and sequence numbers.'
  },
  {
    'id': 3,
    'subjectId': 1,
    'prompt': 'Which are valid C integer types?',
    'options': ['int', 'float', 'char', 'double'],
    'answers': [0, 2],
    'type': 'multiple_answer',
    'explanation': 'int and char are integer types.'
  },
];
List<Map<String, Object>> seededSubjects() => AppConstants.subjects
    .asMap()
    .entries
    .map((e) => <String, Object>{
          'id': e.key + 1,
          ...e.value,
          'completed_lessons': 0,
          'total_lessons': 4
        })
    .toList();
