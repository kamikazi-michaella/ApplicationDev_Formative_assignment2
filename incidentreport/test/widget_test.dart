import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidentreport/main.dart';

void main() {
  testWidgets('shows the CampusHub incident feed', (tester) async {
    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: true));

    expect(find.text('CampusHub'), findsOneWidget);
    expect(find.text('My Incidents'), findsOneWidget);
    expect(find.text('Projector not working'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('submits a report through all four steps', (tester) async {
    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: true));

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
    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: true));

    await tester.enterText(
      find.byKey(const ValueKey('incident-search')),
      'library',
    );
    await tester.pumpAndSettle();

    expect(find.text('No water in the library'), findsOneWidget);
    expect(find.text('Projector not working'), findsNothing);
  });

  testWidgets('wizard back button allows returning to previous step', (tester) async {
    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: true));

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

    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: false));

    // Verify auth screen is shown
    expect(find.text('Sign in to access your campus incident reports'), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-email')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('auth-email')), 'student@campus.edu');
    await tester.enterText(find.byKey(const ValueKey('auth-password')), 'password123');
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    // Verify we reached the dashboard
    expect(find.text('CampusHub'), findsOneWidget);

    // Navigate to profile tab (4th tab)
    await tester.tap(find.byKey(const ValueKey('nav-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Campus community member'), findsOneWidget);
    expect(find.text('student@campus.edu'), findsOneWidget);

    // Sign out
    await tester.tap(find.byKey(const ValueKey('profile-logout')));
    await tester.pumpAndSettle();

    // Verify we are back to the auth screen
    expect(find.text('Sign in to access your campus incident reports'), findsOneWidget);
  });

  testWidgets('admin login with admin/admin credentials grants delete privileges', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: false));

    await tester.enterText(find.byKey(const ValueKey('auth-email')), 'admin');
    await tester.enterText(find.byKey(const ValueKey('auth-password')), 'admin');
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    // Verify logged in as admin
    expect(find.text('CampusHub'), findsOneWidget);
    expect(find.text('Projector not working'), findsOneWidget);

    // Delete incident CC-1048
    final deleteKey = find.byKey(const ValueKey('delete-incident-CC-1048'));
    expect(deleteKey, findsOneWidget);
    await tester.tap(deleteKey);
    await tester.pumpAndSettle();

    // Verify deleted
    expect(find.text('Projector not working'), findsNothing);
  });

  testWidgets('admin can change status of an incident', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CampusHubApp(initialLoggedIn: false));

    await tester.enterText(find.byKey(const ValueKey('auth-email')), 'admin');
    await tester.enterText(find.byKey(const ValueKey('auth-password')), 'admin');
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    // Open change status popup for CC-1048
    final statusMenuKey = find.byKey(const ValueKey('change-status-CC-1048'));
    expect(statusMenuKey, findsOneWidget);
    await tester.tap(statusMenuKey);
    await tester.pumpAndSettle();

    // Tap 'Resolved'
    await tester.tap(find.text('Resolved').last);
    await tester.pumpAndSettle();

    // Verify status updated snackbar / text
    expect(find.text('Incident CC-1048 status updated to "Resolved" by Admin.'), findsOneWidget);
  });
}
