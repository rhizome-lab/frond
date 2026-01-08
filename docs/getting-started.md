# Getting Started

## Installation

Add frond crates to your `Cargo.toml`:

```toml
[dependencies]
frond-fsm = "0.1"
frond-controller = "0.1"
```

Or use the umbrella crate:

```toml
[dependencies]
frond = "0.1"
```

## Quick Example: Movement State Machine

```rust
use frond_fsm::{StateMachine, State};

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
enum MovementState {
    Idle,
    Run,
    Jump,
    Fall,
}

impl State for MovementState {
    type Context = PlayerInput;

    fn update(&self, ctx: &Self::Context) -> Option<Self> {
        match self {
            Self::Idle => {
                if ctx.jump_pressed { Some(Self::Jump) }
                else if ctx.move_input.length() > 0.1 { Some(Self::Run) }
                else { None }
            }
            Self::Run => {
                if ctx.jump_pressed { Some(Self::Jump) }
                else if ctx.move_input.length() < 0.1 { Some(Self::Idle) }
                else { None }
            }
            Self::Jump => {
                if ctx.velocity.y < 0.0 { Some(Self::Fall) }
                else { None }
            }
            Self::Fall => {
                if ctx.grounded { Some(Self::Idle) }
                else { None }
            }
        }
    }
}
```

## With Bevy

Frond primitives integrate with Bevy's ECS:

```rust
use bevy::prelude::*;
use frond_fsm::StateMachine;

fn movement_system(
    mut query: Query<(&mut StateMachine<MovementState>, &PlayerInput)>,
) {
    for (mut fsm, input) in &mut query {
        fsm.update(input);
    }
}
```

## Next Steps

- [State Machines](/primitives/state-machines) - Deep dive into FSMs
- [Character Controllers](/primitives/character-controllers) - Kinematic movement
- [Philosophy](/philosophy) - Design principles
