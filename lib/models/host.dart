// host.dart
import 'summary.dart';
import 'service.dart';

class Host {
  final String ip;
  final String? org;
  final String? isp;
  final List<String> hostnames;
  final List<String> domains;
  final Geo? geo;
  final DateTime? lastUpdate;
  final Summary summary;
  final List<Service> services;
  final List<String> vulns;

  Host({
    required this.ip,
    this.org,
    this.isp,
    this.hostnames = const [],
    this.domains = const [],
    this.geo,
    this.lastUpdate,
    required this.summary,
    this.services = const [],
    this.vulns = const [],
  });

  factory Host.fromMap(Map<String, dynamic> m) => Host(
    ip: m['ip'] ?? '',
    org: m['org'],
    isp: m['isp'],
    hostnames: (m['hostnames'] as List? ?? []).cast<String>(),
    domains: (m['domains'] as List? ?? []).cast<String>(),
    geo: m['geo'] == null ? null : Geo.fromMap(m['geo']),
    lastUpdate: m['last_update'] == null
        ? null
        : DateTime.tryParse(m['last_update']),
    summary: Summary.fromMap((m['summary'] as Map?) ?? const {}),
    services: ((m['services'] as List?) ?? [])
        .map((e) => Service.fromMap(e))
        .toList(),
    vulns: ((m['vulns'] as List?) ?? []).cast<String>(),
  );
}

class Geo {
  final String? country, city;
  final double? lat, lon;
  Geo({this.country, this.city, this.lat, this.lon});
  factory Geo.fromMap(Map m) => Geo(
    country: m['country'],
    city: m['city'],
    lat: (m['lat'] as num?)?.toDouble(),
    lon: (m['lon'] as num?)?.toDouble(),
  );
}
