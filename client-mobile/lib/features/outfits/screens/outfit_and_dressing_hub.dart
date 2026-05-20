import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart' as camera_pkg;
import 'package:http/http.dart' as http;

import '../../camera/models/camera_item.dart';
import '../../camera/screens/image_confirm_screen.dart';
import '../../camera/screens/smart_camera_screen.dart';
import '../../camera/state/camera_capture_controller.dart';
import '../../camera/state/item_fetch_controller.dart';
import '../../camera/widgets/image_placeholder.dart';
import '../../camera/widgets/signed_item_image.dart';

// Importation globale via ton Barrel File (sans modification de ton module)


class OutfitAndDressingHub extends StatefulWidget {
  const OutfitAndDressingHub({super.key});

  @override
  State<OutfitAndDressingHub> createState() => _OutfitAndDressingHubState();
}

class _OutfitAndDressingHubState extends State<OutfitAndDressingHub> {
  // Variables d'état pour la construction de l'Outfit
  CameraItem? selectedTop;
  CameraItem? selectedBottom;
  CameraItem? selectedShoe;

  final _outfitNameController = TextEditingController();
  final _outfitDescController = TextEditingController();
  bool _isSavingOutfit = false;

  @override
  void dispose() {
    _outfitNameController.dispose();
    _outfitDescController.dispose();
    super.dispose();
  }

  // INTERFACE 1 : Gestion de la Galerie (Flux Fichier sans prendre de photo)
  Future<void> _handleGalleryPicker(BuildContext context) async {
    // On instancie temporairement le contrôleur existant pour utiliser sa logique SANS caméra physique
    final captureController = CameraCaptureController(cameras: []);
    final String? imagePath = await captureController.pickFromGallery();

    if (imagePath != null && context.mounted) {
      // Redirection directe vers ton écran de confirmation d'origine
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageConfirmScreen(imagePath: imagePath),
        ),
      );
    }
  }

  // INTERFACE 2 : Gestion de la Caméra standard
  Future<void> _handleCameraPicker(BuildContext context) async {
    try {
      final cameras = await camera_pkg.availableCameras();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SmartCameraScreen(cameras: cameras),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir la caméra : $e")),
      );
    }
  }

  // SAUVEGARDE DE L'OUTFIT : Appel HTTP vers le OutfitController de ton Spring Boot
  Future<void> _saveOutfit() async {
    if (_outfitNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner un nom à votre Outfit')),
      );
      return;
    }

    if (selectedTop == null || selectedBottom == null || selectedShoe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un Top, un Bottom et une Shoe')),
      );
      return;
    }

    setState(() => _isSavingOutfit = true);

    try {
      // Endpoint correspondant à ton @PostMapping dans OutfitController
      final url = Uri.parse('http://10.0.2.2:8080/api/outfits');

      // Payload JSON mappé exactement sur ton CreateOutfitRequest record Java
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer <TON_TOKEN>', // À décommenter si Spring Security est actif
        },
        body: jsonEncode({
          'name': _outfitNameController.text.trim(),
          'description': _outfitDescController.text.trim(),
          'topId': selectedTop!.id,
          'bottomId': selectedBottom!.id,
          'shoeId': selectedShoe!.id,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outfit sauvegardé avec succès !')),
        );
        // Réinitialisation du formulaire après succès
        setState(() {
          selectedTop = null;
          selectedBottom = null;
          selectedShoe = null;
          _outfitNameController.clear();
          _outfitDescController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur backend : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de la sauvegarde : $e')),
      );
    } finally {
      setState(() => _isSavingOutfit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // On initialise le ItemFetchController existant pour charger les vrais items du dressing
      create: (_) => ItemFetchController()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion Dressing & Outfits'),
          centerTitle: true,
        ),
        body: Consumer<ItemFetchController>(
          builder: (context, fetchController, child) {
            if (fetchController.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Séparation des vrais items récupérés par catégories
            final tops = fetchController.items.where((i) => i.category == 'TOP').toList();
            final bottoms = fetchController.items.where((i) => i.category == 'BOTTOM').toList();
            final shoes = fetchController.items.where((i) => i.category == 'SHOE').toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= SECTION 1 : LES DEUX INTERFACES D'AJOUT =================
                  const Text(
                    "AJOUTER UN VÊTEMENT",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Interface 1 : Galerie de fichiers (Pas de photo en direct)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleGalleryPicker(context),
                          icon: const Icon(Icons.folder_open_rounded),
                          label: const Text("Via Fichier / Galerie"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blueGrey[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Interface 2 : Appareil photo classique
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleCameraPicker(context),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text("Prendre Photo"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFC7FF00), // Style Néon de ton app
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),

                  // ================= SECTION 2 : OUTFIT BUILDER =================
                  const Text(
                    "OUTFIT BUILDER (CONSTRUIRE UN LOOK)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),

                  // Formulaire de saisie d'outfit
                  TextField(
                    controller: _outfitNameController,
                    decoration: const InputDecoration(
                      labelText: "Nom de l'Outfit *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _outfitDescController,
                    decoration: const InputDecoration(
                      labelText: "Description (Optionnel)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sélectionneurs Horizontaux de Vêtements Réels
                  _buildOutfitSelectorSection("Sélectionner un Haut (TOP)", tops, selectedTop, (item) {
                    setState(() => selectedTop = item);
                  }),

                  _buildOutfitSelectorSection("Sélectionner un Bas (BOTTOM)", bottoms, selectedBottom, (item) {
                    setState(() => selectedBottom = item);
                  }),

                  _buildOutfitSelectorSection("Sélectionner des Chaussures (SHOE)", shoes, selectedShoe, (item) {
                    setState(() => selectedShoe = item);
                  }),

                  const SizedBox(height: 24),

                  // Bouton de Sauvegarde de l'Outfit complet
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSavingOutfit ? null : _saveOutfit,
                      icon: _isSavingOutfit
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                      )
                          : const Icon(Icons.save_rounded),
                      label: const Text("SAUVEGARDER L'OUTFIT CHOSI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7FF00),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget générique de carrousel de sélection pour l'Outfit Builder
  Widget _buildOutfitSelectorSection(
      String title,
      List<CameraItem> items,
      CameraItem? selectedItem,
      ValueWith<CameraItem> onSelected
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        items.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Aucun vêtement disponible dans cette catégorie.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        )
            : SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isCurrentSelected = selectedItem?.id == item.id;

              return GestureDetector(
                onTap: () => onSelected(item),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCurrentSelected ? const Color(0xFFC7FF00) : Colors.grey[300]!,
                      width: isCurrentSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.hasImage
                              ? SignedItemImage(imageUrl: item.imageUrl!)
                              : ImagePlaceholder(text: item.imageStatus),
                        ),
                      ),
                      Container(
                        color: isCurrentSelected ? const Color(0xFFC7FF00).withOpacity(0.2) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        width: double.infinity,
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrentSelected ? FontWeight.bold : FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Définition de type simple pour les callbacks
typedef ValueWith<T> = void Function(T value);