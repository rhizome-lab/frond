# Wave Function Collapse

Constraint-based procedural generation.

## Concept

WFC generates output by:
1. Starting with all possibilities at each cell
2. Collapsing cells to single values
3. Propagating constraints to neighbors
4. Repeating until complete (or contradiction)

## Tileset Definition

```rust
struct Tile {
    id: usize,
    // Allowed neighbors per direction
    // (up, right, down, left) for 2D
    neighbors: [HashSet<usize>; 4],
}

struct Tileset {
    tiles: Vec<Tile>,
    weights: Vec<f32>, // optional: selection bias
}
```

## Core Algorithm

```rust
struct WfcGrid {
    width: usize,
    height: usize,
    cells: Vec<HashSet<usize>>, // possible tiles per cell
    tileset: Tileset,
}

impl WfcGrid {
    fn collapse(&mut self, rng: &mut impl Rng) -> Result<(), WfcError> {
        while !self.is_complete() {
            // Find cell with lowest entropy (fewest possibilities)
            let cell = self.lowest_entropy_cell()?;

            // Collapse to single tile
            self.collapse_cell(cell, rng);

            // Propagate constraints
            self.propagate(cell)?;
        }
        Ok(())
    }

    fn collapse_cell(&mut self, idx: usize, rng: &mut impl Rng) {
        let possibilities: Vec<_> = self.cells[idx].iter().copied().collect();
        let weights: Vec<_> = possibilities
            .iter()
            .map(|&t| self.tileset.weights[t])
            .collect();

        let dist = WeightedIndex::new(&weights).unwrap();
        let chosen = possibilities[dist.sample(rng)];

        self.cells[idx] = HashSet::from([chosen]);
    }

    fn propagate(&mut self, start: usize) -> Result<(), WfcError> {
        let mut stack = vec![start];

        while let Some(idx) = stack.pop() {
            let (x, y) = (idx % self.width, idx / self.width);

            for (dir, (dx, dy)) in DIRECTIONS.iter().enumerate() {
                let nx = x as i32 + dx;
                let ny = y as i32 + dy;

                if !self.in_bounds(nx, ny) { continue; }

                let neighbor_idx = ny as usize * self.width + nx as usize;
                let allowed = self.get_allowed_neighbors(idx, dir);

                let before = self.cells[neighbor_idx].len();
                self.cells[neighbor_idx].retain(|t| allowed.contains(t));
                let after = self.cells[neighbor_idx].len();

                if after == 0 {
                    return Err(WfcError::Contradiction);
                }

                if after < before {
                    stack.push(neighbor_idx);
                }
            }
        }

        Ok(())
    }
}
```

## Usage

```rust
let tileset = Tileset::from_rules(vec![
    ("grass", vec![("grass", ALL), ("water", [DOWN])]),
    ("water", vec![("water", ALL), ("grass", [UP])]),
    ("sand", vec![("sand", ALL), ("water", ALL), ("grass", ALL)]),
]);

let mut grid = WfcGrid::new(32, 32, tileset);
grid.collapse(&mut rng)?;

// grid.cells now contains single-tile solutions
```

## Tips

- **Backtracking**: For complex tilesets, save state before collapse and backtrack on contradiction
- **Weighted tiles**: Bias towards common tiles for natural-looking output
- **Overlapping model**: Learn adjacency from example images
- **3D WFC**: Same algorithm, 6 directions instead of 4
