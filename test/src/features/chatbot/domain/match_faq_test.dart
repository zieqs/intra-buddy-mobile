import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/chatbot/domain/match_faq.dart';

const _logbook = FaqEntry(
  id: 1,
  question: 'How do I submit my logbook?',
  answer: 'Mark the week after submitting it through the INTRA portal.',
  keywords: ['logbook', 'submit', 'weekly'],
);

const _deadline = FaqEntry(
  id: 2,
  question: 'When is the internship deadline?',
  answer: 'The placement ends with the semester.',
  keywords: ['deadline', 'last day'],
);

void main() {
  group('matchFaq', () {
    test('returns null when there are no FAQs', () {
      expect(matchFaq('How do I submit my logbook?', const []), isNull);
    });

    test('prefers the FAQ whose question appears verbatim', () {
      final match = matchFaq(
        'quick one - how do I submit my logbook? thanks',
        const [_deadline, _logbook],
      );

      expect(match, same(_logbook));
    });

    test('matches on a keyword when the wording differs', () {
      final match = matchFaq('I already used the weekly form', const [
        _deadline,
        _logbook,
      ]);

      expect(match, same(_logbook));
    });

    test('matches on shared words longer than three characters', () {
      final match = matchFaq('internship deadline?', const [
        _logbook,
        _deadline,
      ]);

      expect(match, same(_deadline));
    });

    test('is case insensitive', () {
      final match = matchFaq('HOW DO I SUBMIT MY LOGBOOK', const [_logbook]);

      expect(match, same(_logbook));
    });

    test('ignores short words so "how do I" matches nothing', () {
      expect(matchFaq('how do I', const [_logbook, _deadline]), isNull);
    });

    test('picks the strongest match when several could apply', () {
      final match = matchFaq(
        'when is the internship deadline for the logbook?',
        const [_logbook, _deadline],
      );

      expect(match, isNotNull);
      // "deadline" + "internship" outranks the single "logbook" keyword.
      expect(match, same(_deadline));
    });

    test('returns null when nothing overlaps', () {
      expect(
        matchFaq('what is the wifi password', const [_logbook, _deadline]),
        isNull,
      );
    });
  });
}
