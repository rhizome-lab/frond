# Introduction

Frond is a library of game design primitives - composable building blocks for game mechanics.

## What Frond Is

- **Building blocks** - not a framework
- **Primitives** you compose into your game
- **Engine agnostic** - works with Bevy, macroquad, or no engine
- **Kinematic-first** for predictable game feel

## What Frond Isn't

- Not a game engine
- Not a framework that dictates structure
- Not physics simulation (use Rapier for that)

## Primitives

| Primitive | Purpose |
|-----------|---------|
| State Machines | Movement, AI, animation, gameplay states |
| Procedural Generation | Noise, WFC, tileset generation |
| Character Controllers | Kinematic movement with game feel |
| Camera Controllers | Follow, orbit, cinematic cameras |

## Philosophy

Frond follows these principles:

1. **Building blocks, not frameworks** - You compose primitives
2. **Kinematic over dynamic** - Code-driven movement feels better
3. **Hot-reloadable feel** - Logic in Rust, parameters in config
4. **State machines for behavior** - Explicit transitions, not implicit

See [Philosophy](/philosophy) for the full design philosophy.
