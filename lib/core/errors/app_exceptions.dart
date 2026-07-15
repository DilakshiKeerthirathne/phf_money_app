/// Thrown when user input fails a business rule (e.g. amount <= 0).
class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when a local storage operation fails.
class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() =>
      'Something went wrong while saving your data. Please try again.';
}
