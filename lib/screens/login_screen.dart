import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'home_page_user.dart';
import 'admin_dashboard_page.dart'; // Import halaman admin

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi!')),
      );
      return;
    }

    // SIMULASI LOGIN UNTUK DEMO FRONTEND
    if (email.contains('admin')) {
      // Masuk ke Halaman Admin jika email mengandung kata "admin"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } else {
      // Masuk ke Halaman User untuk email biasa/lainnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageUser()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        AuthField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        AuthField(
          label: 'Password',
          controller: _passwordController,
          obscure: true,
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('Lupa Password?', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 20),
        AuthButton(text: 'Login', onPressed: _handleLogin),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: const Text.rich(
              TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Daftar',
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
