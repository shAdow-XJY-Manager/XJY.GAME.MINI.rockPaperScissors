import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rock_paper_scissors/main.dart';
import 'package:rock_paper_scissors/game.dart';
import 'package:rock_paper_scissors/frequency/game_support.dart';

void main() {
  setUp(() {
    saveMap('rock-paper-scissors.save', {});
    saveMap('results', {});
  });
  testWidgets(
    'Ready does not start; two-player handover reveals and records a series',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.text('猜拳'), findsOneWidget);
      expect(find.text('开始系列赛'), findsOneWidget);
      expect(find.text('石头'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(readMap('rock-paper-scissors.save'), isEmpty);
      await tester.tap(find.text('同屏双人'));
      await tester.pump();
      await tester.tap(find.text('开始系列赛'));
      await tester.pump();
      expect(find.text('开始系列赛'), findsNothing);
      for (var round = 0; round < 3; round++) {
        await tester.tap(find.text('石头'));
        await tester.pump();
        expect(find.text('选择已隐藏。请把屏幕交给玩家二。'), findsOneWidget);
        expect(find.text('石头'), findsNothing);
        expect(localRecords(), isEmpty);
        await tester.tap(find.text('我是玩家二，开始选择'));
        await tester.pump();
        await tester.tap(find.text('剪刀'));
        await tester.pump();
        expect(find.text('选择已锁定，正在同时揭晓…'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 250));
        final match = RpsMatch.fromJson(
          objectMap(readMap('rock-paper-scissors.save')!['match']),
        )!;
        expect(match.player, round + 1);
        expect(match.opponent, 0);
        expect(match.rounds.last, [0, 2, 1]);
      }
      expect(find.text('再来一场'), findsOneWidget);
      expect(localRecords().single['result'], '玩家一获胜');
      expect(readMap('rock-paper-scissors.save')!['finished'], isTrue);
    },
  );
}
