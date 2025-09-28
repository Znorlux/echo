import 'package:flutter/foundation.dart';

@immutable
class HttpInfo {
  final String? server;
  final String? title;
  final int? status;
  final List<String> redirects;
  final Map<String, dynamic> headers;

  const HttpInfo({
    this.server,
    this.title,
    this.status,
    this.redirects = const [],
    this.headers = const {},
  });

  factory HttpInfo.fromMap(Map? m) {
    if (m == null) return const HttpInfo();
    return HttpInfo(
      server: m['server']?.toString(),
      title: m['title']?.toString(),
      status: (m['status'] is num) ? (m['status'] as num).toInt() : null,
      redirects: (m['redirects'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      headers: Map<String, dynamic>.from(m['headers'] as Map? ?? const {}),
    );
  }
}

/// Certificado + emisor/sujeto muy resumido
@immutable
class CertificateName {
  final String? cn; // Common Name
  const CertificateName({this.cn});
  factory CertificateName.fromMap(Map? m) =>
      CertificateName(cn: m?['CN']?.toString());
}

@immutable
class CertificateInfo {
  final CertificateName issuer;
  final CertificateName subject;
  final String? validFrom;
  final String? validTo;

  const CertificateInfo({
    this.issuer = const CertificateName(),
    this.subject = const CertificateName(),
    this.validFrom,
    this.validTo,
  });

  factory CertificateInfo.fromMap(Map? m) {
    final mm = (m ?? const {});
    return CertificateInfo(
      issuer: CertificateName.fromMap(mm['issuer'] as Map?),
      subject: CertificateName.fromMap(mm['subject'] as Map?),
      validFrom: mm['valid_from']?.toString(),
      validTo: mm['valid_to']?.toString(),
    );
  }
}

@immutable
class SslInfo {
  final List<String> versions; // p. ej. ["TLSv1.2", "TLSv1.3"]
  final List<String> alpn; // p. ej. ["h2", "http/1.1"]
  final CertificateInfo cert;

  const SslInfo({
    this.versions = const [],
    this.alpn = const [],
    this.cert = const CertificateInfo(),
  });

  factory SslInfo.fromMap(Map? m) {
    if (m == null) return const SslInfo();
    return SslInfo(
      versions: (m['versions'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      alpn: (m['alpn'] as List? ?? []).map((e) => e.toString()).toList(),
      cert: CertificateInfo.fromMap(m['cert'] as Map?),
    );
  }
}

/// Servicio/puerto descubierto
@immutable
class Service {
  final int port;
  final String transport; // "tcp" | "udp"
  final String? service; // nombre (http, ssh, etc.)
  final String product; // texto amigable (default: "No identificado")
  final String? version; // se castea a String
  final List<String> cpe;
  final int? fingerprints; // puede venir null
  final HttpInfo http;
  final SslInfo ssl;
  final List<String> rawTags;

  const Service({
    required this.port,
    required this.transport,
    this.service,
    this.product = 'No identificado',
    this.version,
    this.cpe = const [],
    this.fingerprints,
    this.http = const HttpInfo(),
    this.ssl = const SslInfo(),
    this.rawTags = const [],
  });

  factory Service.fromMap(Map m) {
    return Service(
      port: (m['port'] as num?)?.toInt() ?? 0,
      transport: m['transport']?.toString() ?? 'tcp',
      service: m['service']?.toString(),
      product: m['product']?.toString() ?? 'No identificado',
      version: m['version']?.toString(),
      cpe: (m['cpe'] as List? ?? []).map((e) => e.toString()).toList(),
      fingerprints: (m['fingerprints'] is num)
          ? (m['fingerprints'] as num).toInt()
          : null,
      http: HttpInfo.fromMap(m['http'] as Map?),
      ssl: SslInfo.fromMap(m['ssl'] as Map?),
      rawTags: (m['raw_tags'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
