import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/host.dart';
import '../models/service.dart';
import '../models/summary.dart';

class HostDetailScreen extends StatefulWidget {
  const HostDetailScreen({super.key});

  @override
  State<HostDetailScreen> createState() => _HostDetailScreenState();
}

class _HostDetailScreenState extends State<HostDetailScreen> {
  Host? _host;
  bool _loading = true;
  String? _error;
  bool _showAllVulns = false;

  String get _ip {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['ip'] is String) return args['ip'] as String;
    // si no te pasaron ip, usa la del ejemplo
    return '45.33.32.156';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHost();
    });
  }

  // =========================
  // MOCK: sin backend
  // =========================
  Future<void> _fetchHost() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // simula latencia
      await Future.delayed(const Duration(milliseconds: 600));
      final mock = _mockHostResponseFor(_ip);
      setState(() {
        _host = Host.fromMap(mock['data'] as Map<String, dynamic>);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _mockHostResponseFor(String ip) {
    // podrías tener distintos mocks por IP si quieres
    return {
      "data": {
        "ip": ip,
        "org": "Linode",
        "isp": "Akamai Connected Cloud",
        "hostnames": ["scanme.nmap.org"],
        "domains": ["nmap.org"],
        "geo": {
          "country": "United States",
          "city": "Fremont",
          "lat": 37.54827,
          "lon": -121.98857,
        },
        "last_update": "2025-09-27T14:57:39.932874",
        "summary": {
          "open_ports_count": 5,
          "open_ports": [22, 80, 123, 9929, 31337],
          "top_service": "https-simple-new",
          "web_stack": "Apache/2.4.7 (Ubuntu)",
          "tls_summary": null,
          "provider_hint": null,
          "badges": ["web"],
          "risk_score": 40,
          "exposure_flags": ["remote_access_exposed", "unencrypted_web"],
          "port_buckets": {
            "web": [80],
            "db": [],
            "remote_access": [22],
            "mail": [],
            "dns": [],
            "other": [123, 9929, 31337],
          },
        },
        "services": [
          {
            "port": 22,
            "transport": "tcp",
            "service": "OpenSSH",
            "product": "OpenSSH",
            "version": "6.6.1 Ubuntu",
            "cpe": [
              "cpe:/a:openbsd:openssh:6.6.1p1",
              "cpe:/o:canonical:ubuntu_linux",
            ],
            "fingerprints": -145740310,
            "http": null,
            "ssl": null,
            "raw_tags": ["cloud"],
          },
          {
            "port": 80,
            "transport": "tcp",
            "service": "Apache httpd",
            "product": "Apache httpd",
            "version": "2.4.7",
            "cpe": [
              "cpe:/a:apache:http_server:2.4.7",
              "cpe:/o:canonical:ubuntu_linux",
            ],
            "fingerprints": 173770629,
            "http": {
              "server": "Apache/2.4.7 (Ubuntu)",
              "title": "Go ahead and ScanMe!",
              "status": 200,
              "redirects": [],
              "headers": {},
            },
            "ssl": null,
            "raw_tags": ["cloud"],
          },
          {
            "port": 123,
            "transport": "udp",
            "service": "ntp",
            "product": null,
            "version": 1.2,
            "cpe": [],
            "fingerprints": 1863949623,
            "http": null,
            "ssl": null,
            "raw_tags": ["cloud"],
          },
          {
            "port": 9929,
            "transport": "tcp",
            "service": "sftpserver",
            "product": null,
            "version": 1.2,
            "cpe": [],
            "fingerprints": 323137400,
            "http": null,
            "ssl": null,
            "raw_tags": ["cloud"],
          },
          {
            "port": 31337,
            "transport": "tcp",
            "service": "https-simple-new",
            "product": null,
            "version": null,
            "cpe": [],
            "fingerprints": null,
            "http": null,
            "ssl": null,
            "raw_tags": ["cloud"],
          },
        ],
        "vulns": [
          "CVE-2014-0117",
          "CVE-2017-7679",
          "CVE-2017-9798",
          "CVE-2015-3185",
          "CVE-2015-3184",
          "CVE-2015-3183",
          "CVE-2013-4365",
          "CVE-2022-28330",
          "CVE-2021-32791",
          "CVE-2021-32792",
          "CVE-2023-31122",
          "CVE-2024-38476",
          "CVE-2024-38477",
          "CVE-2024-38474",
          "CVE-2024-38475",
          "CVE-2024-38472",
          "CVE-2024-38473",
          "CVE-2009-0796",
          "CVE-2014-0118",
          "CVE-2022-31813",
          "CVE-2020-1927",
          "CVE-2011-2688",
          "CVE-2017-3167",
          "CVE-2023-38709",
          "CVE-2021-32786",
          "CVE-2021-32785",
          "CVE-2007-4723",
          "CVE-2021-44790",
          "CVE-2016-4975",
          "CVE-2020-13938",
          "CVE-2020-35452",
          "CVE-2022-22719",
          "CVE-2024-47252",
          "CVE-2020-1934",
          "CVE-2021-34798",
          "CVE-2019-0217",
          "CVE-2024-24795",
          "CVE-2014-3523",
        ],
      },
    };
  }

  Future<void> _addToFavorites() async {
    if (!mounted || _host == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardado en favoritos (mock)')),
    );
  }

  Color _riskColor(num? score) {
    final s = (score ?? 0).toDouble();
    if (s >= 80) return Colors.redAccent;
    if (s >= 60) return Colors.deepOrange;
    if (s >= 40) return Colors.orange;
    if (s >= 20) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  Widget _chip(
    String text, {
    IconData? icon,
    Color? color,
    bool noMargin = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // El chip no podrá ser más ancho que el espacio disponible en la fila/wrap
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: noMargin
                ? EdgeInsets.zero
                : const EdgeInsets.only(right: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: (color ?? Colors.greenAccent).withValues(alpha: 0.7),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: PhosphorIcon(
                      icon,
                      size: 16,
                      color: color ?? Colors.greenAccent,
                    ),
                  ),
                // ⬇️ Esto evita el overflow
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // si prefieres 2 líneas, pon 2
                    style: TextStyle(
                      color: color ?? Colors.greenAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          if (icon != null)
            PhosphorIcon(icon, color: Colors.greenAccent, size: 18),
          if (icon != null) const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  Widget _header(Host h) {
    final hostnames = h.hostnames;
    final domains = h.domains;
    final geo = h.geo;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PhosphorIcon(
                PhosphorIconsFill.desktopTower,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.ip,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((h.org ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _chip(
                              'ORG: ${h.org}',
                              icon: PhosphorIconsRegular.buildings,
                              noMargin: true,
                            ),
                          ),
                        if ((h.isp ?? '').isNotEmpty)
                          _chip(
                            'ISP: ${h.isp}',
                            icon: PhosphorIconsRegular.globe,
                            noMargin: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (hostnames.isNotEmpty || domains.isNotEmpty)
            Wrap(
              runSpacing: 6,
              spacing: 6,
              children: [
                if (hostnames.isNotEmpty)
                  _chip(
                    'hostnames: ${hostnames.join(', ')}',
                    icon: PhosphorIconsRegular.identificationCard,
                  ),
                if (domains.isNotEmpty)
                  _chip(
                    'domains: ${domains.join(', ')}',
                    icon: PhosphorIconsRegular.at,
                  ),
              ],
            ),

          if (geo != null) ...[
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 6,
              spacing: 6,
              children: [
                if (geo.country != null)
                  _chip(geo.country!, icon: PhosphorIconsRegular.flag),
                if (geo.city != null)
                  _chip(geo.city!, icon: PhosphorIconsRegular.mapPin),
                if (geo.lat != null && geo.lon != null)
                  _chip(
                    '(${geo.lat}, ${geo.lon})',
                    icon: PhosphorIconsRegular.target,
                  ),
              ],
            ),
          ],

          if (h.lastUpdate != null) ...[
            const SizedBox(height: 10),
            _chip(
              'last update: ${h.lastUpdate}',
              icon: PhosphorIconsRegular.clock,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summary(Summary sum) {
    final openPorts = sum.openPorts;
    final badges = sum.badges;
    final exposure = sum.exposureFlags;
    final provider = sum.providerHint;
    final risk = sum.riskScore;
    final webStack = sum.webStack;
    final tls = sum.tlsSummary;
    final portBuckets = sum.portBuckets;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 6,
            spacing: 6,
            children: [
              _chip(
                'risk: $risk',
                icon: PhosphorIconsRegular.warning,
                color: _riskColor(risk),
              ),
              _chip(
                'open: ${openPorts.length}',
                icon: PhosphorIconsRegular.plug,
              ),
              if (provider != null && provider.isNotEmpty)
                _chip(provider, icon: PhosphorIconsRegular.cloud),
              if (webStack != null && webStack.isNotEmpty)
                _chip(webStack, icon: PhosphorIconsRegular.browser),
              if (tls != null && tls.isNotEmpty)
                _chip('tls', icon: PhosphorIconsRegular.lock),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 6,
              spacing: 6,
              children: badges.map((b) => _chip(b)).toList(),
            ),
          ],
          if (exposure.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 6,
              spacing: 6,
              children: exposure
                  .map(
                    (e) => _chip(
                      e,
                      icon: PhosphorIconsRegular.shieldWarning,
                      color: Colors.orange,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (portBuckets.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Port Buckets:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              runSpacing: 6,
              spacing: 6,
              children: portBuckets.entries.map((e) {
                final name = e.key;
                final values = (e.value as List?)?.cast<num>() ?? const [];
                return _chip(
                  '$name: ${values.join(", ")}',
                  icon: PhosphorIconsRegular.hash,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _services(List<Service> services) {
    if (services.isEmpty) return _card(const Text('Sin servicios detectados.'));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, i) {
        final s = services[i];
        final serviceName = s.service?.toLowerCase();

        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    (serviceName?.contains('http') ?? false)
                        ? PhosphorIconsFill.globe
                        : PhosphorIconsFill.plug,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.service ?? ''}  •  ${s.product} ${s.version ?? ""}'
                          .trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _chip(
                    '${s.port}/${s.transport}',
                    icon: PhosphorIconsRegular.plug,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (s.cpe.isNotEmpty)
                Wrap(
                  children: s.cpe
                      .map((e) => _chip(e, icon: PhosphorIconsRegular.code))
                      .toList(),
                ),

              if (s.http.server != null ||
                  (s.http.title?.isNotEmpty ?? false) ||
                  s.http.status != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'HTTP',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (s.http.server != null)
                  _chip(
                    'server: ${s.http.server}',
                    icon: PhosphorIconsRegular.browser,
                  ),
                if (s.http.title != null && s.http.title!.isNotEmpty)
                  _chip(
                    'title: ${s.http.title}',
                    icon: PhosphorIconsRegular.textT,
                  ),
                if (s.http.status != null)
                  _chip(
                    'status: ${s.http.status}',
                    icon: PhosphorIconsRegular.numberSquareNine,
                  ),
              ],
              // TLS
              if (s.ssl.versions.isNotEmpty ||
                  s.ssl.alpn.isNotEmpty ||
                  s.ssl.cert.validFrom != null ||
                  s.ssl.cert.validTo != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'TLS',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                _finalCert(s.ssl),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _finalCert(SslInfo ssl) {
    final cert = ssl.cert;
    return Wrap(
      children: [
        if (ssl.versions.isNotEmpty)
          _chip(
            'vers: ${ssl.versions.join(", ")}',
            icon: PhosphorIconsRegular.lock,
          ),
        if (ssl.alpn.isNotEmpty)
          _chip(
            'alpn: ${ssl.alpn.join(", ")}',
            icon: PhosphorIconsRegular.arrowsLeftRight,
          ),
        if (cert.issuer.cn != null)
          _chip(
            'issuer: ${cert.issuer.cn}',
            icon: PhosphorIconsRegular.certificate,
          ),
        if (cert.subject.cn != null)
          _chip(
            'cn: ${cert.subject.cn}',
            icon: PhosphorIconsRegular.userCircle,
          ),
        if (cert.validFrom != null)
          _chip('from: ${cert.validFrom}', icon: PhosphorIconsRegular.calendar),
        if (cert.validTo != null)
          _chip(
            'to: ${cert.validTo}',
            icon: PhosphorIconsRegular.calendarBlank,
          ),
      ],
    );
  }

  Widget _vulns(List<String> vulns) {
    if (vulns.isEmpty) {
      return _card(const Text('Sin vulnerabilidades reportadas por Shodan.'));
    }
    final show = _showAllVulns ? vulns : vulns.take(12).toList();
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: show
                .map((cve) => _chip(cve, icon: PhosphorIconsRegular.bug))
                .toList(),
          ),
          if (vulns.length > 12)
            TextButton(
              onPressed: () => setState(() => _showAllVulns = !_showAllVulns),
              child: Text(
                _showAllVulns ? 'Ver menos' : 'Ver más (${vulns.length - 12})',
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canShow = _ip.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(canShow ? 'Host: $_ip' : 'Host Detail'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: _fetchHost,
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addToFavorites,
        tooltip: 'Agregar a favoritos',
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        child: const PhosphorIcon(PhosphorIconsFill.star),
      ),
      body: _loading
          ? const LinearProgressIndicator()
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          : !_hostReady()
          ? const Center(child: Text('Sin datos'))
          : _buildBody(),
    );
  }

  bool _hostReady() => _host != null && _host!.ip.isNotEmpty;

  Widget _buildBody() {
    final host = _host!;

    final summary = host.summary; // Summary
    final services = host.services; // List<Service>
    final vulns = host.vulns; // List<String>

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _sectionTitle('Overview', icon: PhosphorIconsRegular.info),
        _header(host),

        _sectionTitle('Summary', icon: PhosphorIconsRegular.listChecks),
        _summary(summary),

        _sectionTitle('Services', icon: PhosphorIconsRegular.plug),
        _services(services),

        _sectionTitle('Vulnerabilities', icon: PhosphorIconsRegular.bug),
        _vulns(vulns),
      ],
    );
  }
}
