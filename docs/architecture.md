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

- `glam` - Math types (shared by Bevy, macroquad, rend3, others)
- `serde` - Serialization for config files
- `thiserror` - Error handling

### Per-Crate Dependencies

Each crate declares only what it needs. The umbrella `frond` crate re-exports all primitives.

### Integration Crates

Engine-specific adapters live in separate crates:

```
frond-bevy/       # Bevy components, systems, plugins
frond-macroquad/  # macroquad integration
```

## Engine Agnostic Design

Core frond crates have zero engine dependencies:

```rust
// Works standalone - no engine required
let mut fsm = StateMachine::new(MovementState::Idle);
fsm.update(&input);

// Works with any engine that uses glam
let velocity: glam::Vec3 = controller.velocity();
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

Load via `serde` with any format (RON, TOML, JSON).
