import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencok/core/audio/background_music/background_music.dart';
import 'package:opencok/l10n/app_localizations.dart';
import 'package:opencok/ui/hud/screens/hud_preview_screen/hud_preview_screen.dart';

Widget _host() => const MaterialApp(
  locale: Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BackgroundMusic(child: HudPreviewScreen()),
);

void main() {
  testWidgets('HUD preview actions open real panels instead of snackbars', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_host());
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Daily'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Gather Kingdom Resources'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Claim').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Claimed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.bySemanticsLabel('Items'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('50K Wood Crate (x6)'), findsOneWidget);

    await tester.tap(find.text('Use').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('50K Wood Crate (x5)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.bySemanticsLabel('Alliance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('[COK] Knights of OpenCoK'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.bySemanticsLabel('Chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField), 'Hello Kingdom!');
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Hello Kingdom!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('OpenCoK: Hello Kingdom!'), findsOneWidget);
  });
}
