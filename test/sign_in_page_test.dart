import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamapp/app/top_level_providers.dart';
import 'package:teamapp/app/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:teamapp/routing/app_router.dart';

import 'mocks.dart';

void main() {
  group('sign-in page', () {
    MockFirebaseAuth mockFirebaseAuth;
    MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpSignInPage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider
                .overrideWithProvider(Provider((ref) => mockFirebaseAuth)),
          ],
          child: Consumer(builder: (context, watch, __) {
            final firebaseAuth = watch(firebaseAuthProvider);
            return MaterialApp(
              home: SignInPage(),
              onGenerateRoute: (settings) =>
                  AppRouter.onGenerateRoute(settings, firebaseAuth),
              navigatorObservers: [mockNavigatorObserver],
            );
          }),
        ),
      );
      // didPush is called once when the widget is first built
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    }

    testWidgets('email & password navigation', (tester) async {
      await pumpSignInPage(tester);

      final emailPasswordButton =
          find.byKey(SignInPageContents.emailPasswordButtonKey);
      expect(emailPasswordButton, findsOneWidget);

      await tester.tap(emailPasswordButton);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });
  });
}
