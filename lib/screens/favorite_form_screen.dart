// lib/screens/favorites_form_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Usa la MISMA base que en tus otras screens
const String kBackendBase = 'http://192.168.1.16:4000';
// const String kBackendBase = 'http://10.0.2.2:4000'; // Emulador

class FavoriteFormScreen extends StatefulWidget {
  const FavoriteFormScreen({super.key});

  @override
  State<FavoriteFormScreen> createState() => _FavoriteFormScreenState();
}

class _FavoriteFormScreenState extends State<FavoriteFormScreen> {
  final _notesCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  bool _saving = false;
  String? _error;

  // Datos base del favorito pasado por argumentos
  String? _id; // si viene null -> crear
  String _ip = ''; // requerido para crear
  String _alias = '';

  // Tags seleccionados
  final Set<String> _selected = <String>{};

  // Presets que el usuario puede preseleccionar
  final List<String> _presets = const [
    'dns',
    'http',
    'https',
    'ssh',
    'rdp',
    'db',
    'public',
    'internal',
    'critical',
    'prod',
    'dev',
    'windows',
    'linux',
    'cloud',
    'iot',
    'vpn',
  ];

  @override
  void initState() {
    super.initState();
    // Cargamos argumentos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _id = (args['id'] ?? args['_id'])?.toString();
        _ip = (args['ip'] ?? '').toString();
        _alias = (args['alias'] ?? '').toString();
        final notes = (args['notes'] as String?)?.toString();
        final List tagsRaw = (args['tags'] is List)
            ? (args['tags'] as List)
            : const [];
        _selected.addAll(
          tagsRaw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty),
        );
        if (notes != null) _notesCtrl.text = notes;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  // ----------------- Helpers -----------------

  void _togglePreset(String tag) {
    final t = tag.trim();
    if (t.isEmpty) return;
    setState(() {
      if (_selected.contains(t)) {
        _selected.remove(t);
      } else {
        _selected.add(t);
      }
    });
  }

  void _addCustomTag() {
    final t = _tagInputCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _selected.add(t);
      _tagInputCtrl.clear();
    });
  }

  void _removeTag(String t) {
    setState(() => _selected.remove(t));
  }

  // ----------------- Networking -----------------

  Future<void> _save() async {
    if (_saving) return;

    // Si no hay ID, asumimos "crear". Para crear necesitamos ip y alias.
    if (_id == null) {
      if (_ip.isEmpty || _alias.isEmpty) {
        setState(() => _error = 'Faltan datos para crear (ip/alias).');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_id == null) {
        // Crear
        final uri = Uri.parse('$kBackendBase/api/v1/favorites');
        final resp = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'ip': _ip,
                'alias': _alias,
                'notes': _notesCtrl.text.trim().isEmpty
                    ? null
                    : _notesCtrl.text.trim(),
                'tags': _selected.toList(),
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (resp.statusCode != 200 && resp.statusCode != 201) {
          throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
        }

        // Opcional: leer id devuelto
        final body = json.decode(resp.body);
        if (body is Map && body['data'] is Map) {
          _id = ((body['data'] as Map)['id'] ?? (body['data'] as Map)['_id'])
              ?.toString();
        }
      } else {
        // Editar (PATCH)
        final uri = Uri.parse('$kBackendBase/api/v1/favorites/$_id');
        final resp = await http
            .patch(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'notes': _notesCtrl.text.trim().isEmpty
                    ? null
                    : _notesCtrl.text.trim(),
                'tags': _selected.toList(),
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (resp.statusCode != 200) {
          throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
      Navigator.pop(
        context,
        true,
      ); // <- devuelve true para que la lista recargue
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ----------------- UI -----------------

  @override
  Widget build(BuildContext context) {
    final isEdit = _id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar favorito' : 'Nuevo favorito'),
        actions: [
          IconButton(
            tooltip: 'Guardar',
            onPressed: _saving ? null : _save,
            icon: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Info básica (solo lectura para ip/alias en edición)
          if (_ip.isNotEmpty || _alias.isNotEmpty) ...[
            Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: const PhosphorIcon(
                  PhosphorIconsFill.star,
                  color: Colors.greenAccent,
                ),
                title: Text(_alias.isEmpty ? '—' : _alias),
                subtitle: Text(_ip.isEmpty ? '—' : _ip),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Notes
          const Text('Notas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Opcional: observaciones, contexto, etc.',
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tags - presets
          const Text(
            'Etiquetas (presets)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((t) {
              final selected = _selected.contains(t);
              return FilterChip(
                selected: selected,
                onSelected: (_) => _togglePreset(t),
                label: Text(t),
                avatar: Icon(
                  selected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 16,
                ),
                side: BorderSide(
                  color: Colors.greenAccent.withValues(alpha: 0.5),
                ),
                selectedColor: Colors.green.withValues(alpha: 0.15),
                showCheckmark: false,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Tags - personalizados
          const Text(
            'Añadir etiqueta personalizada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputCtrl,
                  decoration: InputDecoration(
                    hintText: 'ej: pci, backup, perimeter…',
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _addCustomTag(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addCustomTag,
                icon: const Icon(Icons.add),
                label: const Text('Añadir'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tags seleccionados
          if (_selected.isNotEmpty) ...[
            const Text(
              'Seleccionadas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selected.map((t) {
                return Chip(
                  label: Text(t),
                  onDeleted: () => _removeTag(t),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  side: BorderSide(
                    color: Colors.greenAccent.withValues(alpha: 0.6),
                  ),
                );
              }).toList(),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],

          const SizedBox(height: 24),
          // Botones inferiores
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => Navigator.pop(context, false),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
