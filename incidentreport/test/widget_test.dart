import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidentreport/main.dart';

void main() {
  testWidgets('shows the Campus Connect incident feed', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(initialLoggedIn: true));

    expect(find.text('Campus Connect'), findsOneWidget);
    expect(find.text('My Incidents'), findsOneWidget);
    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('submits a report through all four steps', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(initialLoggedIn: true));

    await tester.tap(find.byKey(const ValueKey('nav-report')));
    await tester.pumpAndSettle();
    expect(find.text('Report an Incident'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-Broken Facility')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('incident-description')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('incident-description')),
      'Projector in room 8 is offline.',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('incident-building')),
      'Science Block',
    );
    await tester.enterText(
      find.byKey(const ValueKey('incident-room')),
      'Room 8',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Review your report'), findsOneWidget);
    expect(find.text('Science Block · Room 8'), findsOneWidget);

    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(find.text('Projector in room 8 is offline'), findsOneWidget);
    expect(find.text('Your incident has been submitted.'), findsOneWidget);
  });

  testWidgets('search filters the incident feed', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(initialLoggedIn: true));

    await tester.enterText(
      find.byKey(const ValueKey('incident-search')),
      'library',
    );
    await tester.pumpAndSettle();

    expect(find.text('No water in the library'), findsOneWidget);
    expect(find.text('Projector not working'), findsNothing);
  });

  testWidgets('wizard back button allows returning to previous step', (tester) async {
    await tester.pumpWidget(const CampusConnectApp(initialLoggedIn: true));

    await tester.tap(find.byKey(const ValueKey('nav-report')));
    await tester.pumpAndSettle();
    expect(find.text('Report an Incident'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-Broken Facility')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('incident-description')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('incident-description')),
      'Testing wizard back navigation.',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify back button is present on step 1
    expect(find.byKey(const ValueKey('wizard-back')), findsOneWidget);

    // Tap Back
    await tester.tap(find.byKey(const ValueKey('wizard-back')));
    await tester.pumpAndSettle();

    // Verify we returned to step 0
    expect(find.text('Incident Category'), findsOneWidget);
  });

  testWidgets('authentication login and sign out flow works', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CampusConnectApp(initialLoggedIn: false));

    // Verify auth screen is shown
    expect(find.text('Sign in to access your campus incident reports'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-demo-login')), findsOneWidget);

    // Ensure demo login button is visible and tap it
    await tester.ensureVisible(find.byKey(const ValueKey('auth-demo-login')));
    await tester.tap(find.byKey(const ValueKey('auth-demo-login')));
    await tester.pumpAndSettle();

    // Verify we reached the dashboard
    expect(find.text('Campus Connect'), findsOneWidget);

    // Navigate to profile tab (4th tab)
    await tester.tap(find.byKey(const ValueKey('nav-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Alex Student'), findsOneWidget);
    expect(find.text('alex.student@campus.edu'), findsOneWidget);

    // Sign out
    await tester.tap(find.byKey(const ValueKey('profile-logout')));
    await tester.pumpAndSettle();

    // Verify we are back to the auth screen
    expect(find.text('Sign in to access your campus incident reports'), findsOneWidget);
  });
}
