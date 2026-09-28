import 'package:computer_engineering_companion/domain/services/knowledge_index.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds an index from plain maps, exactly as the isolate entry point does.
KnowledgeIndex _build(List<Map<String, Object?>> docs) =>
    KnowledgeIndex.deserialize(KnowledgeIndex.serializeIndex(docs));

Map<String, Object?> _doc(
  String id,
  String title,
  String body, {
  String type = 'lesson',
  String heading = '',
  String formula = '',
}) =>
    KnowledgeDocument(
      id: id,
      type: type,
      title: title,
      heading: heading,
      body: body,
      formula: formula,
    ).toTransferable();

void main() {
  group('tokenize', () {
    test('lowercases and strips punctuation', () {
      expect(KnowledgeIndex.tokenize('Deadlock, Avoidance!'),
          ['deadlock', 'avoidance']);
    });

    test('drops stop words and single characters', () {
      expect(KnowledgeIndex.tokenize('the a of TCP'), ['tcp']);
    });

    test('keeps digits and operators that carry meaning', () {
      expect(KnowledgeIndex.tokenize('IEEE 802.11'), ['ieee', '802', '11']);
    });

    test('returns empty for an empty string', () {
      expect(KnowledgeIndex.tokenize(''), isEmpty);
    });
  });

  group('index and search', () {
    late KnowledgeIndex index;

    setUp(() {
      index = _build([
        _doc('lesson:1', 'Deadlock',
            'A deadlock is a state where processes hold resources and wait '
                'for each other forever. Prevent it with prevention, '
                'avoidance or detection.',
            heading: 'Operating Systems'),
        _doc('lesson:2', 'Banker’s algorithm',
            'The banker algorithm avoids deadlock by checking whether a '
                'resource request can be safely granted before allocating.',
            heading: 'Operating Systems'),
        _doc('lesson:3', 'Transmission control protocol',
            'TCP is a connection oriented transport protocol that provides '
                'reliable delivery using sequence numbers and acknowledgements.',
            heading: 'Networking'),
        _doc('formula:1', 'Ohm’s law', 'V = I x R', type: 'formula',
            heading: 'Electronics', formula: 'V = I * R'),
      ]);
    });

    test('builds an index with the expected document count', () {
      expect(index.documentCount, 4);
    });

    test('finds the relevant lesson by title', () {
      final hits = index.search('deadlock');
      expect(hits, isNotEmpty);
      expect(hits.first.document.title, 'Deadlock');
    });

    test('ranks the exact title match above a body-only mention', () {
      final hits = index.search('deadlock');
      // The banker lesson mentions "deadlock" in its body only.
      expect(hits.map((h) => h.document.title), contains('Banker’s algorithm'));
      expect(hits.indexWhere((h) => h.document.title == 'Deadlock'),
          lessThan(hits.indexWhere((h) => h.document.title == 'Banker’s algorithm')));
    });

    test('matches a networking query to the TCP lesson', () {
      final hits = index.search('reliable transport');
      expect(hits, isNotEmpty);
      expect(hits.first.document.title, contains('Transmission control'));
    });

    test('finds a formula by its expression', () {
      final hits = index.search('ohm');
      expect(hits.map((h) => h.document.title), contains('Ohm’s law'));
    });

    test('returns nothing for a term absent from the corpus', () {
      expect(index.search('photosynthesis'), isEmpty);
    });

    test('keeps operators so a language name is searchable', () {
      // The tokenizer preserves `+` and `#` so "C++" survives as one term
      // rather than being shredded into single characters.
      expect(KnowledgeIndex.tokenize('C++'), ['c++']);
      final cIndex = _build([
        _doc('reference:1', 'C++ templates',
            'A C++ template generates code for multiple types.', type: 'reference'),
      ]);
      expect(cIndex.search('C++').first.document.title, 'C++ templates');
    });

    test('returns empty for a query with nothing searchable in it', () {
      // Better an honest empty result than a fabricated match.
      expect(index.search('!!!'), isEmpty);
    });

    test('returns a snippet drawn from the body', () {
      final hits = index.search('sequence numbers');
      expect(hits, isNotEmpty);
      expect(hits.first.snippet, isNotEmpty);
    });

    test('respects the result limit', () {
      expect(index.search('deadlock resource protocol', limit: 2).length,
          lessThanOrEqualTo(2));
    });

    test('an empty query returns nothing rather than everything', () {
      expect(index.search('   '), isEmpty);
    });
  });

  group('round trip', () {
    test('serialize then deserialize preserves search behaviour', () {
      final docs = [
        _doc('lesson:1', 'Cache', 'A cache stores results to avoid recompute'),
        _doc('lesson:2', 'Disk', 'A disk stores data persistently'),
      ];
      final serialized = KnowledgeIndex.serializeIndex(docs);
      final restored = KnowledgeIndex.deserialize(serialized);
      expect(restored.documentCount, 2);
      expect(restored.search('cache').first.document.title, 'Cache');
    });

    test('the isolate entry point produces the same result', () {
      final docs = [
        _doc('lesson:1', 'Mutex', 'A mutex protects a critical section'),
      ];
      final viaHelper = KnowledgeIndex.buildIndexInIsolate(docs);
      final direct = KnowledgeIndex.serializeIndex(docs);
      expect(
        KnowledgeIndex.deserialize(viaHelper).search('mutex').first.document.title,
        KnowledgeIndex.deserialize(direct).search('mutex').first.document.title,
      );
    });
  });

  group('edge cases', () {
    test('an empty corpus returns no hits and does not divide by zero', () {
      final empty = _build([]);
      expect(empty.search('anything'), isEmpty);
      expect(empty.documentCount, 0);
    });

    test('a document with an empty body is still searchable by title', () {
      final index = _build([_doc('lesson:1', 'Multiprocessor', '')]);
      expect(index.search('multiprocessor').first.document.title,
          'Multiprocessor');
    });
  });
}
