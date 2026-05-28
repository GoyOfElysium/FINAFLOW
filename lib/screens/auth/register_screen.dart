import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  String _role = 'Freelancer';
  final List<String> _roles = [
    'Freelancer',
    'Pekerja Kreatif',
    'Agensi Digital',
    'Mahasiswa'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Password tidak cocok');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    final provider = context.read<FinanceProvider>();
    final success = await provider.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error = provider.errorMessage ?? 'Gagal mendaftar. Periksa kembali data Anda.');
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Buat Akun FinaFlow',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // balance
                  ],
                ),
              ),
            ),
          ),

          // Form area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mulai kelola keuangan digitalmu',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 24),

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
                                      color: AppTheme.expense, fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role Selection
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      labelText: 'Peran',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: _roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _role = val ?? _role),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      hintText: 'Min. 6 karakter',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _confirmPassCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
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
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Buat Akun',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? ',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Masuk',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
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
