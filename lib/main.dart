import 'package:darkness_dungeon/menu.dart';
import 'package:darkness_dungeon/socket/connect_socket_manager.dart';
import 'package:darkness_dungeon/util/localization/my_localizations_delegate.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:event_bus/event_bus.dart' as events;
import 'package:provider/provider.dart';
import 'util/sounds.dart';

double tileSize;
events.EventBus mainEventBus = events.EventBus();
String topic="/game/join";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  await Sounds.initialize();
  await ConnectionManager.getInstance();
  MyLocalizationsDelegate myLocation = const MyLocalizationsDelegate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Normal',
        ),
        home: Menu(),
        supportedLocales: MyLocalizationsDelegate.supportedLocales(),
        localizationsDelegates: [
          myLocation,
          DefaultCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: myLocation.resolution,
      ),
    ),
  );
}
