class CardFilterUtils {
  /// Filter cards by search query (name or organization)
  static List<Map<String, dynamic>> filterCards(
    List<Map<String, dynamic>> cards,
    String query,
  ) {
    if (query.isEmpty) {
      return cards;
    }

    return cards.where((card) {
      final name = card['name'].toString().toLowerCase();
      final organization = card['organization'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || organization.contains(searchQuery);
    }).toList();
  }

  /// Group cards by category
  static Map<String, List<Map<String, dynamic>>> groupByCategory(
    List<Map<String, dynamic>> cards,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var card in cards) {
      final category = card['category'] as String;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(card);
    }

    return grouped;
  }
}
