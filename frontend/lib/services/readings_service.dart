import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class TarotCard {
  final String num;
  final String name;
  final String sym;
  final String keys;
  final bool reversed;

  const TarotCard({
    required this.num,
    required this.name,
    required this.sym,
    required this.keys,
    this.reversed = false,
  });

  Map<String, dynamic> toJson() => {
    'num': num,
    'name': name,
    'keys': keys,
    'reversed': reversed,
  };
}

class Reading {
  final int id;
  final String? question;
  final String spreadType;
  final List<TarotCard> cards;
  final String? interpretation;
  final DateTime createdAt;

  Reading({
    required this.id,
    this.question,
    required this.spreadType,
    required this.cards,
    this.interpretation,
    required this.createdAt,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    final cardsRaw = jsonDecode(json['cards_json'] as String) as List;
    return Reading(
      id: json['id'],
      question: json['question'],
      spreadType: json['spread_type'],
      cards: cardsRaw.map((c) => TarotCard(
        num: c['num'],
        name: c['name'],
        sym: _symForNum(c['num']),
        keys: c['keys'],
        reversed: c['reversed'] ?? false,
      )).toList(),
      interpretation: json['interpretation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _symForNum(String num) {
    const map = {
      'O': '🌀', 'I': '⚡', 'II': '☽', 'III': '🌿', 'IV': '♦',
      'V': '✝', 'VI': '❤', 'VII': '☸', 'VIII': '∞', 'IX': '◈',
      'X': '⊕', 'XI': '⚖', 'XII': 'ψ', 'XIII': '⚰', 'XIV': '△',
      'XV': '☯', 'XVI': '⚑', 'XVII': '✦', 'XVIII': '🌙', 'XIX': '☀',
      'XX': '♚', 'XXI': '⊗',
    };
    return map[num] ?? '✦';
  }
}

class ReadingsService {
  final AuthService auth;
  ReadingsService(this.auth);

  Future<Reading> createReading({
    String? question,
    required String spreadType,
    required List<TarotCard> cards,
  }) async {
    final res = await http.post(
      Uri.parse('${AuthService.baseUrl}/readings/'),
      headers: auth.authHeaders,
      body: jsonEncode({
        'question': question,
        'spread_type': spreadType,
        'cards': cards.map((c) => c.toJson()).toList(),
      }),
    );
    if (res.statusCode == 201) {
      return Reading.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Ошибка создания расклада: ${res.statusCode}');
  }

  Future<List<Reading>> getHistory() async {
    final res = await http.get(
      Uri.parse('${AuthService.baseUrl}/readings/'),
      headers: auth.authHeaders,
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      return list.map((j) => Reading.fromJson(j)).toList();
    }
    throw Exception('Ошибка загрузки истории');
  }

  Future<void> deleteReading(int id) async {
    await http.delete(
      Uri.parse('${AuthService.baseUrl}/readings/$id'),
      headers: auth.authHeaders,
    );
  }
}
