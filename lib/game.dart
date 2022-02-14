import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/decoration/door.dart';
import 'package:darkness_dungeon/decoration/key.dart';
import 'package:darkness_dungeon/decoration/potion_life.dart';
import 'package:darkness_dungeon/decoration/spikes.dart';
import 'package:darkness_dungeon/decoration/torch.dart';
import 'package:darkness_dungeon/enemies/boss.dart';
import 'package:darkness_dungeon/enemies/goblin.dart';
import 'package:darkness_dungeon/enemies/imp.dart';
import 'package:darkness_dungeon/enemies/mini_boss.dart';
import 'package:darkness_dungeon/interface/knight_interface.dart';
import 'package:darkness_dungeon/main.dart';
import 'package:darkness_dungeon/npc/kid.dart';
import 'package:darkness_dungeon/player/local/knight.dart';
import 'package:darkness_dungeon/socket/connect_socket_manager.dart';
import 'package:darkness_dungeon/util/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'player/remote/remote_knight.dart';

class Game extends StatefulWidget {
  final Knight knight;
  final List<RemoteKnight> remoteKnight;

  const Game(this.knight, this.remoteKnight, {Key key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game>
    with WidgetsBindingObserver
    implements GameListener {
  bool showGameOver = false;

  GameController _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController()..addListener(this);
    _initSocketMessage();
    _sendPlayJoin();
    _getUser();
    // Sounds.playBackgroundSound();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Sounds.resumeBackgroundSound();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        // Sounds.pauseBackgroundSound();
        break;
      case AppLifecycleState.detached:
        // Sounds.stopBackgroundSound();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Sounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BonfireTiledWidget(
        gameController: _controller,
        joystick: Joystick(
          directional: JoystickDirectional(
            spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
            spriteKnobDirectional: Sprite.load('joystick_knob.png'),
            size: 100,
            isFixed: false,
          ),
          actions: [
            JoystickAction(
              actionId: 0,
              sprite: Sprite.load('joystick_atack.png'),
              spritePressed: Sprite.load('joystick_atack_selected.png'),
              size: 80,
              margin: EdgeInsets.only(bottom: 50, right: 50),
            ),
            JoystickAction(
              actionId: 1,
              sprite: Sprite.load('joystick_atack_range.png'),
              spritePressed: Sprite.load('joystick_atack_range_selected.png'),
              size: 50,
              margin: EdgeInsets.only(bottom: 50, right: 160),
            )
          ],
        ),
        player: widget.knight,
        map: TiledWorldMap(
          'tiled/map.json',
          forceTileSize: Size(tileSize, tileSize),
          objectsBuilder: {
            'door': (p) => Door(p.position, p.size),
            // 'torch': (p) => Torch(p.position),
            'potion': (p) => PotionLife(p.position, 30),
            // 'wizard': (p) => WizardNPC(p.position),
            'spikes': (p) => Spikes(p.position),
            'key': (p) => DoorKey(p.position),
            'kid': (p) => Kid(p.position),
            'boss': (p) => Boss(p.position),
            'goblin': (p) => Goblin(p.position),
            'imp': (p) => Imp(p.position),
            'mini_boss': (p) => MiniBoss(p.position),
            'torch_empty': (p) => Torch(p.position, empty: true),
          },
        ),
        interface: KnightInterface(),
        lightingColorGame: Colors.black.withOpacity(0.9),
        background: BackgroundColorGame(Colors.grey[900]),
        progress: Center(
          child: Text(
            "Loading...",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Normal',
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }

  void _initMap(){
    _controller.livingEnemies.forEach((enemy) {
      enemy.position;
    });
  }

  void _showDialogGameOver() {
    setState(() {
      showGameOver = true;
    });
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => Game(
                  Knight(
                    ConnectionManager.clientId,
                    initPosition: Vector2(2 * tileSize, 3 * tileSize),
                  ),
                  [])),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {
    // _controller.addGameComponent(RemoteKnight(22,initPosition: Vector2(1 * tileSize, 1 * tileSize)));
    if (_controller.player != null && _controller.player.isDead) {
      if (!showGameOver) {
        showGameOver = true;
        _showDialogGameOver();
      }
    }
  }

  void _sendPlayJoin() {
    Map player = Map();
    player["id"] = widget.knight.id;
    player["initSpeed"] = widget.knight.initSpeed;
    player["x"] = widget.knight.initPosition.x;
    player["y"] = widget.knight.initPosition.y;

    Map data = Map();
    data["type"] = "join";
    data["data"] = player;

    ConnectionManager.getInstance().publish(topic, data);
  }

  void _getUser() async {
    var httpClient = new HttpClient();
    var uri = new Uri.http(
        '120.77.220.166:8090', '/users', {'topic': topic, 'param2': 'foo'});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    List list = convert.jsonDecode(responseBody);
    list.forEach((map) {
      if (map["clientId"] != widget.knight.id) {
        Vector2 position = Vector2(3 * tileSize, 3 * tileSize);
        RemoteKnight remoteKnight =
        RemoteKnight(map["clientId"], initPosition: position);
        _controller.addGameComponent(remoteKnight);
      }
    });
  }

  void _initSocketMessage() {
    mainEventBus.on<MqttPublishMessage>().listen((publishMessage) {
      if (publishMessage.variableHeader.topicName == topic) {
        Map data = convert.jsonDecode(
            utf8.decoder.convert(publishMessage.payload.message.toList()));
        if (data["type"] == "join") {
          Map map = data["data"];
          var id = map["id"];
          if (id != widget.knight.id) {
            Vector2 position = Vector2(3 * tileSize, 3 * tileSize);
            RemoteKnight remoteKnight =
                RemoteKnight(map["id"], initPosition: position);
            _controller.addGameComponent(remoteKnight);
          }
        }
      }
    });
  }
}
