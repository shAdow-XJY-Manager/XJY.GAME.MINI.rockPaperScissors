import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:rock_paper_scissors/game.dart';

void main() {
  test('all nine gesture pairs follow rock/paper/scissors rules', () {
    const outcomes = [
      [0, -1, 1],
      [1, 0, -1],
      [-1, 1, 0],
    ];
    for (var player = 0; player < 3; player++) {
      for (var opponent = 0; opponent < 3; opponent++) {
        expect(rpsResult(player, opponent), outcomes[player][opponent]);
      }
    }
    expect(() => rpsResult(-1, 0), throwsArgumentError);
    expect(() => rpsResult(0, 3), throwsArgumentError);
  });

  test('draws do not score; first three wins end the series', () {
    for (final winner in [1, -1]) {
      final match = RpsMatch();
      expect(match.add(0, 0), isTrue);
      expect([match.player, match.opponent], [0, 0]);
      for (var i = 0; i < 3; i++) {
        expect(match.add(winner == 1 ? 1 : 0, winner == 1 ? 0 : 1), isTrue);
        expect(match.over, i == 2);
      }
      expect([match.player, match.opponent], winner == 1 ? [3, 0] : [0, 3]);
      expect(match.add(2, 0), isFalse);
      expect(match.rounds, hasLength(4));
      final restored = RpsMatch.fromJson(
        jsonDecode(jsonEncode(match.toJson())),
      );
      expect(restored!.toJson(), match.toJson());
      expect(restored.over, isTrue);
    }
  });

  test('save scores are recomputed and tampered rounds are rejected', () {
    final match = RpsMatch()
      ..add(0, 2)
      ..add(1, 1)
      ..add(2, 0);
    final restored = RpsMatch.fromJson(match.toJson())!;
    expect([restored.player, restored.opponent], [1, 1]);
    for (final rounds in [
      [
        [0, 2, -1],
      ],
      [
        [3, 0, 1],
      ],
      [
        [0, 0],
      ],
      [
        [1, 0, 1],
        [1, 0, 1],
        [1, 0, 1],
        [0, 0, 0],
      ],
    ]) {
      expect(RpsMatch.fromJson({'version': 1, 'rounds': rounds}), isNull);
    }
    expect(RpsMatch.fromJson({'version': 2, 'rounds': []}), isNull);
  });

  test('predictive choice uses only the last twenty previous gestures', () {
    for (var seed = 0; seed < 50; seed++) {
      final recent = List<int>.filled(20, 0);
      expect(
        chooseGesture(
          [...List<int>.filled(30, 2), ...recent],
          true,
          Random(seed),
        ),
        chooseGesture(recent, true, Random(seed)),
      );
      expect(chooseGesture([], false, Random(seed)), inInclusiveRange(0, 2));
    }
  });
}
