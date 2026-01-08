# TODO

## Scope

**Frond** = Runtime game mechanics (per-frame behavior, queries, state)
**Resin** = Computation-graph-based generation (lazy eval, node graphs, expressions)

The split: Resin generates, Frond runs.

## Next Up

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
8. **Character controllers** - kinematic movement math
9. **Camera controllers** - follow, orbit, first-person math
10. **Behavior trees** - alternative to FSM for AI

### Questions to Resolve

- Character/camera controllers: pure math primitives, or too engine-specific?
- Animation state machines: subset of FSM, or separate concern?
- Should stat systems include buff/debuff with duration (overlaps timing)?
- Behavior trees vs FSM vs GOAP - one, some, or all?

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
- [ ] Base + modifier system
- [ ] Stackable buffs with priorities
- [ ] Derived stats (calculated from others)
- [ ] Stat serialization

### Controllers (uncertain scope)
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

## For Resin

These belong in resin (graph-based generation), not frond:

- [ ] WFC (2D simple tiled, overlapping, 3D)
- [ ] Dungeon generation (room placement, corridors)
- [ ] Cellular automata (cave generation)
- [ ] Loot tables / weighted random
- [ ] Noise wrappers (octaves, persistence, domain warping)
- [ ] Terrain generation
- [ ] Name generators, markov chains
