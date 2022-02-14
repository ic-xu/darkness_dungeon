import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor {
  final double damage;

  Spikes(Vector2 position, {this.damage = 60})
      : super.withAnimation(
          GameSpriteSheet.spikes(),
          position: position,
          width: tileSize,
          height: tileSize,
        ) {
    setupSensorArea(
      size: Vector2(width,height),
      align: position,
      intervalCheck: 100,
    );
  }

  @override
  void onContact(GameComponent collision) {
    if (collision is Player) {
      if (this.animation.currentIndex == this.animation.frames.length - 1 ||
          this.animation.currentIndex == this.animation.frames.length - 2) {
        gameRef.player.receiveDamage(damage, 0);
      }
    }
  }

  @override
  int get priority => LayerPriority.getComponentPriority(1);
}
