import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/user_avatar.dart';
import 'package:transly_ai/core/widgets/user_avatar_hero.dart';
import 'package:transly_ai/features/home/presentation/widgets/translate_header.dart';
import 'package:transly_ai/features/profile/presentation/widgets/profile_identity.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  final flyingAvatar = find.descendant(
    of: find.byType(FittedBox),
    matching: find.byType(UserAvatar),
  );

  Future<void> pumpToMidFlight(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
  }

  Widget avatarScreen(double size, double ringWidth) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: UserAvatarHero(
          child: UserAvatar(name: 'ahmed', size: size, ringWidth: ringWidth),
        ),
      ),
    );
  }

  Future<void> pumpSmallAvatar(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        home: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => avatarScreen(84, 4)),
            ),
            child: avatarScreen(44, 2),
          ),
        ),
      ),
    );
  }

  testWidgets('grows the avatar in flight to the next route', (tester) async {
    await pumpSmallAvatar(tester);

    await tester.tap(find.byType(UserAvatar));
    await pumpToMidFlight(tester);

    final shuttle = tester.getSize(find.byType(FittedBox));
    expect(shuttle.width, inExclusiveRange(44, 84));
    expect(shuttle.height, inExclusiveRange(44, 84));
  });

  testWidgets('lands at the size of the next route', (tester) async {
    await pumpSmallAvatar(tester);

    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();

    expect(find.byType(FittedBox), findsNothing);
    expect(tester.getSize(find.byType(UserAvatar)), const Size.square(84));
  });

  group('between the shell header and the profile', () {
    late GoRouter router;

    Future<void> pumpHeader(WidgetTester tester) {
      final user = UserEntity(
        id: '1',
        email: 'ahmed@example.com',
        username: 'ahmed',
        createdAt: DateTime(2026),
      );
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TranslateHeader(
                kicker: 'Translate',
                userName: user.username,
                isPro: false,
                onProfileTap: () => context.push('/profile'),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, _) => Scaffold(
              body: Center(child: ProfileIdentity(user: user)),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      return tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(extensions: const [AppPalette.light]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('stays a circle while flying to the profile', (tester) async {
      await pumpHeader(tester);

      await tester.tap(find.byType(UserAvatar));
      await pumpToMidFlight(tester);

      final avatar = tester.getRect(flyingAvatar);
      expect(avatar.width, inExclusiveRange(44, 84));
      expect(avatar.width, moreOrLessEquals(avatar.height));
    });

    testWidgets('scales the letter with the circle in flight', (tester) async {
      await pumpHeader(tester);

      await tester.tap(find.byType(UserAvatar));
      await pumpToMidFlight(tester);

      final letter = find.descendant(
        of: flyingAvatar,
        matching: find.text('A'),
      );
      expect(
        tester.getRect(letter).height / tester.getRect(flyingAvatar).height,
        closeTo(0.4, 0.01),
      );
    });

    Future<void> pumpProfile(WidgetTester tester) async {
      await pumpHeader(tester);
      await tester.tap(find.byType(UserAvatar));
      await tester.pumpAndSettle();
    }

    testWidgets('flies back to the header on pop', (tester) async {
      await pumpProfile(tester);

      router.pop();
      await pumpToMidFlight(tester);

      expect(tester.getRect(flyingAvatar).width, inExclusiveRange(44, 84));
    });

    testWidgets('lands in the header on pop', (tester) async {
      await pumpProfile(tester);

      router.pop();
      await tester.pumpAndSettle();

      expect(flyingAvatar, findsNothing);
      expect(tester.getSize(find.byType(UserAvatar)), const Size.square(44));
    });

    testWidgets(
      'stays out of a committed predictive back',
      (tester) async {
        Future<void> sendBackGesture(String method, [double? progress]) async {
          await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            SystemChannels.backGesture.name,
            const StandardMethodCodec().encodeMethodCall(
              MethodCall(method, {
                'touchOffset': [5.0, 300.0],
                'progress': ?progress,
                'swipeEdge': 0,
              }),
            ),
            (_) {},
          );
          await tester.pump();
        }

        await pumpProfile(tester);

        await sendBackGesture('startBackGesture', 0);
        await sendBackGesture('updateBackGestureProgress', 0.8);
        await sendBackGesture('commitBackGesture');

        expect(flyingAvatar, findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'follows an iOS back swipe',
      (tester) async {
        await pumpProfile(tester);

        final swipe = await tester.startGesture(const Offset(5, 300));
        await swipe.moveBy(const Offset(20, 0));
        await tester.pump();
        await swipe.moveBy(const Offset(150, 0));
        await tester.pump();

        expect(flyingAvatar, findsOneWidget);

        await swipe.up();
        await tester.pumpAndSettle();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });
}
