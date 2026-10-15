import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/widgets/app_svg_icon.dart';

/// Finds the [AppSvgIcon]s drawing [asset] (one of the `AppIcons`).
Finder findSvgIcon(String asset) => find.byWidgetPredicate(
  (widget) => widget is AppSvgIcon && widget.asset == asset,
  description: 'AppSvgIcon($asset)',
);
