import 'dart:convert';

import 'package:http/http.dart' as http;

/// Runs Go code on the official Go Playground (go.dev/play).
class Playground {
  static final _base = Uri.parse('https://go.dev');

  static Future<RunResult> run(String code) async {
    final res = await http
        .post(
          _base.replace(path: '/_/compile'),
          body: {'version': '2', 'body': code, 'withVet': 'true'},
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Playground returned HTTP ${res.statusCode}');
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final events = (json['Events'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return RunResult(
      compileError: (json['Errors'] as String? ?? '').trim(),
      vetError: (json['VetErrors'] as String? ?? '').trim(),
      output: [
        for (final e in events)
          (text: e['Message'] as String? ?? '', isError: e['Kind'] == 'stderr'),
      ],
    );
  }

  /// Uploads the snippet and returns its go.dev/play URL.
  static Future<Uri> share(String code) async {
    final res = await http
        .post(_base.replace(path: '/_/share'), body: code)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Playground returned HTTP ${res.statusCode}');
    }
    return _base.replace(path: '/play/p/${res.body.trim()}');
  }
}

class RunResult {
  RunResult({
    required this.compileError,
    required this.vetError,
    required this.output,
  });

  final String compileError;
  final String vetError;
  final List<({String text, bool isError})> output;

  bool get failed => compileError.isNotEmpty;
}
