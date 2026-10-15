import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icecream/main.dart';

Future<void> openShop(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: IcecreamApp()));
}

void main() {
  testWidgets('free sauces do not change food prices', (tester) async {
    await openShop(tester);
    expect(find.text('合計 385 円'), findsOneWidget);
    await tester.tap(find.text('マヨネーズ（無料）'));
    await tester.tap(find.text('ケチャップ（無料）'));
    await tester.pump();
    expect(find.text('合計 385 円'), findsOneWidget);
    await tester.tap(find.text('🍗 ナゲット 400円'));
    await tester.pump();
    expect(find.text('合計 440 円'), findsOneWidget);
    await tester.tap(find.text('注文する'));
    await tester.pump();
    expect(find.textContaining('マヨネーズ・ケチャップ（無料）'), findsOneWidget);
  });

  testWidgets('set discount and paid napkin appear in total and receipt', (
    tester,
  ) async {
    await openShop(tester);
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    expect(find.text('合計 495 円'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pump();
    expect(find.text('合計 506 円'), findsOneWidget);
    await tester.tap(find.text('🍗 ナゲット 400円'));
    await tester.pump();
    expect(find.text('合計 561 円'), findsOneWidget);
    await tester.tap(find.text('注文する'));
    await tester.pump();
    expect(find.textContaining('セットドリンク割引: −50円'), findsOneWidget);
    expect(find.textContaining('紙ナプキン: あり（税抜10円）'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    expect(find.text('合計 451 円'), findsOneWidget);
    // The previous order keeps its original amounts.
    expect(find.textContaining('合計: 561 円'), findsOneWidget);
  });

  testWidgets('cola alone has no discount and an empty order is disabled', (
    tester,
  ) async {
    await openShop(tester);
    await tester.tap(find.text('マヨネーズ（無料）'));
    await tester.tap(find.text('フードなし（ドリンク単品）'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<FilterChip>(find.byType(FilterChip).first).selected,
      isFalse,
    );
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    expect(find.text('合計 165 円'), findsOneWidget);
    expect(find.text('セットドリンク割引 −50 円'), findsNothing);
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pump();
    expect(find.text('合計 176 円'), findsOneWidget);
    await tester.tap(find.text('注文する'));
    await tester.pump();
    expect(find.textContaining('🥤 コーラ 150円\n'), findsOneWidget);
    expect(find.textContaining('セットドリンク割引:'), findsNothing);
  });
}
