import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:simple_logger/simple_logger.dart';

pp(dynamic message) {
  if (isInDebugMode) {
    if (message is String) {
      debugPrint('${DateTime.now().toIso8601String()}: $message');
    } else {
      print(message);
    }
  }
}

bool get isInDebugMode {
  bool _inDebugMode = false;
  if (kDebugMode) {
    _inDebugMode = true;
  }

  return _inDebugMode;
}

bool get isInReleaseMode {
  bool _inReleaseMode = false;

  if (kReleaseMode) {
    _inReleaseMode = true;
  }

  return _inReleaseMode;
}

bool get isInProfileMode {
  bool _inProfileMode = false;
  if (kProfileMode) {
    _inProfileMode = true;
  }

  return _inProfileMode;
}

final penFinest = AnsiPen()
  ..white(bold: true)
  ..rgb(r: 0, g: 0, b: 153, bg: true);
final penFiner = AnsiPen()
  ..black(bold: true)
  ..rgb(r: 255, g: 255, b: 255, bg: true);
final penFine = AnsiPen()
  ..magenta(bold: true)
  ..rgb(r: 0, g: 0, b: 102, bg: true);
final penInfo = AnsiPen()
  ..cyan(bold: true)
  ..black(bg: true);
final penConfig = AnsiPen()
  ..blue(bold: true)
  ..red(bg: true);
final penWarning = AnsiPen()
  ..yellow(bold: true)
  ..black(bg: true);
final penSevere = AnsiPen()
  ..green(bold: true)
  ..rgb(r: 0, g: 51, b: 0, bg: true);
final penShout = AnsiPen()
  ..red(bold: true)
  ..black(bg: true);

final logger = SimpleLogger();

void initLog() {
  hierarchicalLoggingEnabled = true;
  if (isInDebugMode) {
    logger.setLevel(
      Level.INFO,
      // Includes  caller info, but this is expensive.
      includeCallerInfo: true,
    );

    Logger.root.onRecord.listen((record) {
      if (record.error != null && record.stackTrace != null) {
        // ignore: avoid_print
        print(
            '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}: ${record.error}: ${record.stackTrace}');
        // ignore: avoid_print
        print(
            'level: ${record.level.name} loggerName: ${record.loggerName} time: ${record.time} message: ${record.message} error: ${record.error} exception: ${record.stackTrace}');
      } else if (record.error != null) {
        // ignore: avoid_print
        print(
            'level: ${record.level.name} loggerName: ${record.loggerName} time: ${record.time} message: ${record.message} error: ${record.error}');
      } else {
        // ignore: avoid_print
        print(
            'level: ${record.level.name} loggerName: ${record.loggerName} time: ${record.time} message: ${record.message}');
      }
    });

    PrintAppender(formatter: const ColorFormatter())
        .attachToLogger(Logger.root);
  }

  if (isInReleaseMode) {
    logger.setLevel(
      Level.OFF,
      // Includes  caller info, but this is expensive.
      includeCallerInfo: false,
    );
  }

  logger.formatter = (info) => penInfo(info.message);
  logger.formatter = (shout) => penShout(shout.message);
  logger.formatter = (warning) => penWarning(warning.message);
  logger.formatter = (severe) => penSevere(severe.message);
  logger.formatter = (finest) => penFinest(finest.message);
  logger.formatter = (finer) => penFiner(finer.message);
  logger.formatter = (fine) => penFine(fine.message);
  logger.formatter = (config) => penConfig(config.message);
}
