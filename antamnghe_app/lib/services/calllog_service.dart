class CallLogService {
  CallLogService._private();

  static final CallLogService instance = CallLogService._private();

  Future<List<Map<String, dynamic>>> getAll() async {
    throw UnsupportedError(
      'Call logs are processed on-device only and are not available from the backend.',
    );
  }

  Future<Map<String, dynamic>> add(Map<String, dynamic> log) async {
    throw UnsupportedError(
      'Call logs stay on-device only and cannot be uploaded to the backend.',
    );
  }
}
