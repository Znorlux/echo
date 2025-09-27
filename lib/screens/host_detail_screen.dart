import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HostDetailScreen extends StatefulWidget {
  const HostDetailScreen({super.key});

  @override
  State<HostDetailScreen> createState() => _HostDetailScreenState();
}

class _HostDetailScreenState extends State<HostDetailScreen> {
  Map<String, dynamic>? _host;
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
        _host = mock['data'] as Map<String, dynamic>;
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
            "version": "6.6.1p1 Ubuntu 2ubuntu2.13",
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
            "version": null,
            "cpe": [],
            "fingerprints": 1863949623,
            "http": null,
            "ssl": null,
            "raw_tags": ["cloud"],
          },
          {
            "port": 9929,
            "transport": "tcp",
            "service": "auto",
            "product": null,
            "version": null,
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

  Widget _chip(String text, {IconData? icon, Color? color}) {
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
            margin: const EdgeInsets.only(right: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: (color ?? Colors.greenAccent).withOpacity(0.7),
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

  Widget _header(Map<String, dynamic> h) {
    final hostnames = (h['hostnames'] as List?)?.cast<String>() ?? const [];
    final domains = (h['domains'] as List?)?.cast<String>() ?? const [];
    final geo = (h['geo'] as Map?) ?? {};
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IP + ISP/ORG
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PhosphorIcon(
                PhosphorIconsFill.desktopTower,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  runSpacing: 6,
                  children: [
                    Text(
                      h['ip']?.toString() ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (h['org'] != null)
                      _chip(
                        'ORG: ${h['org']}',
                        icon: PhosphorIconsRegular.buildings,
                      ),
                    if (h['isp'] != null)
                      _chip(
                        'ISP: ${h['isp']}',
                        icon: PhosphorIconsRegular.globe,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hostnames / domains
          if (hostnames.isNotEmpty || domains.isNotEmpty)
            Wrap(
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
          // Geo
          if (geo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              children: [
                if (geo['country'] != null)
                  _chip(
                    geo['country'].toString(),
                    icon: PhosphorIconsRegular.flag,
                  ),
                if (geo['city'] != null)
                  _chip(
                    geo['city'].toString(),
                    icon: PhosphorIconsRegular.mapPin,
                  ),
                if (geo['lat'] != null && geo['lon'] != null)
                  _chip(
                    '(${geo['lat']}, ${geo['lon']})',
                    icon: PhosphorIconsRegular.target,
                  ),
              ],
            ),
          ],
          if (h['last_update'] != null) ...[
            const SizedBox(height: 10),
            _chip(
              'last update: ${h['last_update']}',
              icon: PhosphorIconsRegular.clock,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summary(Map<String, dynamic> sum) {
    final openPorts = (sum['open_ports'] as List?)?.cast<num>() ?? const [];
    final badges = (sum['badges'] as List?)?.cast<String>() ?? const [];
    final exposure =
        (sum['exposure_flags'] as List?)?.cast<String>() ?? const [];
    final provider = sum['provider_hint']?.toString();
    final risk = sum['risk_score'] as num?;
    final webStack = sum['web_stack']?.toString();
    final tls = sum['tls_summary']?.toString();
    final Map<String, dynamic> portBuckets = Map<String, dynamic>.from(
      sum['port_buckets'] ?? {},
    );

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              _chip(
                'risk: ${risk ?? 0}',
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
            Wrap(children: badges.map((b) => _chip(b)).toList()),
          ],
          if (exposure.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
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

  Widget _services(List<Map<String, dynamic>> services) {
    if (services.isEmpty) {
      return _card(const Text('Sin servicios detectados.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, i) {
        final s = services[i];
        final port = s['port'];
        final transport = s['transport'];
        final service = s['service']?.toString();
        final product = s['product']?.toString();
        final version = s['version']?.toString();
        final cpe = (s['cpe'] as List?)?.cast<String>() ?? const [];
        final httpInfo = s['http'] as Map?;
        final sslInfo = s['ssl'] as Map?;

        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    (service?.toLowerCase().contains('http') ?? false)
                        ? PhosphorIconsFill.globe
                        : PhosphorIconsFill.plug,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$service  •  $product ${version ?? ""}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _chip('$port/$transport', icon: PhosphorIconsRegular.plug),
                ],
              ),
              const SizedBox(height: 8),
              if (cpe.isNotEmpty)
                Wrap(
                  children: cpe
                      .map((e) => _chip(e, icon: PhosphorIconsRegular.code))
                      .toList(),
                ),
              if (httpInfo != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'HTTP',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (httpInfo['server'] != null)
                  _chip(
                    'server: ${httpInfo['server']}',
                    icon: PhosphorIconsRegular.browser,
                  ),
                if (httpInfo['title'] != null &&
                    (httpInfo['title'] as String).isNotEmpty)
                  _chip(
                    'title: ${httpInfo['title']}',
                    icon: PhosphorIconsRegular.textT,
                  ),
                if (httpInfo['status'] != null)
                  _chip(
                    'status: ${httpInfo['status']}',
                    icon: PhosphorIconsRegular.numberSquareNine,
                  ),
              ],
              if (sslInfo != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'TLS',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                finalCert(sslInfo),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget finalCert(Map sslInfo) {
    final versions = (sslInfo['versions'] as List?)?.cast<String>() ?? const [];
    final alpn = (sslInfo['alpn'] as List?)?.cast<String>() ?? const [];
    final cert = (sslInfo['cert'] as Map?) ?? {};
    final issuer = (cert['issuer'] as Map?) ?? {};
    final subject = (cert['subject'] as Map?) ?? {};
    return Wrap(
      children: [
        if (versions.isNotEmpty)
          _chip(
            'vers: ${versions.join(", ")}',
            icon: PhosphorIconsRegular.lock,
          ),
        if (alpn.isNotEmpty)
          _chip(
            'alpn: ${alpn.join(", ")}',
            icon: PhosphorIconsRegular.arrowsLeftRight,
          ),
        if (issuer['CN'] != null)
          _chip(
            'issuer: ${issuer['CN']}',
            icon: PhosphorIconsRegular.certificate,
          ),
        if (subject['CN'] != null)
          _chip('cn: ${subject['CN']}', icon: PhosphorIconsRegular.userCircle),
        if (cert['valid_from'] != null)
          _chip(
            'from: ${cert['valid_from']}',
            icon: PhosphorIconsRegular.calendar,
          ),
        if (cert['valid_to'] != null)
          _chip(
            'to: ${cert['valid_to']}',
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

  bool _hostReady() => _host != null && _host!['ip'] != null;

  Widget _buildBody() {
    final h = _host!;

    // ✅ Tipar fuerte lo que usamos
    final Map<String, dynamic> summary = Map<String, dynamic>.from(
      (h['summary'] as Map?) ?? {},
    );

    final List<Map<String, dynamic>> services = ((h['services'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final List<String> vulns = ((h['vulns'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _sectionTitle('Overview', icon: PhosphorIconsRegular.info),
        _header(Map<String, dynamic>.from(h)),

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
