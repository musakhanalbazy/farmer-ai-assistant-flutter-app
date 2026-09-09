import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:visa_chatbot/ui/business_profile_setup/business_profile_viewmodel.dart';
import 'package:visa_chatbot/ui/business_profile_setup/business_profile_form_view.dart';

void main() {
  group('BusinessProfileFormView Widget Tests', () {
    /// Helper: pumps the view inside a minimal app shell with the ViewModel provided.
    Future<BusinessProfileViewModel> pumpView(WidgetTester tester) async {
      final vm = BusinessProfileViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<BusinessProfileViewModel>.value(
          value: vm,
          child: const MaterialApp(
            // Stub routes so Navigator.pushReplacementNamed doesn't crash.
            onGenerateRoute: _onGenerateRoute,
            home: BusinessProfileFormView(),
          ),
        ),
      );

      return vm;
    }

    testWidgets('renders all input fields and the Save Profile button',
        (WidgetTester tester) async {
      await pumpView(tester);

      expect(find.text('Business Profile Setup'), findsOneWidget);
      expect(find.text('Organization Name'), findsOneWidget);
      expect(find.text('Registration Id'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Operating Countries'), findsOneWidget);
      expect(find.text('Business Email'), findsOneWidget);
      expect(find.text('Business Phone Number'), findsOneWidget);
      expect(find.text('Business Website'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('typing in Organization Name updates the ViewModel',
        (WidgetTester tester) async {
      final vm = await pumpView(tester);

      // Find the first TextFormField (Organization Name) and enter text.
      final orgField = find.byType(TextFormField).first;
      await tester.enterText(orgField, 'Acme Corp');
      await tester.pump();

      expect(vm.profile.organizationName, 'Acme Corp');
    });

    testWidgets('Save Profile button is present and tappable',
        (WidgetTester tester) async {
      await pumpView(tester);

      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Profile');
      expect(saveBtn, findsOneWidget);

      // Tap should navigate — no crash expected.
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();
    });
  });
}

/// Minimal route generator so pushReplacementNamed('/profile-permission') doesn't throw.
Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => Scaffold(
      body: Center(child: Text(settings.name ?? 'Unknown route')),
    ),
  );
}
