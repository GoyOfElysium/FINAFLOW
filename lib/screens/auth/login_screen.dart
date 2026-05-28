import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password harus diisi');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final success =
          await provider.login(_emailCtrl.text.trim(), _passCtrl.text.trim());

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(
            () => _error = provider.errorMessage ?? 'Email atau password tidak valid (min. 6 karakter)');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      setState(() => _error = 'Error: $e');
      debugPrint('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Blue curved header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppTheme.primary, size: 44),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'FinaFlow',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola keuangan digitalmu dengan mudah',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Masuk ke Akun',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 4),
                  const Text('Selamat datang kembali!',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 24),

                  // Error
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.expense.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.expense.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.expense, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: AppTheme.expense, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'contoh@email.com',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      hintText: 'Min. 6 karakter',
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Masuk',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(children: [
                    const Expanded(
                        child: Divider(color: AppTheme.divider, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau',
                          style: TextStyle(
                              color: AppTheme.textSecondary.withValues(alpha: 0.7),
                              fontSize: 13)),
                    ),
                    const Expanded(
                        child: Divider(color: AppTheme.divider, thickness: 1)),
                  ]),
                  const SizedBox(height: 20),

                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? ',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
