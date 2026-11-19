/// A published FAQ row, reduced to what the matcher needs.
class FaqEntry {
  const FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
    this.keywords = const [],
  });

  final int id;
  final String question;
  final String answer;
  final List<String> keywords;
}

/// Picks the best FAQ for [message], or null when nothing is close enough.
///
/// Scoring mirrors the original in-app matcher:
/// - +10 when the message contains the whole question,
/// - +5 per keyword found in the message,
/// - +1 per shared word longer than three characters.
///
/// Words of three characters or fewer are ignored so "how do I" cannot match
/// every entry.
FaqEntry? matchFaq(String message, List<FaqEntry> faqs) {
  final normalized = message.toLowerCase();
  final userWords = normalized
      .split(RegExp(r'\s+'))
      .where((word) => word.length > 3)
      .toSet();

  FaqEntry? bestMatch;
  var bestScore = 0;

  for (final faq in faqs) {
    var score = 0;
    final question = faq.question.toLowerCase();

    if (normalized.contains(question)) score += 10;

    for (final keyword in faq.keywords) {
      if (normalized.contains(keyword.toLowerCase())) score += 5;
    }

    final questionWords = question
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .toSet();
    score += userWords.intersection(questionWords).length;

    if (score > bestScore) {
      bestScore = score;
      bestMatch = faq;
    }
  }

  return bestScore > 0 ? bestMatch : null;
}
