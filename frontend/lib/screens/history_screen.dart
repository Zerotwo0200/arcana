import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/readings_service.dart';
import 'reading_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late ReadingsService _service;
  List<Reading> _readings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = ReadingsService(context.read<AuthService>());
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getHistory();
      setState(() { _readings = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(int id) async {
    await _service.deleteReading(id);
    await _load();
  }

  String _spreadLabel(String type) {
    switch (type) {
      case '1': return 'Карта дня';
      case '3': return 'Три карты';
      case '5': return 'Пять карт';
      default:  return 'Расклад';
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['янв','фев','мар','апр','май','июн',
                    'июл','авг','сен','окт','ноя','дек'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  ·  '
           '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07061A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07061A),
        title: Text('ИСТОРИЯ',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFC8A84B), fontSize: 14, letterSpacing: 6)),
        actions: [
          IconButton(
            icon: const Text('↺', style: TextStyle(color: Color(0xFF8A8070), fontSize: 20)),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC8A84B)));
    }
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✦', style: TextStyle(color: Color(0xFF3A1F6E), fontSize: 40)),
        const SizedBox(height: 16),
        Text('Ошибка загрузки', style: GoogleFonts.cormorantGaramond(
          color: const Color(0xFF8A8070), fontSize: 16, fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        TextButton(onPressed: _load,
          child: Text('Попробовать снова', style: GoogleFonts.cinzel(
            color: const Color(0xFFC8A84B), fontSize: 11, letterSpacing: 2))),
      ]));
    }
    if (_readings.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✦', style: TextStyle(color: Color(0xFF3A1F6E), fontSize: 40)),
        const SizedBox(height: 16),
        Text('Раскладов пока нет', style: GoogleFonts.cormorantGaramond(
          color: const Color(0xFF5F5E5A), fontSize: 18, fontStyle: FontStyle.italic)),
      ]));
    }
    return RefreshIndicator(
      color: const Color(0xFFC8A84B),
      backgroundColor: const Color(0xFF0E0A2A),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _readings.length,
        itemBuilder: (_, i) => _buildItem(_readings[i], i),
      ),
    );
  }

  Widget _buildItem(Reading r, int i) {
    return Dismissible(
      key: Key(r.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0A0A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('✕', style: TextStyle(color: Color(0xFFE24B4A), fontSize: 20)),
      ),
      onDismissed: (_) { _delete(r.id); },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReadingResultScreen(reading: r)),
        ).then((_) => _load()),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A1F6E)),
          ),
          child: Row(
            children: [
              SizedBox(width: 32,
                child: Column(children: r.cards.take(3).map((c) =>
                  Text(c.sym, style: const TextStyle(fontSize: 14))).toList())),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_spreadLabel(r.spreadType), style: GoogleFonts.cinzel(
                    color: const Color(0xFFC8A84B), fontSize: 11, letterSpacing: 2)),
                  if (r.question != null) ...[
                    const SizedBox(height: 4),
                    Text(r.question!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        color: const Color(0xFFCBC4B4),
                        fontSize: 14, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 4),
                  Text(_formatDate(r.createdAt), style: GoogleFonts.cinzel(
                    color: const Color(0xFF5F5E5A), fontSize: 9, letterSpacing: 2)),
                ],
              )),
              const Text('›', style: TextStyle(color: Color(0xFF7A5C1A), fontSize: 22)),
            ],
          ),
        ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.1),
      ),
    );
  }
}
