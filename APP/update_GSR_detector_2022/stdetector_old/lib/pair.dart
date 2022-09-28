class Pair<A,B> {
  final A older;
  final B newer;
  Pair({required this.older, required this.newer});

  @override
  String toString() => 'Pair[$older, $newer]';
}

