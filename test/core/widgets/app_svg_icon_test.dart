import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/constants/app_icons.dart';
import 'package:transly_ai/core/widgets/app_icon_source.dart';
import 'package:transly_ai/core/widgets/app_svg_icon.dart';
import 'package:transly_ai/core/widgets/transly_mark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final asset in AppIcons.all) {
    test('$asset is bundled', () async {
      final svg = await rootBundle.loadString(asset);

      expect(svg, contains('<svg'));
    });
  }

  test('lists every icon once', () {
    expect(AppIcons.all.toSet(), hasLength(AppIcons.all.length));
  });

  group('AppSvgIcon', () {
    testWidgets('paints the icon at the given size in the given colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Center(
          child: AppSvgIcon(AppIcons.trash, size: 18, color: Colors.red),
        ),
      );

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(tester.getSize(find.byType(SvgPicture)), const Size(18, 18));
      expect(
        picture.colorFilter,
        const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      );
    });

    testWidgets('does not mirror unless asked to', (tester) async {
      await tester.pumpWidget(
        const Center(
          child: AppSvgIcon(AppIcons.trash, size: 18, color: Colors.red),
        ),
      );

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(picture.matchTextDirection, isFalse);
    });

    testWidgets('mirrors a directional icon in RTL', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: AppSvgIcon(
              AppIcons.back,
              size: 18,
              color: Colors.red,
              matchTextDirection: true,
            ),
          ),
        ),
      );

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(picture.matchTextDirection, isTrue);
    });
  });

  group('AppIconView', () {
    Future<void> pumpView(WidgetTester tester, AppIconSource source) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppIconView(source, size: 17, color: Colors.red),
          ),
        ),
      );
    }

    testWidgets('draws a design icon as SVG', (tester) async {
      await pumpView(tester, const SvgIconSource(AppIcons.error));

      final icon = tester.widget<AppSvgIcon>(find.byType(AppSvgIcon));
      expect(icon.asset, AppIcons.error);
      expect(icon.size, 17);
    });

    testWidgets('draws a Material icon as an Icon', (tester) async {
      await pumpView(
        tester,
        const MaterialIconSource(Icons.info_outline_rounded),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.info_outline_rounded);
      expect(icon.color, Colors.red);
    });
  });

  group('TranslyMark', () {
    testWidgets('draws the white mark in its own colours', (tester) async {
      await tester.pumpWidget(const Center(child: TranslyMark.white(size: 40)));

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(picture.colorFilter, isNull);
      expect(tester.getSize(find.byType(SvgPicture)), const Size(40, 40));
    });

    testWidgets('draws the coral mark', (tester) async {
      await tester.pumpWidget(const Center(child: TranslyMark.coral(size: 40)));

      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });
}
