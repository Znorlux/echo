// lib/screens/host_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/host.dart';
import '../models/service.dart';
import '../models/summary.dart';

// Usa la misma base que en SearchScreen
const String kBackendBase = 'http://192.168.1.16:4000';
// const String kBackendBase = 'http://10.0.2.2:4000'; // Emulador

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

  // --- Estado de favorito ---
  String? _favId; // null = no es favorito
  String? _favNotes; // notas del favorito
  bool _favBusy = false; // para deshabilitar mientras agrega/borra

  String get _ip {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['ip'] is String) return args['ip'] as String;
    return '45.33.32.156';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHost());
  }

  // =============== Networking ===============
  Future<void> _fetchHost() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$kBackendBase/api/v1/shodan/host/$_ip');
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final body = json.decode(resp.body);
      final data = body['data'];
      if (data is! Map) throw Exception('Respuesta inválida del backend');

      setState(() {
        _host = Host.fromMap(Map<String, dynamic>.from(data));
        _loading = false;
      });

      // después de cargar el host, verificar si es favorito
      await _loadFavoriteStatus();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Consulta si esta IP ya está en favoritos
  Future<void> _loadFavoriteStatus() async {
    try {
      final uri = Uri.parse(
        '$kBackendBase/api/v1/favorites',
      ).replace(queryParameters: {'search': _ip, 'page': '1', 'size': '5'});
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return;

      final body = json.decode(resp.body);
      final List list = (body['data'] as List?) ?? const [];

      String? foundId;
      String? notes;

      for (final e in list) {
        if (e is Map && (e['ip']?.toString() ?? '') == _ip) {
          foundId = (e['id'] ?? e['_id'])?.toString();
          notes = (e['notes'] as String?)?.toString();
          break;
        }
      }

      if (mounted) {
        setState(() {
          _favId = foundId;
          _favNotes = notes;
        });
      }
    } catch (_) {
      // silenciar
    }
  }

  /// Alterna favorito: crea si no existe, borra si ya existe.
  Future<void> _toggleFavorite() async {
    if (_host == null || _favBusy) return;
    setState(() => _favBusy = true);

    try {
      if (_favId == null) {
        // Crear favorito
        final uri = Uri.parse('$kBackendBase/api/v1/favorites');
        final alias = _host!.hostnames.isNotEmpty
            ? _host!.hostnames.first
            : _host!.ip;
        final resp = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'ip': _host!.ip,
                'alias': alias,
                'notes': null,
                'tags': <String>[],
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (resp.statusCode != 200 && resp.statusCode != 201) {
          throw Exception('No se pudo agregar (HTTP ${resp.statusCode})');
        }
        final body = json.decode(resp.body);
        final id = (body is Map && body['data'] is Map)
            ? ((body['data'] as Map)['id'] ?? (body['data'] as Map)['_id'])
                  ?.toString()
            : null;

        setState(() => _favId = id ?? 'unknown');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Agregado a favoritos')));
      } else {
        // Eliminar favorito
        final uri = Uri.parse('$kBackendBase/api/v1/favorites/$_favId');
        final resp = await http
            .delete(uri)
            .timeout(const Duration(seconds: 15));
        if (resp.statusCode != 200 && resp.statusCode != 204) {
          throw Exception('No se pudo eliminar (HTTP ${resp.statusCode})');
        }
        setState(() => _favId = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _favBusy = false);
    }
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
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

  Widget _card(Widget child) => Card(
    color: Colors.grey[900],
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Padding(padding: const EdgeInsets.all(14), child: child),
  );

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
              children: portBuckets.entries
                  .map(
                    (e) => _chip(
                      '${e.key}: ${e.value.join(", ")}',
                      icon: PhosphorIconsRegular.hash,
                    ),
                  )
                  .toList(),
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
    if (vulns.isEmpty)
      return _card(const Text('Sin vulnerabilidades reportadas por Shodan.'));
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

  Widget _noteCard(String notes) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SizedBox(height: 8), Text(notes)],
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
        onPressed: (!_hostReady() || _favBusy) ? null : _toggleFavorite,
        tooltip: _favId == null ? 'Agregar a favoritos' : 'Quitar de favoritos',
        backgroundColor: _favId == null
            ? Colors.greenAccent
            : Colors.amberAccent,
        foregroundColor: Colors.black,
        child: _favBusy
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : PhosphorIcon(
                _favId == null
                    ? PhosphorIconsRegular.star
                    : PhosphorIconsFill.star,
              ),
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
    final summary = host.summary;
    final services = host.services;
    final vulns = host.vulns;

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
        if (_favNotes != null) ...[
          _sectionTitle('Notes', icon: PhosphorIconsRegular.notePencil),
          _noteCard(_favNotes!),
        ],
      ],
    );
  }
}
