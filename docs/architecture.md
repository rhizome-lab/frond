# Architecture

Technical architecture of frond.

## Crate Structure

```
frond/
├── crates/
│   ├── frond/              # Umbrella re-export crate
│   ├── frond-fsm/          # State machines
│   ├── frond-controller/   # Character/camera controllers
│   ├── frond-procgen/      # Procedural generation
│   └── frond-wfc/          # Wave function collapse
└── docs/                   # VitePress documentation
```

## Dependencies

### Core Dependencies

- `glam` - Math types (Bevy-compatible)
- `bevy_math` - Extended math utilities
- `bevy_reflect` - Reflection for hot-reloading
- `serde` - Serialization for config files

### Per-Crate Dependencies

Each crate declares only what it needs. The umbrella `frond` crate re-exports all primitives.

## Bevy Integration

Frond crates are Bevy-compatible but not Bevy-dependent.

**Pattern:**
```rust
// Works standalone
let fsm = StateMachine::new(MovementState::Idle);
fsm.update(&input);

// Works with Bevy
#[derive(Component)]
struct PlayerFsm(StateMachine<MovementState>);
```

## Configuration

Tunable parameters live in asset files, not code.

```ron
// movement.ron
MovementConfig(
    jump_force: 15.0,
    gravity: 40.0,
    slide_decay: 0.95,
    bullet_jump_force: 50.0,
)
```

Load via `bevy_common_assets` or standard `serde` deserialization.
