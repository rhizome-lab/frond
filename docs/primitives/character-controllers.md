# Character Controllers

Kinematic character controllers for predictable game feel.

## Kinematic vs Dynamic

| Aspect | Kinematic | Dynamic |
|--------|-----------|---------|
| Movement | Code-calculated velocity | Physics-simulated |
| Feel | Predictable, responsive | Floaty, realistic |
| Tuning | Direct: change numbers | Indirect: mass, friction |
| Use case | Platformers, action games | Ragdolls, realistic sims |

Playmate is kinematic-first. Use physics for collision detection, not movement.

## Basic Structure

```rust
struct KinematicController {
    velocity: Vec3,
    grounded: bool,
    config: MovementConfig,
}

struct MovementConfig {
    gravity: f32,
    max_speed: f32,
    acceleration: f32,
    friction: f32,
    jump_force: f32,
}
```

## Movement Loop

```rust
impl KinematicController {
    fn update(&mut self, input: &Input, dt: f32) {
        // Apply gravity
        if !self.grounded {
            self.velocity.y -= self.config.gravity * dt;
        }

        // Apply input
        let wish_dir = input.movement.normalize_or_zero();
        self.velocity.x = wish_dir.x * self.config.max_speed;
        self.velocity.z = wish_dir.z * self.config.max_speed;

        // Friction when grounded
        if self.grounded && input.movement.length() < 0.1 {
            self.velocity.x *= self.config.friction;
            self.velocity.z *= self.config.friction;
        }
    }

    fn move_and_collide(&mut self, physics: &mut Physics, dt: f32) {
        let displacement = self.velocity * dt;
        let result = physics.move_shape(displacement);

        self.grounded = result.grounded;
        self.velocity = result.velocity;
    }
}
```

## Warframe-Style Movement

High-mobility movement uses chained states:

```rust
enum MovementState {
    Grounded,
    Slide,       // crouch while running
    BulletJump,  // crouch + jump while sliding
    AimGlide,    // hold aim in air
    WallRun,     // contact wall while airborne
    DoubleJump,  // jump in air
}
```

Each state has:
- **Entry impulse** - BulletJump applies large upward + forward force
- **Persistent effect** - AimGlide reduces gravity
- **Chaining rules** - Can double jump after wall hop but not after bullet jump

## With Rapier

```rust
use bevy_rapier3d::prelude::*;

fn kinematic_move(
    mut query: Query<(&mut KinematicController, &mut KinematicCharacterController)>,
    physics: Res<RapierContext>,
) {
    for (mut ctrl, mut kcc) in &mut query {
        kcc.translation = Some(ctrl.velocity * time.delta_seconds());
    }
}
```
