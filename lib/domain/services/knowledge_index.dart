/// A piece of local knowledge the AI can retrieve.
///
/// Deliberately a plain, sendable shape (primitives only) so a batch of
/// documents can be handed to a background isolate to build an index
/// without blocking the UI thread.
class KnowledgeDocument {
  const KnowledgeDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.heading,
    required this.body,
    this.subject = '',
    this.formula = '',
  });

  /// Kind of source: `lesson`, `formula`, `reference`.
  final String id, type;

  /// Display title, kept out of the searchable body so a title match is
  /// weighted more heavily than an incidental mention.
  final String title;

  /// Short label for citations, e.g. a subject name.
  final String heading;

  /// The searchable prose.
  final String body;

  final String subject;

  /// Rendered formula, when the document has one.
  final String formula;

  /// Only primitives: this type is copied into an isolate.
  Map<String, String> toTransferable() => {
        'id': id,
        'type': type,
        'title': title,
        'heading': heading,
        'body': body,
        'subject': subject,
        'formula': formula,
      };

  static KnowledgeDocument fromTransferable(Map<String, Object?> map) =>
      KnowledgeDocument(
        id: map['id'] as String? ?? '',
        type: map['type'] as String? ?? '',
        title: map['title'] as String? ?? '',
        heading: map['heading'] as String? ?? '',
        body: map['body'] as String? ?? '',
        subject: map['subject'] as String? ?? '',
        formula: map['formula'] as String? ?? '',
      );
}

/// One scored search result.
class KnowledgeHit {
  const KnowledgeHit({
    required this.document,
    required this.score,
    this.snippet = '',
  });

  final KnowledgeDocument document;
  final double score;

  /// The most relevant passage, so the UI does not have to re-scan the body.
  final String snippet;

  String get citation =>
      document.heading.isEmpty ? document.title : '${document.heading} · ${document.title}';
}

/// A BM25 index over the local curriculum.
///
/// Built once, lazily, off the UI thread. The index is a plain map of
/// postings so it can cross an isolate boundary; scoring happens on the
/// reading isolate because it is cheap and happens per query.
///
/// BM25 is used rather than raw TF-IDF because it normalises for document
/// length: without it, long lessons dominate every ranking for short
/// technical terms.
class KnowledgeIndex {
  KnowledgeIndex._(this._postings, this._docLengths, this._documents,
      this._averageLength);

  final Map<String, _Postings> _postings;
  final List<int> _docLengths;
  final List<KnowledgeDocument> _documents;
  final double _averageLength;

  /// BM25 tuning. k1 controls term-frequency saturation, b controls how
  /// strongly length is penalised.
  static const double _k1 = 1.4;
  static const double _b = 0.72;

  int get documentCount => _documents.length;

  /// Builds the index. Pure and free of Flutter dependencies, so it can run
  /// in a background isolate via [buildIndexInIsolate].
  ///
  /// Postings are stored as a flat `[doc, weight, doc, weight, ...]` array
  /// because a `List<int>` crosses an isolate boundary, whereas a list of
  /// small custom classes does not.
  static Map<String, Object?> serializeIndex(
      List<Map<String, Object?>> documents) {
    final postings = <String, List<int>>{};
    final lengths = <int>[];

    for (var docIndex = 0; docIndex < documents.length; docIndex++) {
      final doc = KnowledgeDocument.fromTransferable(documents[docIndex]);
      final counts = _count(doc);
      lengths.add(counts.values.fold(0, (sum, c) => sum + c));
      for (final entry in counts.entries) {
        final packed = postings.putIfAbsent(entry.key, () => <int>[]);
        packed
          ..add(docIndex)
          ..add(entry.value);
      }
    }
    return {
      'postings': postings,
      'lengths': lengths,
      'documents': documents,
    };
  }

  /// Isolate entry point: raw maps in, serialised index out.
  static Map<String, Object?> buildIndexInIsolate(
          List<Map<String, Object?>> documents) =>
      serializeIndex(documents);

  /// Rehydrates a serialised index. Run once on the isolate that will query
  /// it, so scoring never re-parses the postings.
  static KnowledgeIndex deserialize(Map<String, Object?> raw) {
    final rawPostings = raw['postings'] as Map<String, Object?>? ?? const {};
    final postings = <String, _Postings>{};
    rawPostings.forEach((term, value) {
      final packed = (value as List<Object?>).cast<int>();
      final docs = <int>[];
      final weights = <int>[];
      for (var i = 0; i < packed.length; i += 2) {
        docs.add(packed[i]);
        weights.add(packed[i + 1]);
      }
      postings[term] = _Postings(docs, weights);
    });

    final lengths = (raw['lengths'] as List<Object?>? ?? const <Object?>[])
        .map((e) => (e as num).toInt())
        .toList(growable: false);
    final documents = rawDocuments(raw);

    final total = lengths.fold<int>(0, (sum, l) => sum + l);
    final average = lengths.isEmpty ? 1.0 : total / lengths.length;

    return KnowledgeIndex._(postings, lengths, documents, average);
  }

  static List<KnowledgeDocument> rawDocuments(Map<String, Object?> raw) {
    final list = raw['documents'] as List<Object?>? ?? const <Object?>[];
    return [
      for (final entry in list)
        KnowledgeDocument.fromTransferable(
            (entry as Map<Object?, Object?>).cast<String, Object?>()),
    ];
  }

  /// Ranks documents against [query].
  ///
  /// Falls back to substring matching when the query is a single term that
  /// tokenised out of the index, so a search for `O's` or `C++` still finds
  /// something instead of returning nothing.
  List<KnowledgeHit> search(String query, {int limit = 6}) {
    final terms = tokenize(query);
    if (terms.isEmpty) return const [];

    final scores = <int, double>{};
    final documentCount = _documents.length;
    if (documentCount == 0) return const [];

    for (final term in terms) {
      final posting = _postings[term];
      if (posting == null) continue;

      final idf = _idf(posting.documents.length, documentCount);
      final docs = posting.documents;
      final weights = posting.weights;
      for (var i = 0; i < docs.length; i++) {
        final docIndex = docs[i];
        final tf = weights[i];
        final length = _docLengths[docIndex];
        final norm = tf * (_k1 + 1) /
            (tf + _k1 * (1 - _b + _b * (length / _averageLength)));
        scores[docIndex] = (scores[docIndex] ?? 0) + (idf * norm);
      }
    }

    if (scores.isEmpty) return _substringFallback(query, limit);

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final entry in ranked.take(limit))
        KnowledgeHit(
          document: _documents[entry.key],
          score: entry.value,
          snippet: bestSnippet(_documents[entry.key], terms),
        ),
    ];
  }

  double _idf(int documentFrequency, int documentCount) {
    final ratio = documentFrequency / documentCount;
    final idf = (1 - ratio).abs();
    return idf < 0.02 ? 0.02 : idf * 2.2;
  }

  /// Last-resort matching for queries the tokenizer cannot represent.
  List<KnowledgeHit> _substringFallback(String query, int limit) {
    final needle = query.trim().toLowerCase();
    if (needle.length < 2) return const [];
    final hits = <KnowledgeHit>[];
    for (var i = 0; i < _documents.length; i++) {
      final doc = _documents[i];
      if (doc.title.toLowerCase().contains(needle) ||
          doc.body.toLowerCase().contains(needle)) {
        hits.add(KnowledgeHit(
          document: doc,
          score: doc.title.toLowerCase().contains(needle) ? 2 : 1,
          snippet: bestSnippet(doc, [needle]),
        ));
      }
      if (hits.length >= limit * 2) break;
    }
    return hits.take(limit).toList();
  }

  /// The passage with the densest concentration of query terms.
  static String bestSnippet(KnowledgeDocument document, List<String> terms) {
    final body = document.body.trim();
    if (body.isEmpty) return '';
    if (terms.isEmpty) return _clip(body, 220);

    final lower = body.toLowerCase();
    var bestStart = 0;
    var bestScore = -1;
    const window = 220;

    for (final term in terms) {
      final index = lower.indexOf(term);
      if (index < 0) continue;
      // Prefer a window that starts at a sentence boundary so the excerpt
      // does not begin mid-word.
      final boundary = body.lastIndexOf('. ', index);
      final start = boundary >= 0 && index - boundary < 90 ? boundary + 2 : index;
      final score = _countIn(body.substring(start, (start + window).clamp(0, body.length)), terms);
      if (score > bestScore) {
        bestScore = score;
        bestStart = start;
      }
    }
    if (bestScore < 0) return _clip(body, window);
    return _clip(body.substring(bestStart, (bestStart + window).clamp(0, body.length)), window);
  }

  static int _countIn(String text, List<String> terms) {
    final lower = text.toLowerCase();
    var count = 0;
    for (final term in terms) {
      var index = lower.indexOf(term);
      while (index >= 0) {
        count++;
        index = lower.indexOf(term, index + term.length);
      }
    }
    return count;
  }

  static String _clip(String text, int max) {
    if (text.length <= max) return text.trim();
    return '${text.substring(0, max).trimRight()}…';
  }

  /// Term frequencies for a document. Title and formula terms are counted
  /// more heavily, which is what makes a lesson titled "Deadlock" win for
  /// the query "deadlock".
  static Map<String, int> _count(KnowledgeDocument doc) {
    final counts = <String, int>{};
    for (final term in tokenize(doc.title)) {
      counts[term] = (counts[term] ?? 0) + 4;
    }
    for (final term in tokenize(doc.heading)) {
      counts[term] = (counts[term] ?? 0) + 2;
    }
    for (final term in tokenize(doc.formula)) {
      counts[term] = (counts[term] ?? 0) + 2;
    }
    for (final term in tokenize(doc.body)) {
      counts[term] = (counts[term] ?? 0) + 1;
    }
    return counts;
  }

  /// Lowercases, strips punctuation and splits on non-word characters.
  ///
  /// A small stop-word list is enough here: the corpus is engineering
  /// content, so removing only the true noise words avoids deleting
  /// meaningful terms like "state" or "process".
  static List<String> tokenize(String input) {
    if (input.isEmpty) return const [];
    final cleaned = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9+#]+'), ' ');
    final raw = cleaned.split(' ');
    final result = <String>[];
    for (final word in raw) {
      if (word.length < 2) continue;
      if (_stopWords.contains(word)) continue;
      result.add(word);
    }
    return result;
  }

  /// Kept small on purpose — see [tokenize].
  static const Set<String> _stopWords = {
    'the', 'and', 'for', 'are', 'was', 'but', 'not', 'you', 'all', 'can',
    'her', 'has', 'had', 'how', 'its', 'our', 'out', 'use', 'used', 'using',
    'what', 'when', 'where', 'which', 'who', 'why', 'with', 'this', 'that',
    'from', 'they', 'them', 'then', 'than', 'there', 'these', 'those', 'will',
    'would', 'should', 'could', 'about', 'into', 'over', 'such', 'some',
    'of', 'on', 'to', 'as', 'at', 'by', 'it', 'if',
    'does', 'did', 'doing', 'done', 'get', 'got', 'let', 'may', 'also',
  };
}

/// Parallel term-frequency lists for one term.
class _Postings {
  const _Postings(this.documents, this.weights);

  final List<int> documents;
  final List<int> weights;
}
