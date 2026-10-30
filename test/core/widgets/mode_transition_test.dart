import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_motion.dart';
import 'package:transly_ai/core/widgets/mode_transition.dart';

void main() {
  const a = Key('a');
  const b = Key('b');
  const c = Key('c');

  Widget stack(
    int index, {
    TextDirection direction = TextDirection.ltr,
    List<Widget>? children,
  }) {
    return Directionality(
      textDirection: direction,
      child: Center(
        child: SizedBox.square(
          dimension: 400,
          child: ModeTransitionStack(
            index: index,
            children:
                children ??
                const [
                  SizedBox.expand(key: a),
                  SizedBox.expand(key: b),
                  SizedBox.expand(key: c),
                ],
          ),
        ),
      ),
    );
  }

  /// How far [key] sits from its resting place.
  double shiftOf(WidgetTester tester, Key key) =>
      tester.getTopLeft(find.byKey(key)).dx -
      tester.getTopLeft(find.byType(ModeTransitionStack)).dx;

  double opacityOf(WidgetTester tester, Key key) => tester
      .widget<Opacity>(
        find
            .ancestor(of: find.byKey(key), matching: find.byType(Opacity))
            .first,
      )
      .opacity;

  bool isShown(WidgetTester tester, Key key) => tester
      .widget<Visibility>(
        find
            .ancestor(of: find.byKey(key), matching: find.byType(Visibility))
            .first,
      )
      .visible;

  group('ModeTransitionStack', () {
    testWidgets('does not animate the first child in', (tester) async {
      await tester.pumpWidget(stack(0));

      expect(tester.hasRunningAnimations, isFalse);
      expect(shiftOf(tester, a), 0);
      expect(opacityOf(tester, a), 1);
    });

    testWidgets('opens a later child from the end side', (tester) async {
      await tester.pumpWidget(stack(0));

      await tester.pumpWidget(stack(1));

      expect(shiftOf(tester, b), AppMotion.modeShift);
      expect(opacityOf(tester, b), 0);
    });

    testWidgets('opens an earlier child from the start side', (tester) async {
      await tester.pumpWidget(stack(2));

      await tester.pumpWidget(stack(1));

      expect(shiftOf(tester, b), -AppMotion.modeShift);
    });

    testWidgets('mirrors the direction in RTL', (tester) async {
      await tester.pumpWidget(stack(0, direction: TextDirection.rtl));

      await tester.pumpWidget(stack(1, direction: TextDirection.rtl));

      expect(shiftOf(tester, b), -AppMotion.modeShift);
    });

    testWidgets('slides the old child out the opposite way', (tester) async {
      await tester.pumpWidget(stack(0));

      await tester.pumpWidget(stack(1));
      await tester.pump(AppMotion.modeSwitch);

      expect(shiftOf(tester, a), -AppMotion.modeShift);
      expect(opacityOf(tester, a), 0);
    });

    testWidgets('shows both children during the switch', (tester) async {
      await tester.pumpWidget(stack(0));

      await tester.pumpWidget(stack(1));
      await tester.pump(const Duration(milliseconds: 100));

      expect(isShown(tester, a), isTrue);
      expect(isShown(tester, b), isTrue);
      expect(isShown(tester, c), isFalse);
    });

    testWidgets('leaves only the new child once it ends', (tester) async {
      await tester.pumpWidget(stack(0));

      await tester.pumpWidget(stack(1));
      await tester.pumpAndSettle();

      expect(isShown(tester, a), isFalse);
      expect(isShown(tester, b), isTrue);
      expect(shiftOf(tester, b), 0);
      expect(opacityOf(tester, b), 1);
    });

    testWidgets('a child cut short leaves from where it had got to', (
      tester,
    ) async {
      await tester.pumpWidget(stack(0));
      await tester.pumpWidget(stack(1));
      await tester.pump(const Duration(milliseconds: 100));
      final reached = opacityOf(tester, b);
      expect(reached, inExclusiveRange(0, 1));

      await tester.pumpWidget(stack(2));

      expect(opacityOf(tester, b), reached);
    });

    testWidgets('keeps every child mounted with its state', (tester) async {
      Widget withCounter(int index) => stack(
        index,
        children: const [
          _Counter(),
          SizedBox.expand(key: b),
        ],
      );
      await tester.pumpWidget(withCounter(0));
      await tester.tap(find.byType(_Counter));
      await tester.pump();

      await tester.pumpWidget(withCounter(1));
      await tester.pumpAndSettle();
      await tester.pumpWidget(withCounter(0));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('a hidden child takes no taps', (tester) async {
      var taps = 0;
      Widget withTarget(int index) => stack(
        index,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox.expand(),
          ),
          const SizedBox.expand(key: b),
        ],
      );
      await tester.pumpWidget(withTarget(0));

      await tester.pumpWidget(withTarget(1));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.byKey(b)));

      expect(taps, 0);
    });

    testWidgets('the closing child takes no taps', (tester) async {
      var taps = 0;
      Widget withTarget(int index) => stack(
        index,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox.expand(),
          ),
          const SizedBox.expand(key: b),
        ],
      );
      await tester.pumpWidget(withTarget(0));

      await tester.pumpWidget(withTarget(1));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(tester.getCenter(find.byType(ModeTransitionStack)));
      await tester.pumpAndSettle();

      expect(taps, 0);
    });
  });

  group('ModeEntrance', () {
    const first = Key('first');
    const second = Key('second');

    Widget entrances(int index, {Offset? offset, double scale = 1}) => stack(
      index,
      children: [
        const SizedBox.expand(),
        Column(
          children: [
            ModeEntrance(
              index: 1,
              offset: offset,
              scale: scale,
              child: const SizedBox.square(key: first, dimension: 40),
            ),
            ModeEntrance(
              index: 3,
              offset: offset,
              child: const SizedBox.square(key: second, dimension: 40),
            ),
          ],
        ),
      ],
    );

    testWidgets('rests in place outside a stack', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ModeEntrance(index: 1, child: SizedBox.square(key: first)),
        ),
      );

      expect(
        find.ancestor(of: find.byKey(first), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('waits for the panel to open', (tester) async {
      await tester.pumpWidget(entrances(1));

      expect(opacityOf(tester, first), 1);
      expect(opacityOf(tester, second), 1);
    });

    testWidgets('starts hidden on the side the panel opens from', (
      tester,
    ) async {
      await tester.pumpWidget(entrances(0));
      await tester.pumpWidget(entrances(1));

      expect(opacityOf(tester, first), 0);
      expect(
        shiftOf(tester, first),
        AppMotion.modeShift + AppMotion.entranceShift,
      );
    });

    testWidgets('a later index starts later', (tester) async {
      await tester.pumpWidget(entrances(0));
      await tester.pumpWidget(entrances(1));

      await tester.pump(const Duration(milliseconds: 150));

      expect(opacityOf(tester, first), greaterThan(0));
      expect(opacityOf(tester, second), 0);
    });

    testWidgets('settles exactly in place', (tester) async {
      await tester.pumpWidget(entrances(0, offset: const Offset(0, 18)));
      await tester.pumpWidget(
        entrances(1, offset: const Offset(0, 18), scale: .94),
      );

      await tester.pumpAndSettle();

      expect(opacityOf(tester, first), 1);
      expect(tester.getSize(find.byKey(first)), const Size.square(40));
      expect(
        tester.getTopLeft(find.byKey(second)).dy -
            tester.getTopLeft(find.byKey(first)).dy,
        40,
      );
    });

    testWidgets('scales up from the given size', (tester) async {
      await tester.pumpWidget(entrances(0, scale: .5));
      await tester.pumpWidget(entrances(1, scale: .5));

      expect(tester.getRect(find.byKey(first)).width, 20);
    });
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _count++),
      child: SizedBox.expand(child: Text('$_count')),
    );
  }
}
