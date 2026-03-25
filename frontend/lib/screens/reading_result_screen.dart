import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/tarot_cards.dart';
import '../services/readings_service.dart';
import '../widgets/tarot_card_widget.dart';

class ReadingResultScreen extends StatefulWidget {
  final Reading reading;
  const ReadingResultScreen({super.key, required this.reading});
  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen> {
  String _displayed = '';

  @override
  void initState() {
    super.initState();
    _typewrite();
  }

  Future<void> _typewrite() async {
    final full = widget.reading.interpretation ?? '';
    for (int i = 0; i < full.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => _displayed = full.substring(0, i + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = kSpreadLabels[widget.reading.spreadType] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF07061A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF07061A),
            leading: IconButton(
              icon: const Text('←', style: TextStyle(color: Color(0xFFC8A84B), fontSize: 22)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('ПОСЛАНИЕ ОРАКУЛА',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFC8A84B),
                fontSize: 13, letterSpacing: 4,
              ),
            ),
            pinned: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Question
                  if (widget.reading.question != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E0A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3A1F6E)),
                      ),
                      child: Text('"${widget.reading.question}"',
                        style: GoogleFonts.cormorantGaramond(
                          color: const Color(0xFFCBC4B4),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Cards row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.reading.cards.length, (i) {
                        final card  = widget.reading.cards[i];
                        final label = i < labels.length ? labels[i] : '';
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
                              TarotCardWidget(card: card, flipped: true)
                                .animate(delay: (i * 150).ms)
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.3),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Oracle box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0A2A).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7A5C1A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('◎',
                              style: TextStyle(color: Color(0xFFC8A84B), fontSize: 16)),
                            const SizedBox(width: 10),
                            Text('ТОЛКОВАНИЕ',
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFC8A84B),
                                fontSize: 11, letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _displayed,
                          style: GoogleFonts.cormorantGaramond(
                            color: const Color(0xFFCBC4B4),
                            fontSize: 16,
                            height: 1.8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        // Cursor blink
                        if (_displayed.length < (widget.reading.interpretation?.length ?? 0))
                          AnimatedOpacity(
                            opacity: 1,
                            duration: 500.ms,
                            child: Container(
                              width: 2, height: 18,
                              color: const Color(0xFFC8A84B),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .fadeIn(duration: 500.ms),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // Date
                  Center(
                    child: Text(
                      _formatDate(widget.reading.createdAt),
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFF5F5E5A),
                        fontSize: 10, letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['ЯНВ','ФЕВ','МАР','АПР','МАЙ','ИЮН',
                    'ИЮЛ','АВГ','СЕН','ОКТ','НОЯ','ДЕК'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  ·  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}
