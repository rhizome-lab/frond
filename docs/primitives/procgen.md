# Procedural Generation

Tools for generating content algorithmically.

## Noise

Coherent noise for natural-looking randomness.

```rust
use noise::{NoiseFn, Perlin};

struct TerrainGenerator {
    noise: Perlin,
    scale: f64,
    octaves: u32,
    persistence: f64,
}

impl TerrainGenerator {
    fn height_at(&self, x: f64, z: f64) -> f64 {
        let mut total = 0.0;
        let mut amplitude = 1.0;
        let mut frequency = 1.0;

        for _ in 0..self.octaves {
            total += self.noise.get([x * frequency / self.scale, z * frequency / self.scale]) * amplitude;
            amplitude *= self.persistence;
            frequency *= 2.0;
        }

        total
    }
}
```

## Dungeon Generation

Room-based dungeon layout.

```rust
struct Room {
    position: IVec2,
    size: IVec2,
}

struct DungeonGenerator {
    rooms: Vec<Room>,
    corridors: Vec<(usize, usize)>,
    rng: StdRng,
}

impl DungeonGenerator {
    fn generate(&mut self, count: usize) {
        // Place rooms with random positions
        for _ in 0..count {
            let room = self.try_place_room();
            if let Some(room) = room {
                self.rooms.push(room);
            }
        }

        // Connect rooms with corridors
        self.connect_rooms();
    }

    fn try_place_room(&mut self) -> Option<Room> {
        // Random room with no overlaps
        // ...
    }

    fn connect_rooms(&mut self) {
        // MST or similar for corridor placement
        // ...
    }
}
```

## Loot Tables

Weighted random selection.

```rust
struct LootTable<T> {
    entries: Vec<(T, f32)>, // (item, weight)
}

impl<T: Clone> LootTable<T> {
    fn roll(&self, rng: &mut impl Rng) -> T {
        let total: f32 = self.entries.iter().map(|(_, w)| w).sum();
        let mut roll = rng.gen_range(0.0..total);

        for (item, weight) in &self.entries {
            roll -= weight;
            if roll <= 0.0 {
                return item.clone();
            }
        }

        self.entries.last().unwrap().0.clone()
    }
}
```

## Cellular Automata

Cave generation via CA.

```rust
struct CaveGenerator {
    width: usize,
    height: usize,
    cells: Vec<bool>, // true = wall
}

impl CaveGenerator {
    fn step(&mut self) {
        let mut next = self.cells.clone();

        for y in 1..self.height - 1 {
            for x in 1..self.width - 1 {
                let neighbors = self.count_neighbors(x, y);
                let idx = y * self.width + x;

                // Standard cave rules: born if 5+, survive if 4+
                next[idx] = neighbors >= 5 || (self.cells[idx] && neighbors >= 4);
            }
        }

        self.cells = next;
    }

    fn count_neighbors(&self, x: usize, y: usize) -> usize {
        let mut count = 0;
        for dy in -1..=1 {
            for dx in -1..=1 {
                if dx == 0 && dy == 0 { continue; }
                let nx = (x as i32 + dx) as usize;
                let ny = (y as i32 + dy) as usize;
                if self.cells[ny * self.width + nx] {
                    count += 1;
                }
            }
        }
        count
    }
}
```
