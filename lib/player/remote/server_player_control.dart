import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

mixin ServerRemotePlayerControl on SimplePlayer {
  static const EVENT_SOCKET_NAME = 'message';
  static const ACTION_MOVE = 'MOVE';
  static const ACTION_ATTACK = 'ATTACK';
  static const ACTION_RECEIVED_DAMAGE = 'RECEIVED_DAMAGE';
  static const ACTION_PLAYER_LEAVED = 'PLAYER_LEAVED';
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  String playerId;


  String nick = "test";


  String currentMove = 'IDLE';
  int time = 0;

  void setupServerPlayerControl(
    String id,
  ) {
    playerId = id;


    _initSocketMessage();
  }

  void _initSocketMessage() {
    mainEventBus.on<Map>().listen((map) {
      if (map["topic"] == topic && map["id"] == playerId) {
        Map move = map["body"];
        switch (move["action"]) {
          case 'MOVE':
            int serverTime = move["time"];
            if (this.time <= serverTime) {
              this.time = serverTime;
              String direction = move['data']['direction'];
              double x = move['data']['x'] * tileSize;
              double y = move['data']['y'] * tileSize;

              serverMove(direction, x, y);
            }
            break;
          case 'actionAttack':
            String direction = move["direction"];
            actionAttack(direction);
            break;
          case 'actionAttackRange':
            String direction = move["direction"];
            actionAttackRange(direction);
            break;

          case 'receiveDamage':
            life = move["life"];
            // receiveDamage(move["damage"], move['fromId']);
            serverReceiveDamage(move["damage"]);
            break;
        }
      }
    });
  }


  @override
  void update(double dt) {
    _move(currentMove);
    super.update(dt);
  }




  void _move(move) {
    switch (move) {
      case 'LEFT':
        this.moveLeft(speed);
        break;
      case 'RIGHT':
        this.moveRight(speed);
        break;
      case 'UP_RIGHT':
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveUpRight(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case 'DOWN_RIGHT':
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveDownRight(
          speedDiagonal,
          speedDiagonal,
        );

        break;
      case 'DOWN_LEFT':
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveDownLeft(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case 'UP_LEFT':
        double speedDiagonal = (speed * REDUCTION_SPEED_DIAGONAL);
        moveUpLeft(
          speedDiagonal,
          speedDiagonal,
        );
        break;
      case 'UP':
        this.moveUp(speed);
        break;
      case 'DOWN':
        this.moveDown(speed);
        break;
      case 'IDLE':
        this.idle();
        break;
    }
  }

  void serverMove(String direction,  double x,double y) {
    currentMove = direction;
    Rect serverPosition = Rect.fromLTWH(
      x,
      y,
      width,
      height,
    );
    position.position.x = x;
    position.position.x = y;

    position = serverPosition.toVector2Rect();


    // currentMove = direction;
    // /// Corrige posição se ele estiver muito diferente da do server
    // Vector2 p = Vector2(serverPosition.center.dx, serverPosition.center.dy);
    // double dist = p.distanceTo(Vector2(
    //   position.center.dx,
    //   position.center.dy,
    // ));
    //
    // if (dist > (tileSize * 0.5)) {
    //   position = serverPosition.toVector2Rect();
    // }
    // this.position.translate(serverPosition.left-position.left, serverPosition.top-position.top);
  }


  void serverReceiveDamage(double damage) {
    if (!isDead) {
      this.showDamage(
        damage,
        config: TextStyle(color: Colors.red, fontSize: 14),
      );
      if (life > 0) {
        life -= damage;
        if (life <= 0) {
          die();
        }
      }
    }
  }


  void actionAttack(String direction);

  void actionAttackRange(String direction);

  void serverPlayerLeave() {
    if (!isDead) {
      die();
    }
  }
}
