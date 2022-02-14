import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class Sounds {
  static Future initialize() async {
    if (!kIsWeb) {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll([
        'attack_player.mp3',
        'attack_fire_ball.wav',
        'attack_enemy.mp3',
        'explosion.wav',
        'sound_interaction.wav',
      ]);
    }
  }

  static void attackPlayerMelee() async{
    if (kIsWeb) return;
   await FlameAudio.play('attack_player.mp3', volume: 0.4);
  }

  static void attackRange() async{
    if (kIsWeb) return;
    await  FlameAudio.play('attack_fire_ball.wav', volume: 0.3);
  }

  static void attackEnemyMelee() async{
    if (kIsWeb) return;
    await FlameAudio.play('attack_enemy.mp3', volume: 0.4);
  }

  static void explosion() async{
    if (kIsWeb) return;
    await  FlameAudio.play('explosion.wav');
  }

  static void interaction() async{
    if (kIsWeb) return;
    await FlameAudio.play('sound_interaction.wav', volume: 0.4);
  }

  static stopBackgroundSound() async {
    if (kIsWeb) return;
    return await FlameAudio.bgm.stop();
  }

  static void playBackgroundSound() async {
    if (kIsWeb) return;
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play('sound_bg.mp3');
  }

  static void playBackgroundBoosSound() async {
    if (kIsWeb) return;
    await FlameAudio.bgm.play('battle_boss.mp3');
  }

  static void pauseBackgroundSound() async {
    if (kIsWeb) return;
    await FlameAudio.bgm.pause();
  }

  static void resumeBackgroundSound() async{
    if (kIsWeb) return;
    await FlameAudio.bgm.resume();
  }

  static void dispose() async{
    if (kIsWeb) return;
    FlameAudio.bgm.dispose();
  }
}
