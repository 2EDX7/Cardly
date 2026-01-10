import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cardly/logic/cubits/card/card_cubit.dart';
import 'package:cardly/logic/cubits/card/card_state.dart';
import 'package:cardly/data/models/card_info.dart';
import 'package:cardly/data/repositories/card_repository.dart';

// Mock repository for testing
class MockCardRepository implements CardRepository {
  final List<CardInfo> _cards = [];

  @override
  Future<List<CardInfo>> getAllCards({required String userId}) async {
    return _cards;
  }

  @override
  Future<CardInfo?> getCardById(int id, {required String userId}) async {
    return _cards.firstWhere((card) => card.id == id);
  }

  @override
  Future<CardInfo?> getCardByIdGlobal(int id) async {
    return _cards.firstWhere((card) => card.id == id);
  }

  @override
  Future<void> addCard(CardInfo card, {required String userId}) async {
    _cards.add(card);
  }

  @override
  Future<void> updateCard(CardInfo card, {required String userId}) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
    }
  }

  @override
  Future<void> deleteCard(int id, {required String userId}) async {
    _cards.removeWhere((card) => card.id == id);
  }

  @override
  Future<List<CardInfo>> searchCards(String query,
      {required String userId}) async {
    return _cards
        .where((card) =>
            card.name.toLowerCase().contains(query.toLowerCase()) ||
            card.organization.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<CardInfo>> getCardsByCategory(String category,
      {required String userId}) async {
    return _cards.where((card) => card.category == category).toList();
  }
}

void main() {
  group('CardCubit Tests', () {
    late CardCubit cardCubit;
    late MockCardRepository mockRepository;

    setUp(() {
      mockRepository = MockCardRepository();
      cardCubit = CardCubit(
        repository: mockRepository,
        initialUserId: 'test-user',
      );
    });

    tearDown(() {
      cardCubit.close();
    });

    test('initial state is CardInitial', () {
      final cubit = CardCubit(
        repository: mockRepository,
        initialUserId: null,
      );
      expect(cubit.state, isA<CardInitial>());
      cubit.close();
    });

    blocTest<CardCubit, CardState>(
      'loadCards emits CardLoading then CardLoaded',
      build: () => cardCubit,
      act: (cubit) => cubit.loadCards(),
      expect: () => [
        isA<CardLoading>(),
        isA<CardLoaded>(),
      ],
    );

    blocTest<CardCubit, CardState>(
      'addCard adds card and reloads',
      build: () {
        final cubit = CardCubit(
          repository: mockRepository,
          initialUserId: 'test-user',
        );
        return cubit;
      },
      act: (cubit) async {
        final card = CardInfo(
          name: 'Test Card',
          email: 'test@example.com',
          phone: '+1234567890',
          organization: 'Test Org',
          jobTitle: 'Tester',
          location: 'Test City',
          about: 'Test about',
          website: 'https://test.com',
        );
        await cubit.addCard(card);
      },
      skip: 1, // Skip initial CardLoaded state from cubit initialization
      expect: () => [
        isA<CardAdded>(),
        isA<CardLoading>(),
        isA<CardLoaded>(),
      ],
    );

    test('setUser updates userId', () {
      cardCubit.setUser('new-user-id');
      expect(cardCubit.state, isA<CardLoading>());
    });
  });
}
