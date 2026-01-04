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
  });
  
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
      bio: "I am the first complete chess program, running on an IBM 704 vacuum tube computer. I take 8 minutes to make a move. Be gentle.",
      style: 'Very passive. Makes logical but weak moves.',
      skillLevel: 0,
      depthLimit: 2,
      elo: 650,
    ),
    ChessPersona(
      name: 'Mephisto',
      year: '1984',
      vibe: 'The Retro Tabletop',
      bio: "In the 80s, you bought me at an electronics shop. I have a tiny LCD screen and a surprising bite.",
      style: 'Solid, tactical, and annoying to beat for casual players.',
      skillLevel: 7,
      depthLimit: 8,
      elo: 1600,
    ),
    ChessPersona(
      name: 'Deep Blue',
      year: '1997',
      vibe: 'The Legend',
      bio: "In 1997, I defeated Gary Kasparov. I am the monolith of brute force. I play concrete, precise chess.",
      style: 'Classical, materialistic, and extremely precise.',
      skillLevel: 16,
      elo: 2850,
    ),
    ChessPersona(
      name: 'AlphaZero',
      year: '2017',
      vibe: 'The Alien',
      bio: "I learned chess by playing myself for 4 hours. I sacrifice pieces for reasons you won't understand until it's too late.",
      style: 'Intuitive, artistic, and terrifying. Prefers mobility over material.',
      skillLevel: 20,
      elo: 3600,
    ),
    ChessPersona(
      name: 'Stockfish 16',
      year: '2023',
      vibe: 'The Terminator',
      bio: "I am the open-source king. I combine brute force with neural networks. I see 40 moves ahead. Resistance is futile.",
      style: 'Flawless. The perfect chess player.',
      skillLevel: 20,
      elo: 3800,
    ),
  ];
}
