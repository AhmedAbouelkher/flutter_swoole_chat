class APIReqestError implements Exception {
  final Object? body;
  final int? statusCode;
  final String? message;
  APIReqestError({
    this.body,
    this.statusCode,
    this.message,
  });

  @override
  String toString() {
    return '''
    APIReqestError

    body: $body

    statusCode: $statusCode
    statusMessage: $message
    ''';
  }
}
