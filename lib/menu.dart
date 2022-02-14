import 'dart:async' as async;
import 'dart:math';
import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/game.dart';
import 'package:darkness_dungeon/player/local/knight.dart';
import 'package:darkness_dungeon/socket/connect_socket_manager.dart';
import 'package:darkness_dungeon/util/custom_sprite_animation_widget.dart';
import 'package:darkness_dungeon/util/enemy_sprite_sheet.dart';
import 'package:darkness_dungeon/util/localization/strings_location.dart';
import 'package:darkness_dungeon/util/player_sprite_sheet.dart';
import 'package:darkness_dungeon/util/sounds.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool showSplash = true;
  int currentPosition = 0;
  async.Timer _timer;
  List<Future<SpriteAnimation>> sprites = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: showSplash ? buildSplash() : buildMenu(),
    );
  }

  Widget buildMenu() {
    Size sizeScreen = MediaQuery.of(context).size;
    tileSize = max(sizeScreen.height, sizeScreen.width) / 15;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Darkness Dungeon",
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Normal', fontSize: 30.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            if (sprites.isNotEmpty)
              SizedBox(
                height: 100,
                width: 100,
                child: CustomSpriteAnimationWidget(
                  animation: sprites[currentPosition],
                ),
              ),
            SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: 150,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                color: Color.fromARGB(255, 118, 82, 78),
                child: Text(
                  getString('play_cap'),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Normal',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Game(Knight(ConnectionManager.clientId,
                              initPosition: Vector2(2.0 * tileSize, 3.0 * tileSize),
                            ),[])),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 20,
          margin: EdgeInsets.all(20.0),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('connectStatus'),
                      // Provider.
                      // context.watch<bool>(),
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Normal',
                          fontSize: 12.0),
                    ),
                    InkWell(
                      onTap: () {
                        ConnectionManager.getInstance();
                        // _launchURL('https://github.com/RafaelBarbosatec');
                      },
                      child: Text(
                        context.select((ConnectionManager p) => p.connectStatus)
                            ? " connected"
                            : " reConnect",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('built_with'),
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Normal',
                          fontSize: 12.0),
                    ),
                    InkWell(
                      onTap: () {
                        // _launchURL(
                        Map map = Map();
                        map["data"]='https://github.com/RafaelBarbosatec/bonfire';
                        Provider.of<ConnectionManager>(context, listen: false)
                            .sendUdpMessage(map);
                        // );
                      },
                      child: Text(
                        'Bonfire',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSplash() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (BuildContext context) {
        setState(() {
          showSplash = false;
        });
        startTimer();
      },
    );
  }

  void startTimer() {
    _timer = async.Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        currentPosition++;
        if (currentPosition > sprites.length - 1) {
          currentPosition = 0;
        }
      });
      // print(currentPosition);
      ConnectionManager.getInstance();
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
