import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/tarot_cards.dart';
import '../services/auth_service.dart';
import '../services/readings_service.dart';
import '../widgets/tarot_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Reading> _readings = [];
  bool _loading = true;

  // Карта дня — детерминирована по дате, меняется каждый день
  late final TarotCard _cardOfDay;
  late final bool _cardReversed;

  @override
  void initState() {
    super.initState();
    _initDailyCard();
    _loadStats();
  }

  void _initDailyCard() {
    final now = DateTime.now();
    // seed = YYYYMMDD — один и тот же результат весь день
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);
    final idx = rng.nextInt(kAllCards.length);
    _cardOfDay = kAllCards[idx];
    _cardReversed = rng.nextDouble() < 0.3;
  }

  Future<void> _loadStats() async {
    try {
      final service = ReadingsService(context.read<AuthService>());
      final data = await service.getHistory();
      setState(() { _readings = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String get _email => context.read<AuthService>().email ?? '';

  Map<String, int> get _spreadCounts {
    final counts = {'1': 0, '3': 0, '5': 0};
    for (final r in _readings) {
      counts[r.spreadType] = (counts[r.spreadType] ?? 0) + 1;
    }
    return counts;
  }

  String _dailyMessage() {
    final meanings = {
      'O': 'Сегодня — день новых начинаний.',
      'I': 'Ваша сила сегодня на пике.',
      'II': 'Прислушайтесь к интуиции.',
      'III': 'День благоприятен для творчества.',
      'IV': 'Возьмите ситуацию под контроль.',
      'V': 'Обратитесь к мудрым советникам.',
      'VI': 'Важный выбор ждёт сегодня.',
      'VII': 'Движение и прогресс — ваши союзники.',
      'VIII': 'Действуйте мягко, но уверенно.',
      'IX': 'Уединение принесёт ясность.',
      'X': 'Колесо поворачивается — будьте готовы.',
      'XI': 'День требует честности.',
      'XII': 'Взгляните на ситуацию иначе.',
      'XIII': 'Отпустите старое — откроется новое.',
      'XIV': 'Ищите баланс во всём.',
      'XV': 'Осознайте свои привязанности.',
      'XVI': 'Перемены неизбежны — примите их.',
      'XVII': 'Надежда освещает ваш путь.',
      'XVIII': 'Не всё то, чем кажется.',
      'XIX': 'День несёт радость и ясность.',
      'XX': 'Прислушайтесь к внутреннему призыву.',
      'XXI': 'Цикл завершается с победой.',
    };
    final msg = meanings[_cardOfDay.num] ?? 'Карты говорят — действуйте.';
    return _cardReversed ? 'Будьте осторожны сегодня. $msg' : msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07061A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07061A),
        title: Text('ПРОФИЛЬ', style: GoogleFonts.cinzel(
          color: const Color(0xFFC8A84B), fontSize: 14, letterSpacing: 6)),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthService>().logout(),
            child: Text('ВЫЙТИ', style: GoogleFonts.cinzel(
              color: const Color(0xFF8A8070), fontSize: 10, letterSpacing: 3)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // Avatar + email
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A1F6E)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC8A84B), width: 1.5),
                      color: const Color(0xFF1A0E3A),
                    ),
                    child: Center(
                      child: Text(
                        _email.isNotEmpty ? _email[0].toUpperCase() : '✦',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFC8A84B), fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ИСКАТЕЛЬ ТАЙН', style: GoogleFonts.cinzel(
                        color: const Color(0xFF8A8070), fontSize: 9, letterSpacing: 3)),
                      const SizedBox(height: 4),
                      Text(_email, style: GoogleFonts.cormorantGaramond(
                        color: const Color(0xFFE2D9C5), fontSize: 15,
                        fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Stats row
            if (!_loading) Row(children: [
              _StatCard(
                value: _readings.length.toString(),
                label: 'Всего\nраскладов',
              ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              _StatCard(
                value: (_spreadCounts['3']! + _spreadCounts['5']!).toString(),
                label: 'Глубоких\nраскладов',
              ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              _StatCard(
                value: _spreadCounts['1'].toString(),
                label: 'Карт\nдня',
              ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
            ]),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: Color(0xFFC8A84B)),
              ),

            const SizedBox(height: 20),

            // Daily card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7A5C1A)),
              ),
              child: Column(
                children: [
                  Row(children: [
                    const Text('☀', style: TextStyle(fontSize: 16, color: Color(0xFFC8A84B))),
                    const SizedBox(width: 10),
                    Text('КАРТА ДНЯ', style: GoogleFonts.cinzel(
                      color: const Color(0xFFC8A84B), fontSize: 11, letterSpacing: 4)),
                    const Spacer(),
                    Text(_todayLabel(), style: GoogleFonts.cinzel(
                      color: const Color(0xFF5F5E5A), fontSize: 9, letterSpacing: 2)),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TarotCardWidget(
                        card: TarotCard(
                          num: _cardOfDay.num,
                          name: _cardOfDay.name,
                          sym: _cardOfDay.sym,
                          keys: _cardOfDay.keys,
                          reversed: _cardReversed,
                        ),
                        flipped: true,
                      ).animate().scale(
                        begin: const Offset(0.7, 0.7),
                        curve: Curves.elasticOut,
                        duration: 700.ms,
                        delay: 300.ms,
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_cardOfDay.name, style: GoogleFonts.cinzel(
                            color: const Color(0xFFC8A84B), fontSize: 14, letterSpacing: 2)),
                          if (_cardReversed) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF6A3A3A)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Перевёрнутая', style: GoogleFonts.cinzel(
                                color: const Color(0xFF8B6060), fontSize: 8, letterSpacing: 1)),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(_dailyMessage(), style: GoogleFonts.cormorantGaramond(
                            color: const Color(0xFFCBC4B4), fontSize: 14,
                            fontStyle: FontStyle.italic, height: 1.6)),
                          const SizedBox(height: 10),
                          Text(_cardOfDay.keys, style: GoogleFonts.cinzel(
                            color: const Color(0xFF5F5E5A), fontSize: 9, letterSpacing: 1)),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Most frequent card
            if (_readings.isNotEmpty) _buildFavCard()
              .animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

          ],
        ),
      ),
    );
  }

  Widget _buildFavCard() {
    // Находим самую часто выпадавшую карту
    final counts = <String, int>{};
    for (final r in _readings) {
      for (final c in r.cards) {
        counts[c.name] = (counts[c.name] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const SizedBox();
    final top = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A1F6E)),
      ),
      child: Row(children: [
        const Text('◈', style: TextStyle(color: Color(0xFF7A5C1A), fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ВАША КАРТА', style: GoogleFonts.cinzel(
            color: const Color(0xFF8A8070), fontSize: 9, letterSpacing: 3)),
          const SizedBox(height: 4),
          Text(top.key, style: GoogleFonts.cormorantGaramond(
            color: const Color(0xFFC8A84B), fontSize: 16, fontStyle: FontStyle.italic)),
          Text('выпала ${top.value} раз', style: GoogleFonts.cinzel(
            color: const Color(0xFF5F5E5A), fontSize: 9, letterSpacing: 2)),
        ])),
      ]),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    final months = ['янв','фев','мар','апр','май','июн',
                    'июл','авг','сен','окт','ноя','дек'];
    return '${now.day} ${months[now.month - 1]}';
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A1F6E)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.cinzel(
            color: const Color(0xFFC8A84B), fontSize: 28, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: const Color(0xFF5F5E5A), fontSize: 8, letterSpacing: 1, height: 1.5)),
        ]),
      ),
    );
  }
}
