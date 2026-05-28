import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'providers/finance_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dotenv and Supabase
  try {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (e) {
    debugPrint('Supabase/Dotenv initialization error: $e');
  }

  // Initialize locale for Indonesian date formatting (non-blocking)
  try {
    await initializeDateFormatting('id_ID', null).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Date formatting initialization timed out');
      },
    );
  } catch (e) {
    debugPrint('Date formatting initialization error: $e');
  }

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const FinaFlowApp());
}

class FinaFlowApp extends StatelessWidget {
  const FinaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
      child: MaterialApp(
        title: 'FinaFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _SplashScreen(),
      ),
    );
  }
}

/// Splash screen dengan animasi sebelum masuk ke Login
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.75, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          // Inisialisasi data provider sebelum lanjut ke dashboard
          final provider = Provider.of<FinanceProvider>(context, listen: false);
          await provider.initializeUserSession();
          
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        debugPrint('Navigation auth check error: $e');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, __) => FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo container
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppTheme.primary,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'FinaFlow',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Pengelolaan Keuangan Digital',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
