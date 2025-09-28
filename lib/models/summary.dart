import 'package:flutter/foundation.dart';

@immutable
class Summary {
  final int openPortsCount;
  final List<int> openPorts;
  final String? topService;
  final String? webStack;
  final String? tlsSummary;
  final String? providerHint;
  final List<String> badges;
  final int riskScore;
  final List<String> exposureFlags;

  /// buckets por categoría -> lista de puertos
  final Map<String, List<int>> portBuckets;

  const Summary({
    this.openPortsCount = 0,
    this.openPorts = const [],
    this.topService,
    this.webStack,
    this.tlsSummary,
    this.providerHint,
    this.badges = const [],
    this.riskScore = 0,
    this.exposureFlags = const [],
    this.portBuckets = const {},
  });

  factory Summary.fromMap(Map m) {
    final bucketsRaw = Map<String, dynamic>.from(
      m['port_buckets'] as Map? ?? const {},
    );
    final bucketsParsed = <String, List<int>>{};
    for (final entry in bucketsRaw.entries) {
      final list = (entry.value as List? ?? [])
          .map((e) => (e as num?)?.toInt() ?? 0)
          .toList();
      bucketsParsed[entry.key] = list;
    }

    return Summary(
      openPortsCount: (m['open_ports_count'] as num?)?.toInt() ?? 0,
      openPorts: (m['open_ports'] as List? ?? [])
          .map((e) => (e as num?)?.toInt() ?? 0)
          .toList(),
      topService: m['top_service']?.toString(),
      webStack: m['web_stack']?.toString(),
      tlsSummary: m['tls_summary']?.toString(),
      providerHint: m['provider_hint']?.toString(),
      badges: (m['badges'] as List? ?? []).map((e) => e.toString()).toList(),
      riskScore: (m['risk_score'] as num?)?.toInt() ?? 0,
      exposureFlags: (m['exposure_flags'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      portBuckets: bucketsParsed,
    );
  }
}
