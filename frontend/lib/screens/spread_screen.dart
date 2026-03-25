import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/tarot_cards.dart';
import '../services/auth_service.dart';
import '../services/readings_service.dart';
import '../widgets/tarot_card_widget.dart';
import 'reading_result_screen.dart';

class SpreadScreen extends StatefulWidget {
  const SpreadScreen({super.key});
  @override
  State<SpreadScreen> createState() => _SpreadScreenState();
}

class _SpreadScreenState extends State<SpreadScreen> {
  final _questionCtrl = TextEditingController();
  String _spreadType  = '3';
  List<TarotCard> _shuffled = [];
  List<TarotCard> _selected = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final rng = Random();
    final cards = kAllCards.toList()..shuffle(rng);
    setState(() {
      _shuffled = cards;
      _selected = [];
    });
  }

  int get _needed => int.parse(_spreadType);

  void _pickCard(TarotCard card) {
    if (_selected.length >= _needed) return;
    if (_selected.contains(card)) return;
    final reversed = Random().nextDouble() < 0.3;
    setState(() {
      _selected.add(TarotCard(
        num: card.num, name: card.name,
        sym: card.sym, keys: card.keys,
        reversed: reversed,
      ));
    });
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    try {
      final auth    = context.read<AuthService>();
      final service = ReadingsService(auth);
      final reading = await service.createReading(
        question:    _questionCtrl.text.trim().isEmpty ? null : _questionCtrl.text.trim(),
        spreadType:  _spreadType,
        cards:       _selected,
      );
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReadingResultScreen(reading: reading),
      ));
      _shuffle();
      _questionCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07061A),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: const Color(0xFF07061A),
            pinned: true,
            title: Text('ARCANA',
              style: GoogleFonts.cinzelDecorative(
                color: const Color(0xFFC8A84B),
                fontSize: 18,
                letterSpacing: 8,
              ),
            ),
            actions: [
              IconButton(
                icon: const Text('↩', style: TextStyle(color: Color(0xFF8A8070), fontSize: 18)),
                onPressed: () => context.read<AuthService>().logout(),
                tooltip: 'Выйти',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Question input
                  Text('ВАШ ВОПРОС',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFF8A8070),
                      fontSize: 10, letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionCtrl,
                    maxLines: 2,
                    style: GoogleFonts.cormorantGaramond(
                      color: const Color(0xFFE2D9C5),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Что беспокоит вас сейчас?...',
                      hintStyle: GoogleFonts.cormorantGaramond(
                        color: const Color(0xFF5F5E5A),
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0E0A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF7A5C1A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF7A5C1A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC8A84B)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Spread type
                  Text('ТИП РАСКЛАДА',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFF8A8070),
                      fontSize: 10, letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SpreadChip(label: '1 карта', value: '1', selected: _spreadType == '1',
                        onTap: () => setState(() { _spreadType = '1'; _selected = []; })),
                      const SizedBox(width: 10),
                      _SpreadChip(label: '3 карты', value: '3', selected: _spreadType == '3',
                        onTap: () => setState(() { _spreadType = '3'; _selected = []; })),
                      const SizedBox(width: 10),
                      _SpreadChip(label: '5 карт', value: '5', selected: _spreadType == '5',
                        onTap: () => setState(() { _spreadType = '5'; _selected = []; })),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Selected positions
                  if (_selected.isNotEmpty) ...[
                    Text('ВЫБРАННЫЕ КАРТЫ',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFF8A8070),
                        fontSize: 10, letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_needed, (i) {
                          final label = kSpreadLabels[_spreadType]![i];
                          final hasCard = i < _selected.length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Text(label.toUpperCase(),
                                  style: GoogleFonts.cinzel(
                                    color: const Color(0xFF8A8070),
                                    fontSize: 8, letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                hasCard
                                  ? TarotCardWidget(
                                      card: _selected[i],
                                      flipped: true,
                                    ).animate().scale(
                                      begin: const Offset(0.6, 0.6),
                                      curve: Curves.elasticOut,
                                      duration: 500.ms,
                                    )
                                  : Container(
                                      width: 80, height: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF3A1F6E),
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text('✦',
                                          style: TextStyle(color: Color(0xFF3A1F6E), fontSize: 20)),
                                      ),
                                    ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Progress
                  Row(
                    children: [
                      Text('КОЛОДА',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFF8A8070),
                          fontSize: 10, letterSpacing: 4,
                        ),
                      ),
                      const Spacer(),
                      Text('${_selected.length} / $_needed',
                        style: GoogleFonts.cormorantGaramond(
                          color: const Color(0xFFC8A84B),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _shuffle,
                        child: Text('перемешать',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFF5F5E5A),
                            fontSize: 9, letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Deck grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final card = _shuffled[i];
                  final isSelected = _selected.any((c) => c.num == card.num);
                  return TarotCardWidget(
                    card: card,
                    selectable: !isSelected && _selected.length < _needed,
                    isSelected: isSelected,
                    onTap: () => _pickCard(card),
                  ).animate(delay: (i * 20).ms)
                   .fadeIn(duration: 300.ms)
                   .slideY(begin: 0.15);
                },
                childCount: _shuffled.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 80 / 130,
              ),
            ),
          ),

          // Reveal button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: AnimatedOpacity(
                opacity: _selected.length == _needed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: (_selected.length == _needed && !_loading) ? _getReading : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFC8A84B),
                    side: const BorderSide(color: Color(0xFFC8A84B)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFFC8A84B), strokeWidth: 2))
                    : Text('✦  ОТКРЫТЬ ПОСЛАНИЕ  ✦',
                        style: GoogleFonts.cinzel(fontSize: 13, letterSpacing: 4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpreadChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _SpreadChip({required this.label, required this.value,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFC8A84B) : const Color(0xFF7A5C1A),
          ),
          color: selected ? const Color(0xFFC8A84B).withOpacity(0.08) : Colors.transparent,
        ),
        child: Text(label,
          style: GoogleFonts.cinzel(
            color: selected ? const Color(0xFFC8A84B) : const Color(0xFF8A8070),
            fontSize: 11, letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
