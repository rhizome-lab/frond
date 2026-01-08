# TODO

## Next Up

- [ ] Implement `frond-fsm` crate with basic `State` trait
- [ ] Implement `frond-controller` with kinematic character controller
- [ ] Add `.ron` config loading for movement parameters
- [ ] Create example: basic movement FSM with Bevy

## Backlog

### State Machines
- [ ] Hierarchical state machines (substates)
- [ ] State machine visualization/debugging
- [ ] Coyote time and input buffering utilities
- [ ] State machine serialization for save/load

### Character Controllers
- [ ] 2D kinematic controller
- [ ] 3D kinematic controller
- [ ] Rapier integration example
- [ ] XPBD integration example
- [ ] Warframe-style movement preset (bullet jump, wall run, aim glide)

### Camera Controllers
- [ ] Follow camera with smoothing
- [ ] Orbit camera (third-person)
- [ ] First-person camera
- [ ] Camera shake system
- [ ] Cinematic camera paths

### Procedural Generation
- [ ] Noise wrapper with octaves/persistence
- [ ] Room-based dungeon generator
- [ ] Cellular automata caves
- [ ] Loot table system

### Wave Function Collapse
- [ ] 2D simple tiled model
- [ ] Backtracking solver
- [ ] 3D support
- [ ] Overlapping model

### Infrastructure
- [ ] CI/CD with GitHub Actions
- [ ] Publish to crates.io
- [ ] Deploy docs to GitHub Pages
- [ ] Integration tests for each primitive
