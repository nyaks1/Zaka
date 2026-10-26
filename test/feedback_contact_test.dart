import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaka/features/support/contact.dart';
import 'package:zaka/features/support/feedback_contact_tile.dart';

void main() {
  testWidgets('the feedback row shows the contact and copies it', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedbackContactCard(showFormButton: false),
        ),
      ),
    );

    expect(find.text('Send feedback or a complaint'), findsOneWidget);
    expect(find.text(feedbackContactLabel), findsOneWidget);
    expect(
      find.text('Please don’t send bank details or statements.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Send feedback or a complaint'));
    await tester.pump();

    final copy = calls.where((call) => call.method == 'Clipboard.setData');
    expect(copy, isNotEmpty);
    expect(
      (copy.last.arguments as Map<Object?, Object?>)['text'],
      feedbackContact,
    );
    expect(find.text('Contact copied'), findsOneWidget);
  });
}
