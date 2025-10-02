// lib/screens/favorites_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/glow_input.dart';

const String kBackendBase = 'http://192.168.1.16:4000';
// const String kBackendBase = 'http://10.0.2.2:4000'; // Emulador Android

class Favorite {
  final String id;
  final String ip;
  final String alias;
  final String? notes;
  final List<String> tags;

  const Favorite({
    required this.id,
    required this.ip,
    required this.alias,
    this.notes,
    this.tags = const [],
  });

  Favorite copyWith({
    String? id,
    String? ip,
    String? alias,
    String? notes,
    List<String>? tags,
  }) {
    return Favorite(
      id: id ?? this.id,
      ip: ip ?? this.ip,
      alias: alias ?? this.alias,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  factory Favorite.fromMap(Map m) => Favorite(
    id: (m['id'] ?? m['_id']).toString(),
    ip: (m['ip'] ?? '').toString(),
    alias: (m['alias'] ?? '').toString(),
    notes: (m['notes'] as String?)?.toString(),
    tags: (m['tags'] is List)
        ? (m['tags'] as List).map((e) => e.toString()).toList()
        : const <String>[],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ip': ip,
    'alias': alias,
    'notes': notes,
    'tags': tags,
  };
}

class FavoritesListScreen extends StatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  final _searchCtrl = TextEditingController();

  // Estado de red
  bool _loading = false;
  String? _error;

  // Datos de server
  List<Favorite> _items = const [];
  int _page = 1;
  final int _size = 20;
  int _total = 0;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });
    _fetchFavorites(); // primer load
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------- Networking ----------

  Future<void> _fetchFavorites({bool resetPage = true}) async {
    if (resetPage) _page = 1;

    setState(() {
      _loading = true;
      _error = null;
      if (resetPage) _items = const [];
    });

    try {
      final uri = Uri.parse('$kBackendBase/api/v1/favorites').replace(
        queryParameters: {'search': _query, 'page': '$_page', 'size': '$_size'},
      );

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final body = json.decode(resp.body);
      final List list = (body['data'] as List?) ?? const [];
      final total = (body['total'] as num?)?.toInt() ?? list.length;

      final items = list.map((e) => Favorite.fromMap(e as Map)).toList();

      setState(() {
        if (_page == 1) {
          _items = items;
        } else {
          _items = [..._items, ...items];
        }
        _total = total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    if (_items.length >= _total) return;
    _page += 1;
    await _fetchFavorites(resetPage: false);
  }

  // ---------- Navegación ----------

  void _edit(Favorite f) {
    Navigator.pushNamed(context, '/favorites/form', arguments: f.toMap());
  }

  void _viewDetails(Favorite f) {
    Navigator.pushNamed(context, '/detail', arguments: {'ip': f.ip});
  }

  void _create() {
    Navigator.pushNamed(context, '/favorites/form');
  }

  // ---------- UI ----------

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    margin: const EdgeInsets.only(right: 6),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );

  @override
  Widget build(BuildContext context) {
    final canPaginate = _items.length < _total;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        child: const PhosphorIcon(PhosphorIconsFill.plus),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchFavorites(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            // Buscador
            GlowInput(
              controller: _searchCtrl,
              hintText: 'Filtrar por IP, alias o tag...',
              onSearch: () => _fetchFavorites(),
              onSubmitted: (_) => _fetchFavorites(),
            ),

            const SizedBox(height: 12),

            if (_loading && _items.isEmpty) const LinearProgressIndicator(),
            if (_error != null && _items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            if (_items.isEmpty && _error == null && !_loading)
              Center(
                child: Column(
                  children: [
                    Text(
                      _query.isEmpty
                          ? 'Sin favoritos. Toca + para agregar uno.'
                          : 'No se encontraron resultados para "$_query"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Para actualizar la lista, desliza hacia abajo',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            ..._items.map(
              (f) => Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const PhosphorIcon(
                    PhosphorIconsFill.star,
                    color: Colors.greenAccent,
                    size: 26,
                  ),
                  title: Text('${f.alias}  •  ${f.ip}'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(children: f.tags.map(_chip).toList()),
                  ),
                  trailing: IconButton(
                    icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                    onPressed: () => _edit(f),
                    tooltip: 'Editar',
                  ),
                  onTap: () => _viewDetails(f),
                ),
              ),
            ),

            if (canPaginate) ...[
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _loadMore,
                  icon: const Icon(Icons.expand_more),
                  label: Text(_loading ? 'Cargando...' : 'Cargar más'),
                ),
              ),
            ],

            // Mensaje sutil para actualizar
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Para actualizar la lista, desliza hacia abajo',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
