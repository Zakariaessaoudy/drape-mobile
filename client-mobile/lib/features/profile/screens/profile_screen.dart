import 'package:client_mobile/core/constants/app_constants.dart';
import 'package:client_mobile/core/storage/token_storage.dart';
import 'package:client_mobile/features/outfits/data/outfit_api.dart';
import 'package:client_mobile/features/wardrobe/data/item_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.onOpenWardrobe,
    this.onOpenOutfits,
    this.onSignOut,
  });

  final VoidCallback? onOpenWardrobe;
  final VoidCallback? onOpenOutfits;
  final Future<void> Function()? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<void> _refresh() async {
    final nextProfile = _loadProfile();
    setState(() {
      _profileFuture = nextProfile;
    });
    await nextProfile;
  }

  Future<_ProfileViewData> _loadProfile() async {
    final userInfo = await TokenStorage().readUserInfo();
    final counts = await _loadCounts();

    return _ProfileViewData(
      name: userInfo.displayName,
      email: userInfo.email,
      planLabel: 'PRO PLAN ACTIVE',
      counts: counts,
    );
  }

  Future<_ProfileCounts> _loadCounts() async {
    final itemCount = await _safeCount(() => ItemApi().fetchItems());
    final outfitCount = await _safeCount(() => OutfitApi().fetchOutfits());

    return _ProfileCounts(
      items: itemCount,
      outfits: outfitCount,
      tryOns: 0,
    );
  }

  Future<int> _safeCount<T>(Future<List<T>> Function() loader) async {
    try {
      return (await loader()).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _handleSignOut() async {
    if (widget.onSignOut != null) {
      await widget.onSignOut!();
      return;
    }

    await TokenStorage().clearToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileViewData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? _ProfileViewData.fallback();

        return RefreshIndicator(
          color: AuthColors.neon,
          backgroundColor: Colors.black,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _ProfileAvatar(initials: profile.initials),
                    const SizedBox(height: 18),
                    Text(
                      profile.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 31,
                        height: 0.95,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (profile.email != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.email!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF8A8A8A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      profile.planLabel,
                      style: GoogleFonts.spaceGrotesk(
                        color: AuthColors.neon,
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _StatsRow(counts: profile.counts),
                    const SizedBox(height: 32),
                    _ActionPanel(
                      onOpenWardrobe: widget.onOpenWardrobe,
                      onOpenOutfits: widget.onOpenOutfits,
                    ),
                    const SizedBox(height: 34),
                    TextButton(
                      onPressed: _handleSignOut,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF704F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AuthColors.neon.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: AuthColors.neon.withValues(alpha: 0.56),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3D3D3D),
                Color(0xFF111111),
              ],
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.counts});

  final _ProfileCounts counts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: counts.items.toString(),
            label: 'ITEMS',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            value: counts.outfits.toString(),
            label: 'OUTFITS',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            value: counts.tryOns.toString(),
            label: 'TRY-ONS',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFB8B8B8),
              fontSize: 8,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({this.onOpenWardrobe, this.onOpenOutfits});

  final VoidCallback? onOpenWardrobe;
  final VoidCallback? onOpenOutfits;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.checkroom_outlined,
            label: 'My Wardrobe',
            onTap: onOpenWardrobe,
          ),
          const _ActionDivider(),
          _ActionTile(
            icon: Icons.auto_awesome,
            label: 'Saved Outfits',
            onTap: onOpenOutfits,
          ),
          const _ActionDivider(),
          const _ActionTile(
            icon: Icons.tune,
            label: 'Preferences',
          ),
          const _ActionDivider(),
          const _ActionTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                color: AuthColors.neon,
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFA7A7A7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionDivider extends StatelessWidget {
  const _ActionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF252525),
      height: 1,
      indent: 58,
    );
  }
}

class _ProfileViewData {
  const _ProfileViewData({
    required this.name,
    required this.email,
    required this.planLabel,
    required this.counts,
  });

  final String name;
  final String? email;
  final String planLabel;
  final _ProfileCounts counts;

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'CM';
    if (words.length == 1) {
      final end = words.first.length < 2 ? words.first.length : 2;
      return words.first.substring(0, end).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  factory _ProfileViewData.fallback() {
    return const _ProfileViewData(
      name: 'CoutureMember',
      email: null,
      planLabel: 'PRO PLAN ACTIVE',
      counts: _ProfileCounts(items: 0, outfits: 0, tryOns: 0),
    );
  }
}

class _ProfileCounts {
  const _ProfileCounts({
    required this.items,
    required this.outfits,
    required this.tryOns,
  });

  final int items;
  final int outfits;
  final int tryOns;
}
