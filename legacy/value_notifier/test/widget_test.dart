import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value_notifier/main.dart';

void main() {
  testWidgets('Our first frame shows the home', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ValueNotifierApp()));

    // The initial location for our router is `/`,
    // but the redirect is first triggered
    expect(find.text("Login Page"), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);

    // Tap the login button
    await tester.tap(find.bySemanticsLabel('Login'));
    await tester.pumpAndSettle(const Duration(milliseconds: 750));

    // Verify that we're at the home page
    expect(find.text("Login Page"), findsNothing);
    expect(find.text('Home Page'), findsOneWidget);

    // Tap the logout button
    await tester.tap(find.bySemanticsLabel('Logout'));
    await tester.pumpAndSettle(const Duration(milliseconds: 750));

    // // Verify that we're back to the login page
    expect(find.text("Login Page"), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
  });
}
