// lib/screens/scan_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../widgets/glow_input.dart';
import '../models/host.dart';

const String kBackendBase = 'http://192.168.1.16:4000';
// const String kBackendBase = 'http://10.0.2.2:4000'; // Emulador Android

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _ctrl = TextEditingController();

  bool _loading = false;
  String? _error;
  Host? _host; // último resultado

  // ---------- Helpers ----------
  String _sanitize(String raw) {
    // recorta y elimina protocolos si los pegaron
    var s = raw.trim();
    if (s.startsWith('http://')) s = s.substring(7);
    if (s.startsWith('https://')) s = s.substring(8);
    // quita slash final
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    return s;
  }

  bool _looksValid(String s) {
    // validación básica de IPv4/IPv6/hostname
    final ipv4 = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    final ipv6 = RegExp(
      r'^[0-9a-fA-F:]+$',
    ); // esto es muy permisivo (suficiente para UI)
    final host = RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'); // dominio simple
    return ipv4.hasMatch(s) || ipv6.hasMatch(s) || host.hasMatch(s);
  }

  // ---------- Networking ----------
  Future<void> _scan() async {
    FocusScope.of(context).unfocus();
    final target = _sanitize(_ctrl.text);
    if (target.isEmpty || !_looksValid(target)) {
      setState(() {
        _error =
            'Ingresa una IP válida (v4/v6) o un hostname (ej: scanme.nmap.org).';
        _host = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _host = null;
    });

    try {
      final uri = Uri.parse('$kBackendBase/api/v1/shodan/host/$target');
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final body = json.decode(resp.body);
      final data = body['data'];
      if (data is! Map) throw Exception('Respuesta inválida del backend');

      final host = Host.fromMap(Map<String, dynamic>.from(data));
      setState(() => _host = host);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _host = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToDetail() {
    if (_host == null) return;
    Navigator.pushNamed(context, '/detail', arguments: {'ip': _host!.ip});
  }

  // ---------- UI ----------
  Widget _card(Widget child) => Card(
    color: Colors.grey[900],
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Padding(padding: const EdgeInsets.all(14), child: child),
  );

  Color _riskColor(num? score) {
    final s = (score ?? 0).toDouble();
    if (s >= 80) return Colors.redAccent;
    if (s >= 60) return Colors.deepOrange;
    if (s >= 40) return Colors.orange;
    if (s >= 20) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  Widget _chip(String text, {IconData? icon, Color? color}) {
    return Container(
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
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: color ?? Colors.greenAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _resultPreview(Host h) {
    final sum = h.summary;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                    const SizedBox(height: 6),
                    Wrap(
                      children: [
                        if ((h.org ?? '').isNotEmpty)
                          _chip(
                            'ORG: ${h.org}',
                            icon: PhosphorIconsRegular.buildings,
                          ),
                        if ((h.isp ?? '').isNotEmpty)
                          _chip(
                            'ISP: ${h.isp}',
                            icon: PhosphorIconsRegular.globe,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Summary chips
          Wrap(
            children: [
              _chip(
                'risk: ${sum.riskScore}',
                icon: PhosphorIconsRegular.warning,
                color: _riskColor(sum.riskScore),
              ),
              _chip(
                'open: ${sum.openPorts.length}',
                icon: PhosphorIconsRegular.plug,
              ),
              if ((sum.webStack ?? '').isNotEmpty)
                _chip(sum.webStack!, icon: PhosphorIconsRegular.browser),
              if ((sum.providerHint ?? '').isNotEmpty)
                _chip(sum.providerHint!, icon: PhosphorIconsRegular.cloud),
            ],
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _goToDetail,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ver detalle'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _host != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan (IP / Hostname)'),
        actions: [
          IconButton(
            tooltip: 'Limpiar',
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _ctrl.clear();
                _error = null;
                _host = null;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_ctrl.text.trim().isNotEmpty) await _scan();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            GlowInput(
              controller: _ctrl,
              hintText:
                  'Ingresa una IP o hostname (ej: 8.8.8.8 o scanme.nmap.org)',
              onSearch: _scan,
              onSubmitted: (_) => _scan(),
            ),

            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),

            if (_error != null && !_loading)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            if (!hasResult && _error == null && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    'Puedes ingresar dominios a los cuales se les aplicará automaticamente resolucion de DNS para obtener su.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            if (hasResult) _resultPreview(_host!),
          ],
        ),
      ),
    );
  }
}
