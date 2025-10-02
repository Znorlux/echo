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

  // Paginación visual
  int _displayPage = 1;
  final int _displayPageSize = 5;

  // Presets de búsqueda
  final List<String> _presets = const [
    'port:22 country:CO',
    'http.status:200',
    'http.title:"index of /"',
    'http.headers.server:"Apache"',
    'product:"Apache httpd" port:80',
    'product:"OpenSSH" port:22',
    'org:"Akamai Connected Cloud"',
    'asn:AS63949',
    'hostname:"scanme.nmap.org"',
    'net:45.33.32.0/24',
    'city:"Bogotá" port:80',
    'ssl:true port:443',
    'ssl.alpn:h2',
    'ssl.cert.subject.cn:"google.com"',
    'cpe:"cpe:/a:openbsd:openssh"',
    'ports:80,443',
    '(port:22 OR port:3389 OR port:5900 OR port:23)',
    'port:80 -ssl:true',
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
        _displayPage = 1;
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

  // Obtener resultados de la página actual para mostrar
  List<_Hit> _getDisplayResults() {
    final start = (_displayPage - 1) * _displayPageSize;
    final end = start + _displayPageSize;
    if (start >= _results.length) return [];
    return _results.sublist(
      start,
      end > _results.length ? _results.length : end,
    );
  }

  // Calcular total de páginas visuales
  int _getTotalDisplayPages() {
    if (_results.isEmpty) return 0;
    return (_results.length / _displayPageSize).ceil();
  }

  // Cambiar página y cargar más si es necesario
  Future<void> _changeDisplayPage(int newPage) async {
    setState(() => _displayPage = newPage);

    // Si nos acercamos al final y hay más resultados, cargar
    final neededResults = newPage * _displayPageSize;
    if (neededResults > _results.length &&
        _results.length < _total &&
        !_loading) {
      _page += 1;
      await _search(_currentQuery, reset: false);
    }
  }

  // --------------- UI ---------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResults = _results.isNotEmpty;

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
            // GlowInput
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

            // 🎛️ Presets horizontales de shodan
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
              ..._getDisplayResults().map(
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
              const SizedBox(height: 16),
              _PaginationControls(
                currentPage: _displayPage,
                totalPages: _getTotalDisplayPages(),
                onPageChanged: _changeDisplayPage,
                loading: _loading,
              ),
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

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool loading;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    // Calcular qué páginas mostrar
    List<int> pagesToShow = [];
    if (totalPages <= 5) {
      // Mostrar todas si son 5 o menos
      pagesToShow = List.generate(totalPages, (i) => i + 1);
    } else {
      // Mostrar páginas alrededor de la actual
      if (currentPage <= 3) {
        pagesToShow = [1, 2, 3, 4, 5];
      } else if (currentPage >= totalPages - 2) {
        pagesToShow = List.generate(5, (i) => totalPages - 4 + i);
      } else {
        pagesToShow = List.generate(5, (i) => currentPage - 2 + i);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón anterior
        IconButton(
          onPressed: currentPage > 1 && !loading
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(backgroundColor: Colors.grey[800]),
        ),
        const SizedBox(width: 8),

        // Números de página
        ...pagesToShow.map((page) {
          final isActive = page == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: !loading && page != currentPage
                  ? () => onPageChanged(page)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: Colors.greenAccent, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color: isActive ? Colors.greenAccent : Colors.white,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 8),
        // Botón siguiente
        IconButton(
          onPressed: currentPage < totalPages && !loading
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(backgroundColor: Colors.grey[800]),
        ),
      ],
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
