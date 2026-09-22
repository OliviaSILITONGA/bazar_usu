import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import 'home_page_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _penjual = false;
  bool _pembeli = false;

  Widget _roleCheck(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: kGreen),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        const AuthField(label: 'Nama Lengkap'),
        const SizedBox(height: 16),
        const AuthField(
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const AuthField(
          label: 'Nomor WhatsApp/Telepon',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        const AuthField(label: 'Password', obscure: true),
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
        AuthButton(
          text: 'Daftar !!',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePageUser()),
            );
          },
        ),
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
