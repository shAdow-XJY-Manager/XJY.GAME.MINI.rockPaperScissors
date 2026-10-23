import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rock_paper_scissors/main.dart';
import 'package:rock_paper_scissors/game.dart';
import 'package:rock_paper_scissors/frequency/game_support.dart';

void main() {
  testWidgets(
    'same opponent is a no-op and cancelling a mode change preserves the series',
    (tester) async {
      final match = RpsMatch()..add(0, 2);
      saveMap('rock-paper-scissors.save', {
        'match': match.toJson(),
        'session': 'retained-series',
        'two': false,
        'predictive': false,
        'locked': 0,
        'finished': false,
      });
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      await tester.tap(find.text('均衡随机'));
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        readMap('rock-paper-scissors.save')!['session'],
        'retained-series',
      );
      await tester.tap(find.text('历史预测'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('保留进度'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        readMap('rock-paper-scissors.save')!['session'],
        'retained-series',
      );
      expect(
        objectMap(readMap('rock-paper-scissors.save')!['match']),
        match.toJson(),
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '均衡随机'))
            .selected,
        isTrue,
      );
      await tester.tap(find.text('继续系列赛'));
      await tester.pump();
      await tester.tap(find.text('切换对手模式'));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.text('保留进度'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('已暂停'), findsNothing);
      expect(find.text('石头').hitTestable(), findsOneWidget);
      expect(
        readMap('rock-paper-scissors.save')!['session'],
        'retained-series',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
