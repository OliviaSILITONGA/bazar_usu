import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'admin_dashboard_page.dart';
import 'forgot_password_page.dart';
import 'home_page_user.dart';
import 'ktm_pending_page.dart'; // Tambahkan import halaman pending
import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      _showWarning('Email dan Password wajib diisi!');
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
      // 1. Autentikasi masuk menggunakan Firebase Auth via AuthService
      final user = await _authService.loginWithEmailPassword(email, password);

      if (user != null && mounted) {
        // Jika email mengandung kata 'admin', arahkan langsung ke dashboard admin
        if (email.contains('admin')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
          return;
        }

        // 2. Ambil data dokumen user dari Cloud Firestore untuk cek status KTM
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final ktmStatus = data['ktmStatus'] ?? 'pending';

          // 3. Cek apakah status KTM sudah approved atau masih pending/rejected
          if (ktmStatus == 'approved') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePageUser()),
            );
          } else {
            // Jika masih pending atau ditolak, arahkan ke halaman tunggu/pending
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const KtmPendingPage()),
            );
          }
        } else {
          // Jika dokumen user belum ada di Firestore, arahkan ke halaman pending
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KtmPendingPage()),
          );
        }
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
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
              );
            },
            child: const Text(
              'Lupa Password?',
              style: TextStyle(
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
            : AuthButton(text: 'Login', onPressed: _handleLogin),
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
