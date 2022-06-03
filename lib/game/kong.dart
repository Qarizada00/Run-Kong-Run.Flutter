import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/kong_run.dart';
import 'audio.dart';
import '/models/player_data.dart';

/// This enum represents the animation states of [Kong].
enum KongAnimationStates {
  idle,
  run,
  kick,
  hit,
  sprint,
}

// This represents the kong character of this game.
class Kong extends SpriteAnimationGroupComponent<KongAnimationStates>
    with CollisionCallbacks, HasGameRef<KongRun> {
  // A map of all the animation states and their corresponding animations.
  static final _animationMap = {
    KongAnimationStates.idle: SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 0.1,
      textureSize: Vector2.all(23),
    ),
    KongAnimationStates.run: SpriteAnimationData.sequenced(
      amount: 24,
      stepTime: .05,
      textureSize: Vector2.all(23),

    ),
    KongAnimationStates.kick: SpriteAnimationData.sequenced(
      amount: 24,
      stepTime: .1,
      textureSize: Vector2.all(23),
    ),
    KongAnimationStates.hit: SpriteAnimationData.sequenced(
      amount: 24,
      stepTime: .1,
      textureSize: Vector2.all(23),
    ),
    KongAnimationStates.sprint: SpriteAnimationData.sequenced(
      amount: 24,
      stepTime: .1,
      textureSize: Vector2.all(23),
    ),
  };

  // The max distance from top of the screen beyond which
  // kong should never go. Basically the screen height - ground height
  double yMax = 0.0;

  // Kong's current speed along y-axis.
  double speedY = 0.0;

  // Controls how long the hit animations will be played.
  final Timer _hitTimer = Timer(1);

  static const double gravity = 800;

  final PlayerData playerData;

  bool isHit = false;

  Kong(Image image, this.playerData)
      : super.fromFrameData(image, _animationMap);

  @override
  void onMount() {
    // First reset all the important properties, because onMount()
    // will be called even while restarting the game.
    _reset();

    // Add a hitbox for kong.
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
    yMax = y;

    /// Set the callback for [_hitTimer].
    _hitTimer.onTick = () {
      current = KongAnimationStates.run;
      isHit = false;
    };

    super.onMount();
  }

  @override
  void update(double dt) {
    // v = u + at
    speedY += gravity * dt;

    // d = s0 + s * t
    y += speedY * dt;

    /// This code makes sure that kong never goes beyond [yMax].
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != KongAnimationStates.hit) &&
          (current != KongAnimationStates.run)) {
        current = KongAnimationStates.run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  // Gets called when kong collides with other Collidables.
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Call hit only if other component is an Enemy and kong
    // is not already in hit state.
    if ((other is Enemy) && (!isHit)) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  // Returns true if kong is on ground.
  bool get isOnGround => (y >= yMax);

  // Makes the kong jump.
  void jump() {
    // Jump only if kong is on ground.
    if (isOnGround) {
      speedY = -350;
      current = KongAnimationStates.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  // This method changes the animation state to
  /// [KongAnimationStates.hit], plays the hit sound
  /// effect and reduces the player life by 1.
  void hit() {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = KongAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  // This method reset some of the important properties
  // of this component back to normal.
  void _reset() {
    if (isMounted) {
      shouldRemove = false;
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(32, gameRef.size.y - 20);
    size = Vector2.all(24);
    current = KongAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}
