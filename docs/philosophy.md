# Philosophy

Design principles for frond.

## Building Blocks, Not Frameworks

Frond provides primitives. Users compose them.

- State machines that can drive anything (animation, AI, gameplay)
- Controllers that work with any physics backend
- Generators that output data, not side effects

We don't dictate game structure. We provide the Lego bricks.

## Kinematic Over Dynamic

For character controllers, kinematic beats dynamic:

| Approach | Pros | Cons |
|----------|------|------|
| **Kinematic** | Predictable, code-driven, "feels right" | You calculate movement yourself |
| **Dynamic** | Physically accurate | Floaty, hard to tune, unpredictable |

Use physics engines (Rapier) for collision detection. Use code for movement feel.

Warframe-style movement (bullet jumping, aim gliding, wall running) is impossible with dynamic bodies. It's pure kinematic - every velocity vector calculated explicitly.

## Hot-Reloadable Feel

Iteration speed matters. You can't feel a game by reading code.

**The Setup:**
- Logic (Rust): FSMs, vector math, state transitions
- Parameters (Assets): `movement.ron` - jump_force, slide_decay, gravity
- Bridge: Hot-reload config on save

**The Workflow:**
1. Write the logic once
2. Run the game
3. Tweak `bullet_jump_force` from 10.0 to 50.0
4. Instantly feel the difference

No recompile. No restart. Immediate feedback.

## State Machines for Behavior

LLMs excel at generating clean FSMs. So do humans. They're explicit, debuggable, composable.

```rust
enum MovementState {
    Idle,
    Run,
    Slide,
    BulletJump,
    WallRun,
}
```

Each state owns its behavior. Transitions are explicit. Edge cases are visible.

**Bad:** "Can I double jump after a wall hop but not after a bullet jump?"
→ Hidden in spaghetti logic

**Good:** State machine with explicit `can_double_jump` per state
→ Visible, testable, debuggable

## Bevy Compatibility

Compatible with Bevy, not dependent on it.

- Use individual crates: `bevy_math`, `bevy_ecs`, `bevy_reflect`
- Core types convertible to/from Bevy equivalents
- No `bevy` (the full crate) as a dependency

This keeps frond usable outside Bevy while playing nice with the ecosystem.

## General Internal, Constrained APIs

Store the general representation, expose simpler APIs for common cases.

Internal complexity, external simplicity. Power users can access the general form.
