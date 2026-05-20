import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {

  // Fonctions de récupération dynamique depuis tes endpoints Spring Boot
  Future<List<dynamic>> fetchCategoryItems(String endpoint) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/items/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Impossible de charger les données du backend');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Dressing Réel")),
      body: RefreshIndicator(
        onRefresh: () async { setState(() {}); }, // Rafraîchit l'UI en tirant vers le bas
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Force le scroll de haut en bas complet
          padding: const EdgeInsets.only(top: 10, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySection("Tops (Hauts)", "tops"),
              _buildCategorySection("Bottoms (Bas)", "bottoms"),
              _buildCategorySection("Shoes (Chaussures)", "shoes"),
            ],
          ),
        ),
      ),
    );
  }

  // Composant dynamique réutilisable, connecté directement à ton ItemController
  Widget _buildCategorySection(String title, String endpoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180, // Hauteur de la zone pour défiler de gauche à droite
          child: FutureBuilder<List<dynamic>>(
            future: fetchCategoryItems(endpoint),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Aucun vêtement dans cette catégorie"));
              }

              final items = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal, // Scroll horizontal fluide pour chaque catégorie
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // On récupère l'image traitée par ton service S3 / Python
                  String imageUrl = item['imageUrl'] ?? 'https://via.placeholder.com/150';

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: item['imageStatus'] == 'PROCESSING'
                                ? const Center(child: Text("IA nettoie le fond...", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)))
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item['name'] ?? 'Sans nom', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(item['color'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 25),
      ],
    );
  }
}