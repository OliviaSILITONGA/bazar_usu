import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/profile_state.dart';
import 'edit_profile_page.dart';

class ProfileViewPage extends StatelessWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: kDarkGreen,
                  ),
                  const Expanded(
                    child: Text(
                      'Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<ProfileData>(
                valueListenable: ProfileState.instance.data,
                builder: (context, profile, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: kLightGreen,
                          backgroundImage: profile.photo != null
                              ? FileImage(profile.photo!)
                              : null,
                          child: profile.photo == null
                              ? Icon(
                                  Icons.person,
                                  size: 48,
                                  color: kDarkGreen.withValues(alpha: 0.6),
                                )
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkGreen,
                          ),
                        ),
                        if (profile.username.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${profile.username}',
                            style: TextStyle(
                              fontSize: 13,
                              color: kDarkGreen.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        if (profile.bio.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Bio : ${profile.bio}',
                            style: TextStyle(
                              fontSize: 13,
                              color: kDarkGreen.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (profile.address.trim().isNotEmpty)
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat :',
                            value: profile.address,
                          ),
                        if (profile.phone.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.call_outlined,
                            label: 'No. Telepon :',
                            value: profile.phone,
                          ),
                        ],
                        const SizedBox(height: 28),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kDarkGreen,
                            side: BorderSide(
                              color: kDarkGreen.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Edit Profil',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kDarkGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: kDarkGreen.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
