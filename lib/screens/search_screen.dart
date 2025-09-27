import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  Future<void> _searchShodan(String query) async {
    setState(() {
      _loading = true;
      _results = [];
    });

    // ⚡ Aquí va la llamada real a Shodan con tu API Key
    await Future.delayed(const Duration(seconds: 2)); // simulación
    setState(() {
      _loading = false;
      _results = [
        {"ip": "192.168.1.10", "org": "TestOrg", "port": 80},
        {"ip": "8.8.8.8", "org": "Google", "port": 53},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Echord Search"),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsFill.gear),
            onPressed: () {
              // más tarde: configuración / filtros
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔎 Input con glow verde
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.greenAccent),
                decoration: InputDecoration(
                  hintText: "Buscar host, dominio o query...",
                  hintStyle: TextStyle(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                  prefixIcon: const PhosphorIcon(
                    PhosphorIconsRegular.magnifyingGlass,
                    color: Colors.greenAccent,
                  ),
                  suffixIcon: IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.arrowRight,
                      color: Colors.greenAccent,
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        _searchShodan(_controller.text.trim());
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.greenAccent,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.greenAccent,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _searchShodan(value.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            if (_loading) const LinearProgressIndicator(),

            // 📋 Resultados
            Expanded(
              child: _results.isEmpty && !_loading
                  ? const Center(
                      child: Text(
                        "Haz una búsqueda para ver resultados",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const PhosphorIcon(
                              PhosphorIconsFill.desktopTower,
                              color: Colors.greenAccent,
                            ),
                            title: Text(item["ip"]),
                            subtitle: Text(
                              "Org: ${item["org"]} | Puerto: ${item["port"]}",
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: item,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
