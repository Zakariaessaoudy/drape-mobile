import 'package:flutter/material.dart';

class SignupBackground extends StatelessWidget {
  const SignupBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 1. Base Gradient: Smoothed out the stops for a richer transition
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A4237), // Slightly brighter inner core
                    Color(0xFF091410), // Deep forest/emerald mid-tone
                    Colors.black, // True black at the edges
                  ],
                  stops: [0.0, 0.5, 1.0], // Controls the falloff smoothly
                ),
              ),
            ),
          ),

          // 2. Ambient Glow: Creates a "neon light off-screen" effect
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF7F).withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Vignette: Crucial for UI readability
          // Fades the bottom of the screen to deep black so buttons/text pop
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [
                    0.6,
                    0.85,
                    1.0,
                  ], // Pushes the dark fade to the very bottom
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
