# TODO

## Scope

**Frond** = Runtime game mechanics (per-frame behavior, queries, state)
**Resin** = Computation-graph-based generation (lazy eval, node graphs, expressions)

The split: Resin generates, Frond runs.

## Next Up

- [ ] Research existing Rust gamedev crates (gaps vs. solved problems)
- [ ] Refine candidate primitives into fundamental abstractions
- [ ] Determine crate boundaries (what groups together?)
- [ ] Design core traits/APIs before implementation

## Candidate Primitives

Runtime game mechanics to evaluate:

1. **State machines** - FSMs, hierarchical, pushdown automata
2. **Timing/scheduling** - cooldowns, timers, coyote time, input buffering
3. **Pathfinding** - A*, flow fields, nav mesh queries
4. **Spatial queries** - quadtrees, BVH, grid hashing
5. **Stat systems** - modifiers, buffs, calculated values
6. **Inventory/slots** - generic container abstractions
7. **Dialogue/quests** - branching trees, condition evaluation
8. **Character controllers** - kinematic movement math (low barrier, modular)
9. **Camera controllers** - follow, orbit, first-person math
10. **Behavior trees** - alternative to FSM for AI

### Questions to Resolve

- [ ] Controllers: math utilities with low barrier to entry - what's the right API?
- [ ] Animation state machines: subset of FSM, or separate concern?
- [ ] Buff duration: part of stat system or timing system?
- [ ] Behavior trees vs FSM vs GOAP - one, some, or all?
- [ ] Where does Rust end and scripting begin? (GDScript as prior art)

## Design Notes

### Stats System Design

**Principle:** Data-driven tags, not hardcoded enums. Elements, factions, damage types are user-defined.

**Damage pipeline stages:**
```
Source (attacker)     →  Calculation  →  Target (defender)  →  Final
─────────────────────────────────────────────────────────────────────
attack power             base damage     defense               damage number
crit multiplier          elemental       resistance            immunity (0x)
elemental bonuses        faction mods    faction weakness      reduction cap
weapon mods                              armor
```

Each stage can have:
- Flat modifiers (+10)
- Multiplicative (1.5x, PoE "more")
- Additive multipliers (PoE "increased", stacks)
- Curves/functions (level scaling, distance falloff)
- Conditional (only vs faction X, only if burning)

**Open questions:**
- How to represent modifier stacking rules? (PoE more vs increased)
- Curves: inline functions or data-defined (bezier, lookup table)?
- Order of operations: fixed pipeline or user-defined?

### Inventory System Design

**Principle:** Slots are data, not code. Body parts, slot counts are config.

```rust
struct SlotDefinition {
    id: SlotId,
    group: Option<SlotGroup>,  // "ring", "finger", "armor"
    count: usize,              // 2 ring slots, 10 cosmetic slots
    accepts: Vec<ItemTag>,     // filters what items fit
    body_part: Option<BodyPartId>,  // for paper-doll display
}
```

**Examples to support:**
- PoE: two ring slots
- Cosmetic: one or more per finger
- Warframe: multiple mod slots with polarity
- Diablo: single equipment per body part
- MMO: gear sets, transmog

**Open questions:**
- Stacking items (potions x99) vs unique items
- Item affixes/modifiers (ties into stat system)
- Inventory weight/size constraints

### Scripting Boundary

| Layer | Responsibility | Language |
|-------|---------------|----------|
| Frond | Primitives, perf-critical | Rust |
| Game logic | Rules, behaviors | Script (Lua/Rhai/user choice) |
| Data | Configuration | RON/TOML/JSON |

Frond types should be scripting-friendly:
- Simple types at API boundaries
- Avoid complex generics in public APIs
- Serde-compatible for config loading

## Backlog

### State Machines
- [ ] Basic FSM with typed states and transitions
- [ ] Hierarchical state machines (substates)
- [ ] Pushdown automata (state stack)
- [ ] State machine visualization/debugging
- [ ] Serialization for save/load

### Timing
- [ ] Cooldown timers
- [ ] Coyote time helper
- [ ] Input buffering
- [ ] Tick scheduler (run X every N frames/seconds)

### Pathfinding
- [ ] A* on generic graph
- [ ] Grid-based pathfinding
- [ ] Flow fields
- [ ] Nav mesh representation and queries

### Spatial
- [ ] Quadtree / Octree
- [ ] Spatial hashing (grid)
- [ ] BVH for ray/shape queries
- [ ] Broadphase collision candidates

### Stats
- [ ] Tag-based modifier system (no hardcoded elements)
- [ ] Modifier types: flat, multiplicative, additive stacking
- [ ] Damage pipeline with configurable stages
- [ ] Curves/functions for scaling
- [ ] Derived stats (calculated from others)
- [ ] Conditional modifiers (vs faction, on status)
- [ ] Stat serialization

### Inventory
- [ ] Data-driven slot definitions
- [ ] Slot groups with configurable counts
- [ ] Body part mapping for paper-doll
- [ ] Item tag filtering (what fits where)
- [ ] Stacking vs unique items
- [ ] Weight/size constraints (optional)

### Controllers
- [ ] 2D kinematic movement math
- [ ] 3D kinematic movement math
- [ ] Follow camera math
- [ ] Orbit camera math
- [ ] First-person look math

### Infrastructure
- [ ] CI/CD with GitHub Actions
- [ ] Publish to crates.io
- [ ] Deploy docs to GitHub Pages
- [ ] Integration tests for each primitive

## Research

### Existing Crates to Evaluate

- [ ] `big-brain` - behavior trees / utility AI
- [ ] `bevy_stat_system` or similar
- [ ] `pathfinding` crate
- [ ] Spatial: `rstar`, `bvh`, `parry`
- [ ] FSM: `statig`, `bevy_state`, `seldom_state`
- [ ] Inventory: does anything exist?

### Prior Art to Study

- PoE damage calculation (more vs increased)
- Warframe mod system (polarity, capacity)
- GDScript for scripting boundary patterns

## For Resin

These belong in resin (graph-based generation), not frond:

- [ ] WFC (2D simple tiled, overlapping, 3D)
- [ ] Dungeon generation (room placement, corridors)
- [ ] Cellular automata (cave generation)
- [ ] Loot tables / weighted random
- [ ] Noise wrappers (octaves, persistence, domain warping)
- [ ] Terrain generation
- [ ] Name generators, markov chains
