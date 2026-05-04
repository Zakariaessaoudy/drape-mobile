// Darija: Had widget dropdown dyal categories TOP/BOTTOM/SHOE.
// Khllinah reusable bach wardrobe/outfits y9dro yst3mloh.
import 'package:client_mobile/core/constants/api_constants.dart';
import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AuthColors.field,
      iconEnabledColor: AuthColors.neon,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AuthColors.field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
      items: const [
        DropdownMenuItem(value: ApiConstants.categoryTop, child: Text('TOP')),
        DropdownMenuItem(
          value: ApiConstants.categoryBottom,
          child: Text('BOTTOM'),
        ),
        DropdownMenuItem(value: ApiConstants.categoryShoe, child: Text('SHOE')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
