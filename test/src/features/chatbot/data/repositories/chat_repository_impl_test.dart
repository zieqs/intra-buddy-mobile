import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/data/repositories/chat_repository_impl.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/domain/match_faq.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = ChatRepositoryImpl(dataSource);
  });

  group('findAnswer', () {
    test('wraps a matched FAQ as an assistant message', () async {
      when(() => dataSource.findAnswer(any())).thenAnswer(
        (_) async => const FaqEntry(
          id: 7,
          question: 'How do I submit my logbook?',
          answer: 'Mark the week in the app after the portal.',
        ),
      );

      final result = await repository.findAnswer('logbook');

      result.fold((failure) => fail(failure.message), (message) {
        expect(message, isNotNull);
        expect(message!.role, 'assistant');
        expect(message.content, 'Mark the week in the app after the portal.');
        expect(message.matchedFaqId, 7);
      });
      verify(() => dataSource.findAnswer('logbook')).called(1);
    });

    test('returns null when the matcher finds nothing', () async {
      when(() => dataSource.findAnswer(any())).thenAnswer((_) async => null);

      final result = await repository.findAnswer('wifi password');

      result.fold(
        (failure) => fail(failure.message),
        (message) => expect(message, isNull),
      );
    });

    test('reports a failure when the lookup throws', () async {
      when(() => dataSource.findAnswer(any())).thenThrow(Exception('offline'));

      final result = await repository.findAnswer('logbook');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('offline')),
        (_) => fail('expected a failure'),
      );
    });
  });
}
