import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:darkness_dungeon/util/extensions.dart';
import 'server_player_control.dart';

class RemoteKnight extends SimplePlayer with ServerRemotePlayerControl ,Lighting, ObjectCollision {
  final Vector2 initPosition;
  double attack = 25;
  double stamina = 100;
  double initSpeed = tileSize / 0.25;
  async.Timer _timerStamina;
  bool containKey = false;
  bool showObserveEnemy = false;
  String id;
  TextPaint _textConfig;

  RemoteKnight(this.id,{
    this.initPosition,
  }) : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          width: tileSize,
          height: tileSize,
          position: initPosition,
          life: 200,
          speed: tileSize / 0.25,
        ) {
    this.playerId = id;

    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.circle(
            radius: tileSize/2,
            // CollisionArea.rectangle(
            // size: Size(tileSize, tileSize),
            align: Vector2(
              valueByTileSize(0),
              valueByTileSize(0),
            ),
          ),
        ],
      ),
    );

    _textConfig = TextPaint(
      style: TextStyle(
        fontSize: tileSize / 4,
        color: Colors.white,
      ),
    );

    setupLighting(
      LightingConfig(
        radius: width * 3,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
    setupServerPlayerControl(this.playerId);

  }





  @override
  void die() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        Sprite.load('player/crypt.png'),
        position: Vector2(
          this.position.center.dx,
          this.position.center.dy,
        ),
        height: 30,
        width: 30,
      ),
    );
    super.die();
  }

  void actionAttack(String direction) {
    if (stamina < 15) {
      return;
    }
    print("server actionAttack  ---->   $direction");

    // Sounds.attackPlayerMelee();
    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      animationDown: PlayerSpriteSheet.attackEffectBottom(),
      animationLeft: PlayerSpriteSheet.attackEffectLeft(),
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      animationUp: PlayerSpriteSheet.attackEffectTop(),
      direction: direction.getDirectionEnum(),
      withPush: true,
      // interval: 1,
      height: tileSize,
      width: tileSize,
    );
  }

  void actionAttackRange(String direction) {
    if (stamina < 15) {
      return;
    }
    print("server actionAttackRange ---->   $direction");
    double x = position.position.x;
    double y = position.position.y;
    print("server posion ---->  $x, $y");
    // Sounds.attackRange();

    decrementStamina(10);
    this.simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationLeft: GameSpriteSheet.fireBallAttackLeft(),
      animationUp: GameSpriteSheet.fireBallAttackTop(),
      animationDown: GameSpriteSheet.fireBallAttackBottom(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      width: tileSize * 0.65,
      height: tileSize * 0.65,
      direction: direction.getDirectionEnum(),
      damage: 10,
      speed: initSpeed * (tileSize / 32),
      enableDiagonal: true,
      withCollision: true,
      destroy: () {
        // Sounds.explosion();
      },
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Size(tileSize * 0.65, tileSize * 0.65)),
        ],
      ),
      lightingConfig: LightingConfig(
        radius: tileSize * 0.9,
        blurBorder: tileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    this.seeComponentType(
      radiusVision: tileSize * 6,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        _showEmote();
      },
    );
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    _textConfig.render(
      c,
      nick,
      Vector2(
        position.left + ((width - (nick.length * (width / 13))) / 2),
        position.top - (tileSize / 2),
      ),
    );

    this.drawDefaultLifeBar(
      c,
      borderRadius: BorderRadius.circular(2),
    );
    super.render(c);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(Duration(milliseconds: 150), () {
        _timerStamina = null;
      });
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }


  void _showEmote({String emote = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerObject(
        animation: SpriteAnimation.load(
          emote,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        positionFromTarget: Rect.fromLTWH(
          18,
          -6,
          tileSize / 2,
          tileSize / 2,
        ).toVector2Rect(),
      ),
    );
  }

}
