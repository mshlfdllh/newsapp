class NewsException implements Exception {
  final String message;

  const NewsException(this.message);

  @override
  String toString() => message;
}
