import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/motivations.dart';
import '../../data/repositories/settings_repository.dart';

/// A daily motivational line, backed by the free keyless ZenQuotes API
/// (`/api/today` — quote of the day) with a per-day cache and a graceful fall
/// back to the curated local rotation when offline or rate-limited.
class MotivationService {
  MotivationService(this._repo, {http.Client? client})
    : _client = client ?? http.Client();

  static const endpoint = 'https://zenquotes.io/api/today';

  static const _kDate = 'zenQuoteDate';
  static const _kText = 'zenQuoteText';
  static const _kAuthor = 'zenQuoteAuthor';

  final SettingsRepository _repo;
  final http.Client _client;

  /// The line for today. Cached per calendar day, so the network is only hit
  /// once a day at most (ZenQuotes allows 5 requests / 30 s keyless).
  Future<Motivation> daily() async {
    final today = _stamp(DateTime.now());
    final cachedDate = await _repo.getSetting(_kDate);
    final cachedText = await _repo.getSetting(_kText);
    if (cachedDate == today && (cachedText?.isNotEmpty ?? false)) {
      final author = await _repo.getSetting(_kAuthor);
      return Motivation(
        cachedText!,
        author == null || author.isEmpty ? 'ZenQuotes' : author,
        source: 'zenquotes',
      );
    }
    try {
      final quote = await _fetchToday();
      await _repo.setSetting(_kDate, today);
      await _repo.setSetting(_kText, quote.text);
      await _repo.setSetting(_kAuthor, quote.author);
      return quote;
    } on Object {
      return Motivations.daily(DateTime.now());
    }
  }

  Future<Motivation> _fetchToday() async {
    final res = await _client
        .get(Uri.parse(endpoint))
        .timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) {
      throw StateError('zenquotes returned HTTP ${res.statusCode}');
    }
    return parseToday(jsonDecode(res.body));
  }

  /// Parses the ZenQuotes payload: a JSON array of `{"q": ..., "a": ...}`.
  static Motivation parseToday(Object? json) {
    if (json is! List || json.isEmpty) {
      throw const FormatException('unexpected zenquotes payload');
    }
    final first = json.first;
    final text = first is Map ? first['q'] : null;
    if (text is! String || text.trim().isEmpty) {
      throw const FormatException('missing quote text');
    }
    final author = first is Map ? first['a'] : null;
    final name = author is String && author.trim().isNotEmpty
        ? author.trim()
        : 'ZenQuotes';
    return Motivation(text.trim(), name, source: 'zenquotes');
  }

  static String _stamp(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
