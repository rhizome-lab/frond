# TODO

## Vision

**Frond** = Game mechanics toolkit that lowers the barrier to game development.

**Goals:**
- Discoverability - find good patterns without stumbling
- Accessibility - use patterns without being an expert
- Moddability - end users can tweak game behavior

**Multi-engine:** Support Godot, Bevy, Unity, Love2D, custom engines.

**Resin** = Computation-graph-based generation (separate project)

## Architecture

```
frond/
├── core/                    # Pure Rust, no engine deps
│   ├── frond-spatial/       # Quadtree, BVH, spatial hash
│   ├── frond-pathfinding/   # A*, flow fields, nav mesh
│   └── frond-math/          # Kinematic helpers, curves
│
├── bindings/                # Engine-specific adapters
│   ├── frond-godot/         # GDExtension
│   ├── frond-bevy/          # Bevy systems/components
│   ├── frond-unity/         # NativePlugin + C# wrapper
│   └── frond-love/          # Lua FFI for Love2D
│
├── scripting/               # Game logic in engine-native languages
│   ├── frond-gdscript/      # GDScript library
│   ├── frond-lua/           # Lua patterns (Love2D, etc.)
│   └── frond-csharp/        # C# patterns (Unity)
│
└── docs/                    # Universal patterns, language-agnostic
```

## What Lives Where

| Layer | Contents | Why |
|-------|----------|-----|
| **core/** | Spatial, pathfinding, math | Perf-critical, complex algorithms, called 1000s/frame |
| **bindings/** | Engine glue | Thin adapters to expose core to each engine |
| **scripting/** | FSM, stats, inventory, timing, damage | Game logic, moddable, rapid iteration |
| **docs/** | Camera, coyote time, patterns | Universal knowledge, any language |

**Rule of thumb:** If modders should be able to change it, it's scripting. If it needs to be fast, it's core.

## Next Up

- [ ] Learn Godot basics (editor, GDScript, scenes)
- [ ] Research what Godot has built-in vs gaps
- [ ] Set up GDExtension for Rust integration
- [ ] Define core/ crate boundaries
- [ ] Design first scripting pattern (FSM? timing?)

**First target: Godot** - best modding story (.pck), accessible scripting, forces good API design that ports to other engines.

## Core (Rust)

Performance-critical, complex algorithms.

### Spatial
- [ ] Quadtree / Octree
- [ ] Spatial hashing (grid)
- [ ] BVH for ray/shape queries
- [ ] Broadphase collision candidates
- [ ] Generic traits for engine integration

### Pathfinding
- [ ] A* on generic graph
- [ ] Grid-based pathfinding (JPS?)
- [ ] Flow fields
- [ ] Nav mesh representation and queries

### Math Utilities
- [ ] Kinematic movement helpers
- [ ] Curve evaluation (bezier, lookup tables)
- [ ] Interpolation utilities

## Bindings

Thin adapters per engine.

### Godot (frond-godot)
- [ ] GDExtension setup
- [ ] Expose spatial queries to GDScript
- [ ] Expose pathfinding to GDScript
- [ ] Resource types for nav meshes

### Bevy (frond-bevy)
- [ ] Components for spatial structures
- [ ] Systems for pathfinding
- [ ] Integration with bevy_rapier/avian

### Unity (frond-unity)
- [ ] Native plugin build
- [ ] C# wrapper API
- [ ] Unity editor integration?

### Love2D (frond-love)
- [ ] Lua FFI bindings
- [ ] Love2D-friendly API

## Scripting

Game logic in engine-native languages. Moddable.

### Per-Language Libraries

**GDScript (frond-gdscript):**
- [ ] FSM base class
- [ ] Timing utilities (cooldown, coyote time, input buffer)
- [ ] Stat/modifier system
- [ ] Inventory slot system
- [ ] Damage calculation helpers

**Lua (frond-lua):**
- [ ] Same patterns as GDScript
- [ ] Love2D integration examples

**C# (frond-csharp):**
- [ ] Same patterns for Unity

### Patterns to Implement (all languages)

**State Machines:**
- [ ] Basic FSM
- [ ] Hierarchical (substates)
- [ ] Pushdown (state stack)

**Timing:**
- [ ] Cooldown timers
- [ ] Coyote time
- [ ] Input buffering
- [ ] Tick scheduler

**Stats:**
- [ ] Tag-based modifiers (not hardcoded elements)
- [ ] Flat/multiplicative/additive stacking
- [ ] Derived stats
- [ ] Buff/debuff with duration

**Inventory:**
- [ ] Data-driven slot definitions
- [ ] Tag-based item filtering
- [ ] Stacking vs unique items

**Controllers:**
- [ ] Character movement patterns
- [ ] Camera patterns (follow, orbit, first-person)

## Documentation

Universal patterns, language-agnostic explanations.

- [ ] Camera patterns (follow, orbit, shake, cinematic)
- [ ] Coyote time and input buffering explained
- [ ] Damage calculation patterns (PoE-style, simple, etc.)
- [ ] Inventory design patterns
- [ ] FSM vs behavior trees vs GOAP comparison
- [ ] "How to make X moddable" guide

## Research

### Existing Solutions

- [ ] Godot: what's built-in vs gaps?
- [ ] Bevy: `big-brain`, `seldom_state`, spatial crates
- [ ] Unity: common asset store patterns
- [ ] Love2D: existing Lua libraries

### Prior Art

- [ ] RPG in a Box - accessibility patterns
- [ ] MCreator - modding patterns
- [ ] GDScript + .pck - modding architecture
- [ ] PoE damage calculation
- [ ] Warframe mod system

## Infrastructure

- [ ] Monorepo structure for multi-crate
- [ ] CI/CD per engine target
- [ ] Documentation site (VitePress)
- [ ] Examples per engine

## For Resin

These belong in resin (graph-based generation), not frond:

- [ ] WFC (2D simple tiled, overlapping, 3D)
- [ ] Dungeon generation (room placement, corridors)
- [ ] Cellular automata (cave generation)
- [ ] Loot tables / weighted random
- [ ] Noise wrappers
- [ ] Terrain generation
- [ ] Name generators, markov chains

## Low Priority

- [ ] Investigate GDScript typed array ergonomics
  - `Array[String]` rejects untyped `Array` even with string contents
  - Currently using untyped `Array` in public APIs as workaround
  - Check if Godot 4.x has fixes or better patterns
  - Consider runtime validation helper if typed arrays stay annoying
