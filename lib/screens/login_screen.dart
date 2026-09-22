import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'home_page_user.dart'; // sesuaikan path kalau berbeda folder

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        const AuthField(
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const AuthField(label: 'Password', obscure: true),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('Lupa Password?', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 20),
        AuthButton(
          text: 'Login',
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
