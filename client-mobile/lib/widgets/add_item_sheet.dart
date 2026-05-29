import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/wardrobe_provider.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'TOP';
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image.')),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<WardrobeProvider>().addItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        color: _colorController.text.trim(),
        imageFile: _selectedImage!,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: const Color(0xFF222222),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Category'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'TOP', child: Text('TOP')),
                  DropdownMenuItem(value: 'BOTTOM', child: Text('BOTTOM')),
                  DropdownMenuItem(value: 'SHOE', child: Text('SHOE')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _colorController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Color is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSubmitting ? null : _pickImage,
                child: const Text('Pick image from gallery'),
              ),
              if (_selectedImage != null) ...<Widget>[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FutureBuilder<Uint8List>(
                    future: _selectedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildPreviewFallback();
                      }

                      return Container(
                        height: 100,
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFC6F135),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6F135),
                    foregroundColor: const Color(0xFF111111),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF111111),
                            ),
                          ),
                        )
                      : const Text('ADD ITEM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewFallback() {
    return Container(
      height: 100,
      color: Colors.white10,
      alignment: Alignment.center,
      child: const Text(
        'Image preview unavailable',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
