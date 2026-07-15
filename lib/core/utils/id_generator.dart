import 'package:uuid/uuid.dart';

/// Generates local-only unique IDs (no backend involved).
class IdGenerator {
  IdGenerator._();
  static const _uuid = Uuid();
  static String generate() => _uuid.v4();
}
