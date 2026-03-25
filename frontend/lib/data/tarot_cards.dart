import '../services/readings_service.dart';

const List<TarotCard> kAllCards = [
  TarotCard(num: 'O',    name: 'Шут',            sym: '🌀', keys: 'начало, свобода, прыжок в неизвестность'),
  TarotCard(num: 'I',    name: 'Маг',             sym: '⚡', keys: 'сила воли, мастерство, проявление'),
  TarotCard(num: 'II',   name: 'Жрица',           sym: '☽', keys: 'интуиция, тайна, внутренний голос'),
  TarotCard(num: 'III',  name: 'Императрица',     sym: '🌿', keys: 'изобилие, плодородие, природа'),
  TarotCard(num: 'IV',   name: 'Император',       sym: '♦', keys: 'стабильность, власть, структура'),
  TarotCard(num: 'V',    name: 'Иерофант',        sym: '✝', keys: 'традиция, наставник, духовность'),
  TarotCard(num: 'VI',   name: 'Влюблённые',      sym: '❤', keys: 'выбор, союз, ценности'),
  TarotCard(num: 'VII',  name: 'Колесница',       sym: '☸', keys: 'победа, движение, контроль'),
  TarotCard(num: 'VIII', name: 'Сила',            sym: '∞', keys: 'мужество, терпение, внутренняя сила'),
  TarotCard(num: 'IX',   name: 'Отшельник',       sym: '◈', keys: 'уединение, поиск, мудрость'),
  TarotCard(num: 'X',    name: 'Колесо Судьбы',   sym: '⊕', keys: 'судьба, цикл, поворот событий'),
  TarotCard(num: 'XI',   name: 'Справедливость',  sym: '⚖', keys: 'баланс, истина, карма'),
  TarotCard(num: 'XII',  name: 'Повешенный',      sym: 'ψ', keys: 'пауза, жертва, иная перспектива'),
  TarotCard(num: 'XIII', name: 'Смерть',          sym: '⚰', keys: 'трансформация, конец, обновление'),
  TarotCard(num: 'XIV',  name: 'Умеренность',     sym: '△', keys: 'баланс, терпение, гармония'),
  TarotCard(num: 'XV',   name: 'Дьявол',          sym: '☯', keys: 'искушение, привязанность, иллюзия'),
  TarotCard(num: 'XVI',  name: 'Башня',           sym: '⚑', keys: 'разрушение, откровение, перемены'),
  TarotCard(num: 'XVII', name: 'Звезда',          sym: '✦', keys: 'надежда, вдохновение, исцеление'),
  TarotCard(num: 'XVIII',name: 'Луна',            sym: '🌙', keys: 'иллюзия, страх, подсознание'),
  TarotCard(num: 'XIX',  name: 'Солнце',          sym: '☀', keys: 'радость, успех, ясность'),
  TarotCard(num: 'XX',   name: 'Суд',             sym: '♚', keys: 'пробуждение, призыв, второй шанс'),
  TarotCard(num: 'XXI',  name: 'Мир',             sym: '⊗', keys: 'завершение, интеграция, путешествие'),
];

const Map<String, List<String>> kSpreadLabels = {
  '1': ['Сейчас'],
  '3': ['Прошлое', 'Настоящее', 'Будущее'],
  '5': ['Основа', 'Препятствие', 'Прошлое', 'Будущее', 'Итог'],
};
