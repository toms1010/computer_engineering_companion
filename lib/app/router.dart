/// Central route table.
///
/// Named routes rather than a scattering of inline `MaterialPageRoute`s, so
/// every destination is discoverable in one place and a dead link is a
/// compile-time-visible omission rather than a runtime surprise.
abstract final class AppRoutes {
  static const shell = '/';
  static const subject = '/subject';
  static const lesson = '/lesson';
  static const quiz = '/quiz';
  static const assistant = '/assistant';
  static const bookmarks = '/bookmarks';
  static const notes = '/notes';
  static const progress = '/progress';
  static const formulas = '/formulas';
  static const references = '/references';
  static const diagnostics = '/diagnostics';
  static const numberSystem = '/tools/number-system';
  static const binary = '/tools/binary';
  static const bitwise = '/tools/bitwise';
  static const electronics = '/tools/electronics';
  static const physics = '/tools/physics';
  static const networking = '/tools/networking';
  static const calculus = '/tools/calculus';
  static const cpuScheduling = '/tools/cpu-scheduling';
}

/// Keys used to pass arguments to a route.
///
/// A map of arguments is easy to get wrong; named keys are checked by the
/// analyser at the call site.
abstract final class RouteArgs {
  static const subject = 'subject';
  static const lesson = 'lesson';
  static const subjectId = 'subjectId';
  static const lessonId = 'lessonId';
  static const quizMode = 'quizMode';
  static const toolId = 'toolId';
}
