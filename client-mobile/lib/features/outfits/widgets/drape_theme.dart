// widgets/drape_theme.dart
//
// Centralised design tokens extracted from the DRAPE screenshot.
// If your project already has a ThemeData / AppTheme class, reference
// those values instead and delete this file.

import 'package:flutter/material.dart';

class DrapeColors {
  DrapeColors._();

  static const background = Color(0xFFF0EDE6);   // warm off-white
  static const surface    = Color(0xFFEAE7E0);   // slightly darker off-white
  static const accent     = Color(0xFFCAFF00);   // acid green (logo color)
  static const dark       = Color(0xFF121212);   // near-black header/text
  static const cardBg     = Color(0xFFE3E0D8);
  static const divider    = Color(0xFFD0CCC4);
  static const textPrimary   = Color(0xFF121212);
  static const textSecondary = Color(0xFF6B6B63);
  static const white      = Colors.white;
  static const error      = Color(0xFFFF4545);
}

class DrapeTextStyles {
  DrapeTextStyles._();

  static const _base = TextStyle(
    fontFamily: 'Helvetica Neue', // falls back to system sans-serif
    color: DrapeColors.textPrimary,
  );

  static final heading1 = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static final heading2 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static final label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  static final labelSmall = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: DrapeColors.textSecondary,
  );

  static final body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final price = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: DrapeColors.textSecondary,
  );
}

class DrapeSpacing {
  DrapeSpacing._();
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

class DrapeRadius {
  DrapeRadius._();
  static const sm  = Radius.circular(8);
  static const md  = Radius.circular(16);
  static const lg  = Radius.circular(24);
  static const pill = Radius.circular(100);
}