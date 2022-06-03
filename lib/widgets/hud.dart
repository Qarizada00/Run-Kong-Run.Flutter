import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/game/kong_run.dart';
import '../game/audio.dart';
import '/models/player_data.dart';
import '/widgets/pause_menu.dart';

// This represents the head up display in game.
// It consists of, current score, high score,
// a pause button and number of remaining lives.
class Hud extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'Hud';

  // Reference to parent game.
  final KongRun gameRef;

  const Hud(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.playerData,
      child: Container(
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return Text(
                          'Score: $score',
                          style:
                              const TextStyle(fontSize: 20, color: Colors.white),
                        );
                      },
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.level,
                      builder: (_, level, __) {
                        return Text(
                          'Level: $level',
                          style:
                              const TextStyle(fontSize: 20, color: Colors.white),
                        );
                      },
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.highScore,
                      builder: (_, highScore, __) {
                        return Text(
                          'High: $highScore',
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    gameRef.overlays.remove(Hud.id);
                    gameRef.overlays.add(PauseMenu.id);
                    gameRef.pauseEngine();
                    AudioManager.instance.pauseBgm();
                  },
                  child: const Icon(Icons.pause, color: Colors.white),
                ),
                Column(
                  children: [
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.lives,
                      builder: (_, lives, __) {
                        return Row(
                          children: List.generate(5, (index) {
                            if (index < lives) {
                              return const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              );
                            } else {
                              return const Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              );
                            }
                          }),
                        );
                      },
                    ),
                    Column(children: [
                      FloatingActionButton(
                        onPressed: () {
                          gameRef.superpower();
                          gameRef.playerData.superpower=0;
                        },
                        child: const Icon(Icons.bolt_rounded, color: Colors.white),
                        backgroundColor: Colors.red.withOpacity(1),
                        foregroundColor: Colors.orange,
                      )
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
