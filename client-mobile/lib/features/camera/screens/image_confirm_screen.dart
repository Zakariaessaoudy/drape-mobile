// Darija: Had screen kayban mn b3d ma user ytswer/selecti image.
// Hna kayconfirmi photo, kay3mer name/category/color, w kayseft item l backend.
import 'dart:io';

import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/features/camera/models/create_camera_item_request.dart';
import 'package:client_mobile/features/camera/state/add_camera_item_controller.dart';
import 'package:client_mobile/features/camera/widgets/category_picker.dart';
import 'package:client_mobile/shared/widgets/auth_text_field.dart';
import 'package:client_mobile/shared/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageConfirmScreen extends StatelessWidget {
  const ImageConfirmScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCameraItemController(),
      child: _ImageConfirmView(imagePath: imagePath),
    );
  }
}

class _ImageConfirmView extends StatefulWidget {
  const _ImageConfirmView({required this.imagePath});

  final String imagePath;

  @override
  State<_ImageConfirmView> createState() => _ImageConfirmViewState();
}

class _ImageConfirmViewState extends State<_ImageConfirmView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _createItem() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AddCameraItemController>();
    final created = await controller.createItem(
      CreateCameraItemRequest(
        name: _nameController.text,
        category: controller.category,
        color: _colorController.text,
        imagePath: widget.imagePath,
      ),
    );

    if (!mounted) return;

    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added. Image processing started.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      return;
    }

    if (controller.sessionExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error ?? 'Please login again.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddCameraItemController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _TopBar(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const FieldLabel('ITEM NAME'),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _nameController,
                hintText: 'Black Hoodie',
                validator: _required('Name is required'),
              ),
              const SizedBox(height: 18),
              const FieldLabel('CATEGORY'),
              const SizedBox(height: 10),
              CategoryPicker(
                value: controller.category,
                onChanged: controller.setCategory,
              ),
              const SizedBox(height: 18),
              const FieldLabel('COLOR'),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _colorController,
                hintText: 'black',
                validator: _required('Color is required'),
              ),
              if (controller.error != null && !controller.sessionExpired) ...[
                const SizedBox(height: 14),
                Text(
                  controller.error!,
                  style: const TextStyle(color: Color(0xFFFF6B6B)),
                ),
              ],
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.close_rounded,
                    iconColor: Colors.white,
                    backgroundColor: Colors.white12,
                    onTap: controller.loading
                        ? null
                        : () => Navigator.pop(context),
                    tooltip: 'Retake',
                  ),
                  _ActionButton(
                    icon: Icons.check_rounded,
                    iconColor: Colors.black,
                    backgroundColor: AuthColors.neon,
                    loading: controller.loading,
                    onTap: controller.loading ? null : _createItem,
                    tooltip: 'Add item',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) return message;
      return null;
    };
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Spacer(),
        Text(
          'Confirm item',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    required this.tooltip,
    this.loading = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final String tooltip;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: onTap == null ? 0.55 : 1),
            shape: BoxShape.circle,
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Icon(icon, color: iconColor, size: 32),
        ),
      ),
    );
  }
}
