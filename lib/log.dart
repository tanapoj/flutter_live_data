import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as leisim;

class Logger implements leisim.Logger {
  static Logger? _instance;

  static Logger get instance {
    _instance ??= Logger();
    return _instance!;
  }

  static set instance(Logger newInstance) {
    _instance = newInstance;
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void d(message, [error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$message');
    }
  }

  @override
  void i(message, [error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$message');
    }
  }

  @override
  void e(message, [error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print(red(message));
    }
  }

  @override
  void log(leisim.Level level, message, [error, StackTrace? stackTrace]) {
    // TODO: implement log
  }

  @override
  void v(message, [error, StackTrace? stackTrace]) {
    // TODO: implement v
  }

  @override
  void w(message, [error, StackTrace? stackTrace]) {
    // TODO: implement w
  }

  @override
  void wtf(message, [error, StackTrace? stackTrace]) {
    // TODO: implement wtf
  }

  static String tag(String tag) {
    return '\x1B[34m$tag\x1B[0m';
  }

  static String red(String msg) {
    return '\x1B[31m$msg\x1B[0m';
  }
}
