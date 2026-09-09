/// DATA
/// Typed exceptions thrown by the network layer so the Repository
/// (and ultimately the ViewModel) can show a sensible error message
/// instead of a raw stack trace.
class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() => '$prefix$message';
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, 'Error During Communication: ');
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, 'Invalid Input: ');
}
