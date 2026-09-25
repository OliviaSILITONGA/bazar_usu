import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import 'home_page_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/icon/icon.png',
          height: 32,
          errorBuilder: (_, __, ___) => const Text(
            'Bazar USU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: kDarkGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _penjual = false;
  bool _pembeli = false;

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
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
    if (!_penjual && !_pembeli) {
      _showWarning('Pilih minimal satu peran (Penjual/Panitia atau Pembeli)!');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePageUser()),
    );
  }

  Widget _roleCheck(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: kGreen),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        const SizedBox(height: 20),
        const Text(
          'Apa peranmu disini?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kGreen,
          ),
        ),
        _roleCheck(
          'Penjual/Panitia',
          _penjual,
          (v) => setState(() => _penjual = v ?? false),
        ),
        _roleCheck(
          'Pembeli',
          _pembeli,
          (v) => setState(() => _pembeli = v ?? false),
        ),
        const SizedBox(height: 16),
        AuthButton(text: 'Daftar !!', onPressed: _handleRegister),
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
