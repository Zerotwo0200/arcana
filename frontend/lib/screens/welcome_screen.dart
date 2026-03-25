import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthService>();
    final error = _isLogin
        ? await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text)
        : await auth.register(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    if (error != null) {
      setState(() { _error = error; _loading = false; });
    } else if (!_isLogin) {
      setState(() {
        _isLogin = true;
        _loading = false;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация успешна — войдите')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0E3A), Color(0xFF07061A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Logo
                  Text('✦', style: TextStyle(
                    fontSize: 40,
                    color: const Color(0xFFC8A84B).withOpacity(0.8),
                  )).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.5, 0.5)),

                  const SizedBox(height: 16),

                  Text('ARCANA',
                    style: GoogleFonts.cinzelDecorative(
                      color: const Color(0xFFC8A84B),
                      fontSize: 36,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                  const SizedBox(height: 8),

                  Text('ТАРО · ОРАКУЛ · СУДЬБА',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFF8A8070),
                      fontSize: 10,
                      letterSpacing: 5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 48),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0A2A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7A5C1A)),
                    ),
                    child: Column(
                      children: [
                        Text(_isLogin ? 'Вход' : 'Регистрация',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFC8A84B),
                            fontSize: 16,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _ArcanaField(
                          controller: _emailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _ArcanaField(
                          controller: _passwordCtrl,
                          label: 'Пароль',
                          obscure: true,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!,
                            style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFFC8A84B),
                              side: const BorderSide(color: Color(0xFFC8A84B)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: _loading
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFC8A84B), strokeWidth: 2))
                              : Text(
                                  _isLogin ? 'ВОЙТИ' : 'СОЗДАТЬ АККАУНТ',
                                  style: GoogleFonts.cinzel(letterSpacing: 4, fontSize: 13),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                          }),
                          child: Text(
                            _isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти',
                            style: GoogleFonts.cormorantGaramond(
                              color: const Color(0xFF8A8070),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcanaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;

  const _ArcanaField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.cormorantGaramond(
        color: const Color(0xFFE2D9C5),
        fontSize: 16,
        fontStyle: FontStyle.italic,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cinzel(
          color: const Color(0xFF8A8070),
          fontSize: 11,
          letterSpacing: 3,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7A5C1A)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC8A84B)),
        ),
      ),
    );
  }
}
