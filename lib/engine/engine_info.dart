class EngineInfo {
  final double? evaluation; // Centipawns converted to pawns (e.g. 150cp -> 1.5)
  final int? mateIn; // Moves to mate (positive = white winning, negative = black winning)
  final List<String>? pv; // Principal Variation (best line)
  final int? depth;
  final int? nodes;
  final int? nps;

  EngineInfo({
    this.evaluation,
    this.mateIn,
    this.pv,
    this.depth,
    this.nodes,
    this.nps,
  });

  @override
  String toString() {
    return 'EngineInfo(eval: $evaluation, mate: $mateIn, depth: $depth, nodes: $nodes, nps: $nps, pv: ${pv?.first}...)';
  }
}
