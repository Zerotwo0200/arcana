import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/readings_service.dart';

class TarotCardWidget extends StatefulWidget {
  final TarotCard card;
  final bool flipped;
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onTap;

  const TarotCardWidget({
    super.key,
    required this.card,
    this.flipped = false,
    this.selectable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<TarotCardWidget> createState() => _TarotCardWidgetState();
}

class _TarotCardWidgetState extends State<TarotCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.flipped) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(TarotCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.flipped && !old.flipped) _ctrl.forward();
    if (!widget.flipped && old.flipped) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.selectable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (_, __) {
          final showFront = _flipAnim.value > pi / 2;
          final angle = showFront ? _flipAnim.value - pi : _flipAnim.value;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 80,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF12102B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected
              ? const Color(0xFFC8A84B)
              : const Color(0xFF7A5C1A),
          width: widget.isSelected ? 1.5 : 1,
        ),
        boxShadow: widget.isSelected
            ? [const BoxShadow(color: Color(0x55C8A84B), blurRadius: 12)]
            : [],
      ),
      child: Center(
        child: Text('✦',
          style: GoogleFonts.cinzel(
            color: const Color(0xFF7A5C1A),
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: 80,
        height: 130,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141130), Color(0xFF0B0921)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC8A84B), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x44C8A84B), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(widget.card.num,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFC8A84B),
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            if (widget.card.reversed)
              Transform.rotate(
                angle: pi,
                child: Text(widget.card.sym, style: const TextStyle(fontSize: 26)),
              )
            else
              Text(widget.card.sym, style: const TextStyle(fontSize: 26)),
            Text(
              widget.card.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFCBC4B4),
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (widget.card.reversed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6A3A3A)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('перев.',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFF8B6060),
                    fontSize: 7,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
