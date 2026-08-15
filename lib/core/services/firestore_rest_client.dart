import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Minimal Firestore REST client for platforms where the cloud_firestore
/// plugin has no implementation (Linux/Windows desktop).
///
/// Talks to the same `users/<uid>/state/snapshot` document the plugin path
/// uses, so desktop and mobile devices share one cloud snapshot. Requests
/// authenticate with the Firebase ID token of the signed-in user, matching the
/// `firestore.rules` at the repo root.
class FirestoreRestClient {
  FirestoreRestClient(this.projectId, {http.Client? client})
    : _client = client ?? http.Client();

  static const _host = 'https://firestore.googleapis.com/v1';

  final String projectId;
  final http.Client _client;

  Uri _docUri(String uid) => Uri.parse(
    '$_host/projects/$projectId/databases/(default)/documents'
    '/users/$uid/state/snapshot',
  );

  /// Fetches the document for [uid]. Returns null when the document does not
  /// exist yet (HTTP 404) or is empty.
  Future<Map<String, Object?>?> getDocument(String uid, String idToken) async {
    final res = await _client.get(
      _docUri(uid),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw _httpError(res);
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final fields = body['fields'];
    return fields == null ? null : _decodeMap(fields as Map<String, dynamic>);
  }

  /// Creates or replaces the document for [uid] with [data] (upsert; mirrors
  /// the plugin's `set`).
  Future<void> setDocument(
    String uid,
    String idToken,
    Map<String, Object?> data,
  ) async {
    final res = await _client.patch(
      _docUri(uid),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fields': _encodeMap(data)}),
    );
    if (res.statusCode != 200) {
      throw _httpError(res);
    }
  }

  /// Encodes JSON-compatible values into Firestore REST `Value` protos.
  static Map<String, dynamic> _encode(Object? v) {
    if (v == null) return {'nullValue': null};
    if (v is int) return {'integerValue': '$v'};
    if (v is double) return {'doubleValue': '$v'};
    if (v is bool) return {'booleanValue': v};
    if (v is String) return {'stringValue': v};
    if (v is List) {
      return {
        'arrayValue': {
          'values': [for (final e in v) _encode(e)],
        },
      };
    }
    if (v is Map) {
      return {
        'mapValue': {
          'fields': {for (final e in v.entries) '${e.key}': _encode(e.value)},
        },
      };
    }
    throw ArgumentError.value(v, 'value', 'Unsupported Firestore value');
  }

  static Map<String, dynamic> _encodeMap(Map<String, Object?> m) => {
    for (final e in m.entries) e.key: _encode(e.value),
  };

  static Object? _decode(Map<String, dynamic> value) {
    if (value.containsKey('nullValue')) return null;
    if (value.containsKey('integerValue')) {
      return int.tryParse(value['integerValue'] as String);
    }
    if (value.containsKey('doubleValue')) {
      return double.tryParse(value['doubleValue'] as String);
    }
    if (value.containsKey('booleanValue')) return value['booleanValue'];
    if (value.containsKey('stringValue')) return value['stringValue'];
    if (value.containsKey('timestampValue')) {
      return value['timestampValue'];
    }
    if (value.containsKey('arrayValue')) {
      final inner = (value['arrayValue'] as Map<String, dynamic>)['values'];
      return (inner as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_decode)
          .toList();
    }
    if (value.containsKey('mapValue')) {
      final fields = (value['mapValue'] as Map<String, dynamic>)['fields'];
      return _decodeMap(fields as Map<String, dynamic>? ?? const {});
    }
    throw ArgumentError.value(value, 'value', 'Unsupported Firestore value');
  }

  static Map<String, Object?> _decodeMap(Map<String, dynamic> fields) => {
    for (final e in fields.entries)
      e.key: _decode(e.value as Map<String, dynamic>),
  };

  Exception _httpError(http.Response res) {
    String detail = res.body;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final err = body['error'] as Map<String, dynamic>?;
      if (err != null) {
        detail = '${err['message'] ?? res.body} (${err['status'] ?? ''})';
      }
    } catch (_) {
      // Keep the raw body below.
    }
    return HttpException(
      'Firestore ${res.request?.method ?? 'request'} returned '
      '${res.statusCode}: $detail',
    );
  }

  /// Releases the underlying HTTP client.
  void close() => _client.close();
}
