// lib/screens/search_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/glow_input.dart';

// 🔌 Cambia según tu entorno:
const String kBackendBase = 'http://192.168.1.16:4000';
// const String kBackendBase = 'http://10.0.2.2:4000'; // Emulador

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _loading = false;
  String? _error;

  List<_Hit> _results = const [];
  int _page = 1;
  final int _size = 20;
  int _total = 0;
  String _currentQuery = '';

  // Presets de búsqueda
  final List<String> _presets = const [
    'port:22 country:CO',
    'service:http status:200',
    'remote_access_exposed',
    'unencrypted_web',
    'product:"Apache httpd"',
    'org:"Akamai Connected Cloud"',
    'open_ports:>3',
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScrollLoadMore);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ----------- Networking -----------

  Future<void> _search(String query, {bool reset = true}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();

    if (reset) {
      setState(() {
        _currentQuery = q;
        _page = 1;
        _results = const [];
        _total = 0;
        _error = null;
      });
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('$kBackendBase/api/v1/shodan/search').replace(
        queryParameters: {
          'q': _currentQuery,
          'page': '$_page',
          'size': '$_size',
        },
      );

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final body = json.decode(resp.body);
      final List raw = (body['data'] as List?) ?? const [];
      final hits = raw.map((e) => _Hit.fromMap(e as Map)).toList();
      final total =
          (body['total'] as num?)?.toInt() ??
          (_page == 1 ? hits.length : _total);

      setState(() {
        _results = [..._results, ...hits];
        _total = total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScrollLoadMore() {
    if (_loading) return;
    if (_results.length >= _total) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _page += 1;
      _search(_currentQuery, reset: false);
    }
  }

  void _usePreset(String p) {
    _controller.text = p;
    _search(p);
  }

  // --------------- UI ---------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResults = _results.isNotEmpty;
    final canPaginate = _results.length < _total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Echord Search"),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsFill.gear),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            _search(_currentQuery.isEmpty ? _controller.text : _currentQuery),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: [
            // 🔎 Tu GlowInput (sin onChanged)
            GlowInput(
              controller: _controller,
              hintText: "Buscar host, dominio o query...",
              onSearch: () => _search(_controller.text),
              onSubmitted: (v) => _search(v),
              // (opcional) personaliza íconos/colores:
              // prefixIcon: PhosphorIconsRegular.magnifyingGlass,
              // suffixIcon: PhosphorIconsRegular.arrowRight,
            ),

            const SizedBox(height: 12),

            // 🎛️ Presets horizontales (más compacto)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_presets[i]),
                  avatar: const Icon(Icons.bolt, size: 16),
                  onPressed: () => _usePreset(_presets[i]),
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                    0.15,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.greenAccent.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_loading && !hasResults) const LinearProgressIndicator(),
            if (_error != null && !hasResults)
              _ErrorBox(
                message: _error!,
                onRetry: () => _search(
                  _controller.text.isEmpty ? _currentQuery : _controller.text,
                ),
              ),

            if (!hasResults && _error == null && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    "Haz una búsqueda para ver resultados",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            if (hasResults) ...[
              Row(
                children: [
                  Text(
                    'Resultados: ${_results.length}${_total > 0 ? " / $_total" : ""}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  if (_loading)
                    const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ..._results.map(
                (e) => _ResultTile(
                  hit: e,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: {'ip': e.ip},
                  ),
                  onCopy: () {
                    if (e.ip != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('IP copiada')),
                      );
                    }
                  },
                ),
              ),
              if (canPaginate) ...[
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                            _page += 1;
                            _search(_currentQuery, reset: false);
                          },
                    icon: const Icon(Icons.expand_more),
                    label: Text(_loading ? 'Cargando...' : 'Cargar más'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Widgets auxiliares ----------

class _ResultTile extends StatelessWidget {
  final _Hit hit;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  const _ResultTile({
    required this.hit,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const PhosphorIcon(
          PhosphorIconsFill.desktopTower,
          color: Colors.greenAccent,
        ),
        title: Text(hit.ip ?? '—'),
        subtitle: Text(
          [
            if ((hit.org ?? '').isNotEmpty) 'Org: ${hit.org}',
            if (hit.port != null) 'Puerto: ${hit.port}',
            if ((hit.note ?? '').isNotEmpty) hit.note!,
          ].join(' | '),
        ),
        trailing: Wrap(
          spacing: 4,
          children: const [Icon(Icons.arrow_forward_ios, size: 16)],
        ),
        onTap: onTap,
        onLongPress: onCopy,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Modelo del resultado ----------
class _Hit {
  final String? ip;
  final String? org;
  final int? port;
  final String? note;

  const _Hit({this.ip, this.org, this.port, this.note});

  factory _Hit.fromMap(Map m) => _Hit(
    ip: m['ip_str']?.toString(),
    org: m['org']?.toString(),
    port: (m['port'] is num) ? (m['port'] as num).toInt() : null,
    note: m['note']?.toString(),
  );
}
