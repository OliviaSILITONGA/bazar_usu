import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart'; // Import service firebase auth kamu
import 'ktm_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final nim = _nimController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      _showWarning('Nama Lengkap wajib diisi!');
      return;
    }
    if (email.isEmpty) {
      _showWarning('Email wajib diisi!');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showWarning('Format email tidak valid!');
      return;
    }
    if (nim.isEmpty) {
      _showWarning('NIM wajib diisi!');
      return;
    }
    if (phone.isEmpty) {
      _showWarning('Nomor WhatsApp/Telepon wajib diisi!');
      return;
    }
    if (password.isEmpty) {
      _showWarning('Password wajib diisi!');
      return;
    }
    if (password.length < 6) {
      _showWarning('Password minimal 6 karakter!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Proses pendaftaran akun baru ke Firebase Authentication
      await _authService.registerWithEmailPassword(email, password);

      if (mounted) {
        // Navigasi ke halaman verifikasi KTM setelah berhasil daftar di Firebase
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KtmVerificationPage(userName: name, userNim: nim),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showWarning(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        AuthField(label: 'Nama Lengkap', controller: _nameController),
        const SizedBox(height: 16),
        AuthField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'NIM',
          controller: _nimController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Nomor WhatsApp/Telepon',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Password',
          controller: _passwordController,
          obscure: true,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
            : AuthButton(text: 'Daftar !!', onPressed: _handleRegister),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Text.rich(
              TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: kGreen,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
