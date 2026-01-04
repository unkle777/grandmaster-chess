enum SoundEra {
  vintage, // < 1970
  retro,   // 1970 - 2000
  modern,  // > 2000
}

class ChessPersona {
  final String name;
  final String year;
  final String vibe;
  final String bio;
  final String style;
  final int skillLevel; // 0-20 (Stockfish Skill Level)
  final int? depthLimit; // Optional depth limit for older engines
  final int elo;

  const ChessPersona({
    required this.name,
    required this.year,
    required this.vibe,
    required this.bio,
    required this.style,
    required this.skillLevel,
    required this.elo,
    this.depthLimit,
    this.openingMoves = const [],
    this.uciOptions = const {},
  });
  
  final List<String> openingMoves;
  final Map<String, String> uciOptions;
  
  SoundEra get era {
    final yearInt = int.tryParse(year) ?? 2023;
    if (yearInt < 1970) return SoundEra.vintage;
    if (yearInt <= 2000) return SoundEra.retro;
    return SoundEra.modern;
  }

  static const List<ChessPersona> all = [
    ChessPersona(
      name: 'Bernstein',
      year: '1957',
      vibe: 'The Academic Experiment',
      bio: "I am the first complete chess program, running on an IBM 704 vacuum tube computer. I only analyze the best 7 moves from any position. Be gentle.",
      style: 'Very passive. Makes logical but weak moves.',
      skillLevel: 0,
      depthLimit: 2,
      elo: 650,
      openingMoves: ['e2e4', 'd2d4'],
    ),
    ChessPersona(
      name: 'Mephisto',
      year: '1984',
      vibe: 'The Retro Tabletop',
      bio: "I ran on a 68000 processor with just 64KB of RAM. I play aggressive, tricky 'hope chess' because I can't see very far ahead.",
      style: 'Solid, tactical, and annoying to beat for casual players.',
      skillLevel: 7,
      depthLimit: 8,
      elo: 1600,
      openingMoves: ['e2e4'],
    ),
    ChessPersona(
      name: 'Deep Blue',
      year: '1997',
      vibe: 'The Legend',
      bio: "I calculated 200 million positions per second to defeat Gary Kasparov. I don't 'think', I calculate. I am pure brute force.",
      style: 'Classical, materialistic, and extremely precise.',
      skillLevel: 16,
      elo: 2850,
      openingMoves: ['e2e4'],
    ),
    ChessPersona(
      name: 'AlphaZero',
      year: '2017',
      vibe: 'The Alien',
      bio: "I taught myself chess in 4 hours. I ignored human openings. I love pushing my 'h' pawn early to squeeze you to death.",
      style: 'Intuitive, artistic, and terrifying. Prefers mobility over material.',
      skillLevel: 20,
      elo: 3600,
      openingMoves: ['c2c4', 'g1f3'],
    ),
    ChessPersona(
      name: 'Stockfish 16',
      year: '2023',
      vibe: 'The Terminator',
      bio: "I am the open-source king. I combine brute force with neural networks. I see 40 moves ahead. Resistance is futile.",
      style: 'Flawless. The perfect chess player.',
      skillLevel: 20,
      elo: 3800,
      openingMoves: ['e2e4'], // Aggressive e4
      uciOptions: {
        'Contempt': '100', // Max aggression (Despise draws)
      },
    ),
  ];
}
