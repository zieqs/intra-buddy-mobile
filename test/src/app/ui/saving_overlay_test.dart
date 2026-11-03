import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/saving_overlay.dart';

void main() {
  testWidgets('shows a labelled wheel until it is dismissed', (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const Scaffold(body: Text('Page'));
          },
        ),
      ),
    );

    final entry = showSavingOverlay(pageContext, label: 'Saving…');
    await tester.pump();

    expect(find.text('Saving…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    entry.remove();
    await tester.pump();

    expect(find.text('Saving…'), findsNothing);
  });
}
