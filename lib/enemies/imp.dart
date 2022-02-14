import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/player/remote/remote_knight.dart';
import 'package:darkness_dungeon/util/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:flutter/material.dart';

class Imp extends SimpleEnemy with ObjectCollision {
  final Vector2 initPosition;
  double attack = 10;

  Imp(this.initPosition)
      : super(
          animation: EnemySpriteSheet.impAnimations(),
          position: initPosition,
          width: tileSize * 0.8,
          height: tileSize * 0.8,
          speed: tileSize / 0.30,
          life: 80,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(
              valueByTileSize(6),
              valueByTileSize(6),
            ),
            align: Vector2(
              valueByTileSize(3),
              valueByTileSize(5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    this.drawDefaultLifeBar(
      canvas,
      borderRadius: BorderRadius.circular(2),
    );
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    this.seeAndMoveToPlayer(
      radiusVision: tileSize * 5,
      closePlayer: (player) {
        execAttack();
      },
    );

    _seeAndMoveComponent(tileSize * 4, closePlayer: (palyer) {
      execAttack();
    });
  }

  void _seeAndMoveComponent(double radiusVision,
      {Function(GameComponent) closePlayer, double margin = 10}) {
    gameRef.componentsByType().forEach((comp) {
      if (comp is RemoteKnight && gameRef.size!=null) {
        if (isDead) return;
        if (!this.isVisible) return;
        seeComponent(comp, observed: (comp) {
          this.followComponent(
            comp,
            dtUpdate,
            closeComponent: (comp) => closePlayer(comp as RemoteKnight),
            margin: margin,
          );
        });
      }
    });
  }

  void execAttack() {
    this.simpleAttackMelee(
      height: tileSize * 0.62,
      width: tileSize * 0.62,
      damage: attack,
      interval: 300,
      animationDown: EnemySpriteSheet.enemyAttackEffectBottom(),
      animationLeft: EnemySpriteSheet.enemyAttackEffectLeft(),
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      animationUp: EnemySpriteSheet.enemyAttackEffectTop(),
      execute: () {
        Sounds.attackEnemyMelee();
      },
    );
  }

  @override
  void die() {
    gameRef.add(
      AnimatedObjectOnce(
        animation: GameSpriteSheet.smokeExplosion(),
        position: this.position,
      ),
    );
    removeFromParent();
    super.die();
  }

  @override
  void receiveDamage(double damage, dynamic id) {
    this.showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, id);
  }
}
