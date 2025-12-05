import 'package:equatable/equatable.dart';
import '../../../data/models/card_info.dart';

/// Base state class for card management
abstract class CardState extends Equatable {
  const CardState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class CardInitial extends CardState {}

/// Loading state when fetching or processing cards
class CardLoading extends CardState {}

/// Success state with loaded cards
class CardLoaded extends CardState {
  final List<CardInfo> cards;
  final String searchQuery;
  final String? selectedCategory;

  const CardLoaded({
    required this.cards,
    this.searchQuery = '',
    this.selectedCategory,
  });

  /// Get filtered cards based on search and category
  List<CardInfo> get filteredCards {
    var result = cards;
    
    // Apply category filter
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      result = result.where((card) => card.category == selectedCategory).toList();
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((card) {
        return card.name.toLowerCase().contains(query) ||
               card.organization.toLowerCase().contains(query) ||
               card.jobTitle.toLowerCase().contains(query);
      }).toList();
    }
    
    return result;
  }

  /// Get cards grouped by category
  Map<String, List<CardInfo>> get cardsByCategory {
    final grouped = <String, List<CardInfo>>{};
    for (var card in filteredCards) {
      final category = card.category ?? 'Uncategorized';
      grouped.putIfAbsent(category, () => []).add(card);
    }
    return grouped;
  }

  /// Get all unique categories
  List<String> get categories {
    final categorySet = <String>{};
    for (var card in cards) {
      if (card.category != null && card.category!.isNotEmpty) {
        categorySet.add(card.category!);
      }
    }
    return categorySet.toList()..sort();
  }

  @override
  List<Object?> get props => [cards, searchQuery, selectedCategory];

  CardLoaded copyWith({
    List<CardInfo>? cards,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return CardLoaded(
      cards: cards ?? this.cards,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// Error state when something goes wrong
class CardError extends CardState {
  final String message;

  const CardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State after successfully adding a card
class CardAdded extends CardState {
  final CardInfo card;

  const CardAdded(this.card);

  @override
  List<Object?> get props => [card];
}

/// State after successfully updating a card
class CardUpdated extends CardState {
  final CardInfo card;

  const CardUpdated(this.card);

  @override
  List<Object?> get props => [card];
}

/// State after successfully deleting a card
class CardDeleted extends CardState {
  final String cardId;

  const CardDeleted(this.cardId);

  @override
  List<Object?> get props => [cardId];
}
