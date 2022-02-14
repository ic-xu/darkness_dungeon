import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/socket/connect_socket_manager.dart';
import 'package:darkness_dungeon/util/functions.dart';
import 'package:darkness_dungeon/util/game_sprite_sheet.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';

import 'package:flutter/material.dart';
import 'package:darkness_dungeon/util/extensions.dart';
import 'package:logger/logger.dart';

class Knight extends SimplePlayer with Lighting, ObjectCollision {
  final Vector2 initPosition;

  final logger = Logger();
  double attack = 25;
  double stamina = 100;
  double initSpeed = tileSize / 0.25;
  async.Timer _timerStamina;
  bool containKey = false;
  JoystickMoveDirectional currentDirection;
  bool showObserveEnemy = false;
  String directionEvent = 'IDLE';
  final String id;
  TextPaint _textConfig;
  String nick = "test";

  Knight( this.id, { this.initPosition, }) : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          width: tileSize,
          height: tileSize,
          position: initPosition,
          life: 200,
          speed: tileSize / 0.25,
        ) {
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

    setupLighting(
      LightingConfig(
        radius: width * 3,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );

    _textConfig = TextPaint(
      style: TextStyle(
        fontSize: tileSize / 4,
        color: Colors.white,
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    this.speed = initSpeed * event.intensity;
    currentDirection = event.directional;
    switch (currentDirection) {
      case JoystickMoveDirectional.MOVE_UP:
        directionEvent = 'UP';
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        directionEvent = 'UP_LEFT';
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        directionEvent = 'UP_RIGHT';
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        directionEvent = 'RIGHT';
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        directionEvent = 'DOWN';
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        directionEvent = 'DOWN_RIGHT';
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        directionEvent = 'DOWN_LEFT';
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        directionEvent = 'LEFT';
        break;
      case JoystickMoveDirectional.IDLE:
        directionEvent = 'IDLE';
        break;
    }
    Map move = {
      'action': 'MOVE',
      'time': DateTime.now().millisecondsSinceEpoch,
      'data': {
        'player_id': id,
        'direction': directionEvent,
        'x': (position.position.x / tileSize),
        'y': (position.position.y / tileSize)
      }
    };
    Map<String, Object> udpData = new Map();
    udpData["topic"] = topic;
    udpData["body"] = move;
    udpData["id"] = id;
    _sendUdpMessage(udpData);
    logger.d("server posion ---->  $udpData");
    super.joystickChangeDirectional(event);
  }

  //异步发送数据
  _sendUdpMessage(Map data) async {
    ConnectionManager.getInstance().sendUdpMessage(data);
  }

  _sendTcpMessage(Map data) {
    ConnectionManager.getInstance().sendMessage(data);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }
    super.joystickAction(event);
  }

  @override
  void die() {

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

  void actionAttack() {
    Map move = {
      'action': 'actionAttack',
      'time': DateTime.now().millisecondsSinceEpoch,
      'direction': this.lastDirection.getName(),
    };
    Map<String, Object> udpData = new Map();
    udpData["topic"] = topic;
    udpData["body"] = move;
    udpData["id"] = id;
    _sendUdpMessage(udpData);

    if (stamina < 15) {
      return;
    }

    // Sounds.attackPlayerMelee();
    decrementStamina(15);
    this.simpleAttackMelee(
      damage: attack,
      animationDown: PlayerSpriteSheet.attackEffectBottom(),
      animationLeft: PlayerSpriteSheet.attackEffectLeft(),
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      animationUp: PlayerSpriteSheet.attackEffectTop(),
      direction: lastDirection.getName().getDirectionEnum(),
      withPush: true,
      height: tileSize,
      width: tileSize,
    );
  }

  void actionAttackRange() {
    Map move = {
      'action': 'actionAttackRange',
      'time': DateTime.now().millisecondsSinceEpoch,
      'direction': this.lastDirection.getName(),
    };
    Map<String, Object> udpData = new Map();
    udpData["topic"] = topic;
    udpData["body"] = move;
    udpData["id"] = id;
    _sendUdpMessage(udpData);

    if (stamina < 10) {
      return;
    }

    // Sounds.attackRange();
    double x = position.position.x;
    double y = position.position.y;
    decrementStamina(10);
    this.simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationLeft: GameSpriteSheet.fireBallAttackLeft(),
      animationUp: GameSpriteSheet.fireBallAttackTop(),
      animationDown: GameSpriteSheet.fireBallAttackBottom(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      width: tileSize * 0.65,
      height: tileSize * 0.65,
      damage: 10,
      direction: lastDirection.getName().getDirectionEnum(),
      speed: initSpeed * (tileSize / 32),
      enableDiagonal: true,
      withCollision: true,
      destroy: () {
        // Sounds.explosion();
      },
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Size(tileSize / 2, tileSize / 2)),
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
    this.seeEnemy(
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

  @override
  void receiveDamage(double damage, dynamic fromId) {
    if (isDead) return;
    _sendDamageData(damage, life, fromId);
    this.showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, fromId);

  }

  void _sendDamageData(double damage, double lifeValue, dynamic fromId) {
    Map receiveDamage = {
      'action': 'receiveDamage',
      'time': DateTime.now().millisecondsSinceEpoch,
      'damage': damage,
      'life': lifeValue,
      // 'fromId': fromId
    };
    Map<String, Object> udpData = new Map();
    udpData["topic"] = topic;
    udpData["body"] = receiveDamage;
    udpData["id"] = id;
    _sendUdpMessage(udpData);
    // _sendTcpMessage(udpData);
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
