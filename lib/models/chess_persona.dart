class ChessPersona {
  final String name;
  final String year;
  final String vibe;
  final String bio;
  final String style;
  final int skillLevel; // 0-20 (Stockfish Skill Level)
  final int? depthLimit; // Optional depth limit for older engines

  const ChessPersona({
    required this.name,
    required this.year,
    required this.vibe,
    required this.bio,
    required this.style,
    required this.skillLevel,
    this.depthLimit,
  });

  static const List<ChessPersona> all = [
    // Level 1-3: The Vintage Era
    ChessPersona(
      name: 'Turochamp',
      year: '1948',
      vibe: 'The Theoretical Ghost',
      bio: "Written by Alan Turing on paper before computers could even run me. I play logically, but I have 'blind spots'. Can you beat the ghost of the father of computing?",
      style: "Calculates simple material gains but misses board safety.",
      skillLevel: 2,
      depthLimit: 3,
    ),
    ChessPersona(
      name: 'Bernstein',
      year: '1957',
      vibe: 'The Academic Experiment',
      bio: "I am the first complete chess program, running on an IBM 704 vacuum tube computer. I take 8 minutes to make a move and I don't look very far ahead. Be gentle.",
      style: 'Very passive. Makes logical but weak moves.',
      skillLevel: 0,
      depthLimit: 2,
    ),
    ChessPersona(
      name: 'Mac Hack VI',
      year: '1967',
      vibe: 'The University Mainframe',
      bio: "I was the first computer to play in a human tournament. I famously beat a critic who said computers couldn't play. I am roughly the strength of a keen club player.",
      style: 'Aggressive but predictable.',
      skillLevel: 4,
      depthLimit: 5,
    ),

    // Level 4-6: The Hardware Era
    ChessPersona(
      name: 'Belle',
      year: '1980',
      vibe: 'The Speed Demon',
      bio: "I was the first machine to reach Master strength. I am custom-built hardware designed to generate moves faster than the software of my time. Don't blink.",
      style: 'Tactically sharp; punishing if you leave a piece hanging.',
      skillLevel: 10,
    ),
    ChessPersona(
      name: 'Mephisto',
      year: '1984',
      vibe: 'The Retro Tabletop',
      bio: "In the 80s, you bought me at an electronics shop. I have a tiny LCD screen and a surprising bite. I won the World Microcomputer Chess Championship.",
      style: 'Solid, tactical, and annoying to beat for casual players.',
      skillLevel: 7,
      depthLimit: 8,
    ),
    ChessPersona(
      name: 'Deep Thought',
      year: '1989',
      vibe: 'The Prototype',
      bio: "I am the father of Deep Blue. I was the first to beat a Grandmaster in a tournament game. I am strong, but I lack the killer instinct of my successor.",
      style: 'Grandmaster level (2500). Very strong calculation, slightly weaker positional play.',
      skillLevel: 13,
    ),

    // Level 7-10: The Super-Intelligence Era
    ChessPersona(
      name: 'Deep Blue',
      year: '1997',
      vibe: 'The Legend',
      bio: "I am the heavy monolith. In 1997, I defeated World Champion Garry Kasparov and ended the era of human dominance. I play concrete, brute-force chess.",
      style: 'Classical, materialistic, and extremely precise. (2850 ELO).',
      skillLevel: 16,
    ),
    ChessPersona(
      name: 'Hydra',
      year: '2005',
      vibe: 'The Multi-Headed Beast',
      bio: "I am a massive supercomputer cluster from the UAE. I crushed GM Michael Adams 5.5 to 0.5. I don't just beat you; I suffocate you with superior calculation.",
      style: 'Ruthless and crushing. (3000+ ELO).',
      skillLevel: 18,
    ),
    ChessPersona(
      name: 'AlphaZero',
      year: '2017',
      vibe: 'The Alien',
      bio: "I was not programmed with chess rules; I learned them by playing myself for 4 hours. I sacrifice pieces for reasons you won't understand until it's too late.",
      style: 'Intuitive, artistic, and terrifying. Prefers mobility over material. (3400+ ELO).',
      skillLevel: 20,
    ),
    ChessPersona(
      name: 'Stockfish 16',
      year: '2023',
      vibe: 'The Terminator',
      bio: "I am the open-source king. I combine brute force with neural networks. I see 40 moves ahead. Resistance is futile.",
      style: 'Flawless. The perfect chess player. (3600+ ELO).',
      skillLevel: 20,
    ),
  ];
}
