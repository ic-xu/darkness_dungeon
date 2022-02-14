import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/player/remote/remote_knight.dart';
import 'package:darkness_dungeon/util/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Goblin extends SimpleEnemy with ObjectCollision {
  final Vector2 initPosition;
  double attack = 25;

  Goblin(this.initPosition)
      : super(
          animation: EnemySpriteSheet.goblinAnimations(),
          position: initPosition,
          width: tileSize * 0.8,
          height: tileSize * 0.8,
          speed: tileSize / 0.35,
          life: 120,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(
              valueByTileSize(7),
              valueByTileSize(7),
            ),
            align: Vector2(valueByTileSize(3), valueByTileSize(4)),
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
    _seeAndMoveComponent(tileSize * 4,closePlayer: (palyer){
      execAttack();
    });
  }

  void _seeAndMoveComponent(double radiusVision,
      {Function(GameComponent) closePlayer, double margin = 10}) {
    this.seeAndMoveToPlayer(closePlayer: closePlayer,radiusVision: tileSize * 4,);

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

  /*
     seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        this.followComponent(
          player,
          dtUpdate,
          closeComponent: (comp) => closePlayer(comp as Player),
          margin: margin,
        );
      },
      notObserved: () {
        if (!this.isIdle) {
          this.idle();
        }
      },
    );

   */

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

  void execAttack() {
    this.simpleAttackMelee(
      height: tileSize * 0.62,
      width: tileSize * 0.62,
      damage: attack,
      interval: 800,
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
