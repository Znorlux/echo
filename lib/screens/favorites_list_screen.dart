import 'package:flutter/material.dart';
import 'package:echord/widgets/glow_input.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el texto para actualizar el filtro automáticamente
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Datos de prueba
  final List<Favorite> _all = [
    const Favorite(
      id: '1',
      ip: '8.8.8.8',
      alias: 'Google DNS',
      notes: 'UDP/53 público',
      tags: ['dns', 'public'],
    ),
    const Favorite(
      id: '2',
      ip: '1.1.1.1',
      alias: 'Cloudflare',
      notes: 'Rápido en LATAM',
      tags: ['dns'],
    ),
    const Favorite(
      id: '3',
      ip: '203.0.113.42',
      alias: 'Nginx Demo',
      notes: 'Puerto 80 abierto',
      tags: ['http', 'nginx'],
    ),
  ];

  String _query = '';

  List<Favorite> get _filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((f) {
      return f.ip.contains(q) ||
          f.alias.toLowerCase().contains(q) ||
          f.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void _delete(Favorite f) {
    setState(() => _all.removeWhere((e) => e.id == f.id));
  }

  Future<void> _confirmDelete(Favorite f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar favorito'),
        content: Text('¿Eliminar "${f.alias}" (${f.ip})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) _delete(f);
  }

  void _edit(Favorite f) {
    //esto debe arreglarse a favorites/form
    Navigator.pushNamed(context, '/detail', arguments: f.toMap());
  }

  void _create() {
    Navigator.pushNamed(context, '/detail'); // sin argumentos = crear
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const PhosphorIcon(PhosphorIconsFill.plus),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: GlowInput(
              controller: _searchCtrl,
              hintText: 'Filtrar por IP, alias o tag...',
            ),
          ),

          // Lista
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Sin favoritos. Toca + para agregar uno.'
                          : 'No se encontraron resultados para "$_query"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final f = _filtered[i];
                      return Dismissible(
                        key: ValueKey(f.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red.withOpacity(0.3),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        confirmDismiss: (_) => showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text('¿Eliminar "${f.alias}" (${f.ip})?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) => _delete(f),
                        child: Card(
                          color: Colors.grey[900],
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
                              icon: const PhosphorIcon(
                                PhosphorIconsRegular.pencilSimple,
                              ),
                              onPressed: () => _edit(f),
                              tooltip: 'Editar',
                            ),
                            onTap: () => _edit(f),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
