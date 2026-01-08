# Camera Controllers

Camera primitives for various game styles.

## Follow Camera

Tracks a target with smoothing.

```rust
struct FollowCamera {
    offset: Vec3,      // offset from target
    smoothing: f32,    // 0 = instant, 1 = never catches up
}

impl FollowCamera {
    fn update(&mut self, camera: &mut Transform, target: Vec3, dt: f32) {
        let desired = target + self.offset;
        let t = 1.0 - self.smoothing.powf(dt);
        camera.translation = camera.translation.lerp(desired, t);
        camera.look_at(target, Vec3::Y);
    }
}
```

## Orbit Camera

Rotates around a target (third-person).

```rust
struct OrbitCamera {
    distance: f32,
    yaw: f32,      // horizontal rotation
    pitch: f32,    // vertical rotation
    pitch_limits: (f32, f32),
}

impl OrbitCamera {
    fn update(&mut self, input: &CameraInput) {
        self.yaw += input.mouse_delta.x * input.sensitivity;
        self.pitch -= input.mouse_delta.y * input.sensitivity;
        self.pitch = self.pitch.clamp(self.pitch_limits.0, self.pitch_limits.1);
    }

    fn get_transform(&self, target: Vec3) -> Transform {
        let rotation = Quat::from_euler(EulerRot::YXZ, self.yaw, self.pitch, 0.0);
        let offset = rotation * Vec3::new(0.0, 0.0, self.distance);
        Transform::from_translation(target + offset).looking_at(target, Vec3::Y)
    }
}
```

## First-Person Camera

Mouse-look without orbit.

```rust
struct FirstPersonCamera {
    yaw: f32,
    pitch: f32,
    sensitivity: f32,
}

impl FirstPersonCamera {
    fn update(&mut self, camera: &mut Transform, input: &CameraInput) {
        self.yaw -= input.mouse_delta.x * self.sensitivity;
        self.pitch -= input.mouse_delta.y * self.sensitivity;
        self.pitch = self.pitch.clamp(-89.0_f32.to_radians(), 89.0_f32.to_radians());

        camera.rotation = Quat::from_euler(EulerRot::YXZ, self.yaw, self.pitch, 0.0);
    }
}
```

## Camera Shake

```rust
struct CameraShake {
    trauma: f32,       // 0-1, decays over time
    decay: f32,        // how fast trauma decays
    max_offset: f32,
    max_rotation: f32,
}

impl CameraShake {
    fn add_trauma(&mut self, amount: f32) {
        self.trauma = (self.trauma + amount).min(1.0);
    }

    fn get_offset(&self, time: f32) -> (Vec3, f32) {
        let shake = self.trauma * self.trauma; // squared for better feel

        let offset = Vec3::new(
            noise(time * 10.0) * shake * self.max_offset,
            noise(time * 10.0 + 100.0) * shake * self.max_offset,
            0.0,
        );
        let rotation = noise(time * 10.0 + 200.0) * shake * self.max_rotation;

        (offset, rotation)
    }

    fn tick(&mut self, dt: f32) {
        self.trauma = (self.trauma - self.decay * dt).max(0.0);
    }
}
```
