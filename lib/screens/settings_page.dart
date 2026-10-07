import 'package:flutter/material.dart';

import '../constants.dart';

// Versi aplikasi — ganti di sini kalau nanti rilis versi baru.
const String kAppVersion = 'Bazar USU v1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _openChangePasswordForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Pengaturan',
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  // ========== 1. AKUN & KEAMANAN ==========
                  _SectionLabel('Akun & Keamanan'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          label: 'Ubah Kata Sandi',
                          onTap: () => _openChangePasswordForm(context),
                        ),
                        Divider(
                          height: 1,
                          indent: 58,
                          color: kDarkGreen.withValues(alpha: 0.08),
                        ),
                        const _VerificationStatusTile(
                          label: 'Email',
                          value: 'email@students.usu.ac.id',
                          isVerified: true,
                        ),
                        Divider(
                          height: 1,
                          indent: 58,
                          color: kDarkGreen.withValues(alpha: 0.08),
                        ),
                        const _VerificationStatusTile(
                          label: 'Nomor Ponsel',
                          value: '+62 8xx-xxxx-xxxx',
                          isVerified: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ========== 2. INFORMASI TAMBAHAN & TINDAKAN AKUN ==========
                  _SectionLabel('Informasi Tambahan & Tindakan Akun'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const _VersionInfoTile(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== LABEL SECTION ====================
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: kDarkGreen.withValues(alpha: 0.55),
      ),
    );
  }
}

// ==================== TILE MENU BIASA (contoh: Ubah Kata Sandi) ====================
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: kLightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 17,
                color: kDarkGreen.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13.5, color: kDarkGreen),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: kDarkGreen.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STATUS VERIFIKASI (email / no hp) ====================
class _VerificationStatusTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isVerified;
  const _VerificationStatusTile({
    required this.label,
    required this.value,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: kLightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              label == 'Email'
                  ? Icons.email_outlined
                  : Icons.phone_iphone_outlined,
              size: 17,
              color: kDarkGreen.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kDarkGreen,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFF34A853).withValues(alpha: 0.12)
                  : const Color(0xFFE09A2E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.error_outline,
                  size: 12,
                  color: isVerified
                      ? const Color(0xFF34A853)
                      : const Color(0xFFE09A2E),
                ),
                const SizedBox(width: 4),
                Text(
                  isVerified ? 'Terverifikasi' : 'Belum Verifikasi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isVerified
                        ? const Color(0xFF34A853)
                        : const Color(0xFFE09A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== INFO VERSI APLIKASI ====================
class _VersionInfoTile extends StatelessWidget {
  const _VersionInfoTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: kLightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, size: 17, color: kDarkGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Versi Aplikasi',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  kAppVersion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kDarkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FORM UBAH KATA SANDI ====================
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String hint, {
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDarkGreen, width: 2),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 19,
          color: kDarkGreen.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  void _submit() {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Semua field wajib diisi!');
      return;
    }
    if (newPassword.length < 6) {
      _showError('Kata sandi baru minimal 6 karakter.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showError('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    // Catatan: belum terhubung ke backend/auth sungguhan.
    // Nanti di sini tinggal panggil API ganti password.
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil diperbarui.'),
        backgroundColor: kDarkGreen,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ubah Kata Sandi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Kata Sandi Lama',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: _decoration(
                'Masukkan kata sandi lama',
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Kata Sandi Baru',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: _decoration(
                'Minimal 6 karakter',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Konfirmasi Kata Sandi Baru',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: _decoration(
                'Ulangi kata sandi baru',
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
