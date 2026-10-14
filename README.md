# CityLifeOnline - 3D Open World Prototype (Godot 4)

A modular, Android-optimized third-person open-world game prototype built with **Godot 4.7** and **GDScript**, featuring Quaternius's **Downtown City MegaKit**, the **Universal Base Character** system, and the **Universal Animation Library (UAL)**.

---

## Live Features: Universal Animation Library (UAL) Connected

### 1. 43 Handcrafted Skeletal Animations
The player character is now powered directly by Quaternius's **Universal Animation Library** (`UAL1_Standard.glb`) connected to Godot's `AnimationPlayer`:
- **Smooth Cross-Fading Locomotion State Machine**:
  - `Idle`: Smooth breathing and resting pose (cross-fade: `0.25s`).
  - `Walk`: Natural rhythmic walking stride matching movement speed (cross-fade: `0.20s`).
  - `Sprint`: High-energy athletic sprinting animation when holding sprint or moving fast (cross-fade: `0.20s`).
  - `Jump`: Dynamic leaping and in-air hang animation (cross-fade: `0.15s`).
- **Dynamic Speed Scaling**: The playback speed of the walking and sprinting animations scales proportionally with the player's actual physical velocity (`speed_scale = h_speed / base_speed`).
- **Synchronized Hairstyle Tracking**: The character's 3D hair (`Hair_SimpleParted.gltf`) has an synchronized `AnimationPlayer` tracking the head bone transforms in real-time.
- **Full Library of 43 Action Animations Available**:
  - Locomotion: `Walk`, `Jog_Fwd`, `Sprint`, `Jump`, `Jump_Start`, `Jump_Land`, `Crouch_Idle`, `Crouch_Fwd`, `Roll`
  - Emotes & Actions: `Dance`, `Interact`, `PickUp_Table`, `Punch_Jab`, `Punch_Cross`
  - Vehicle & Weapons (Ready for future milestones): `Driving`, `Pistol_Aim_Neutral`, `Pistol_Shoot`, `Pistol_Reload`, `Pistol_Idle`

### 2. Modular Character Outfits & Dress System
- **Pre-rigged Modular Outfits**: Equipped with high-fidelity glTF modular outfits from Quaternius's Fantasy pack sharing the exact same 65-bone skeleton as the base body and animation library:
  - **Male Ranger Outfit**: Full leather tunic dress, hood, pauldrons, belts, bracers, trousers, and boots with PBR textures.
  - **Male Peasant Outfit**: Historic tunic dress, boots, and trousers.
- **Dynamic Outfit Hot-Swapping**:
  - Press `O` on PC or tap the on-screen **"Outfit: Ranger / Peasant"** button on mobile to hot-swap dresses seamlessly in real-time.
  - All equipped outfits receive synchronized animations from `UAL1_Standard.glb`.

### 3. Natural Facing Direction & Third-Person Locomotion
- **Authentic Third-Person Facing**:
  - **Spawn**: Spawns facing forward into the city down the road, back to the third-person camera.
  - **Press W (Forward)**: Character runs forward down the road, facing away from the camera.
  - **Press S (Backward)**: Character turns and runs toward the screen, facing the player and camera.
  - **Press A / D (Left / Right)**: Character turns naturally and runs left or right.

### 4. Complete Downtown City MegaKit Environment Applied
The world now features the full modular 3D environment system from the **Downtown City MegaKit**:
- **Modular 3D Road Network (23 segments)**:
  - Grand 4-Lane Avenue (12m wide corridor) made with consecutive `Street_2Lane.gltf` and `Street_4Lane.gltf` segments.
  - Central 4-Way Crossroads with `Street_4WayIntersection.gltf` with integrated crosswalks and curb cuts.
  - Cross Streets with `Street_Curve_2Lane.gltf` (90° corner turn) and asphalt transition plazas (`Street_Asphalt_6x6.gltf`).
- **Modular 3D Sidewalks (78 tiles)**:
  - Snapped 3m grid with `Sidewalk_Straight_3m.gltf`, `Sidewalk_Straight_3m_Stripe.gltf` (tactile hazard stripes), and `Sidewalk_Planter.gltf` (tree pit tiles).
  - Wide pedestrian promenade tiles (`Sidewalk_NoCurb_3m.gltf`) in front of retail storefronts and apartment complexes.
- **Asphalt Decals & Markings (25 markings)**:
  - Centerline `Decal_DoubleYellow_Straight.gltf` and dashed `Decal_BrokenLine_Straight.gltf`.
  - `Decal_Stop.gltf` stop text before intersections.
  - Lane arrows: `Decal_ArrowStraight.gltf`, `Decal_ArrowTurnLeft.gltf`, `Decal_ArrowTurnRight.gltf`, `Decal_Only.gltf`.
  - Safety & cycling: `Decal_Crosswalk.gltf` (zebra crossings), `Decal_Bikelane.gltf`, and `Decal_Slow.gltf`.
- **Urban Street Furniture & Props (26 props)**:
  - Cast-iron `Prop_ManholeCover.gltf` on road asphalt.
  - Curb gutter `Prop_Drain.gltf` storm drains.
  - Stainless steel `Prop_Bollard.gltf` lining pedestrian crossings.
  - Concrete `Prop_Planter_Single.gltf` with lush greenery.
  - Industrial `Prop_ACUnit.gltf` mounted on building facades.
- **Architectural Entrances & Stairs (7 components)**:
  - `Stairs_Entrance_Concrete.gltf` entrance steps with `Stairs_Rails_Metal.gltf` handrails leading to building stoops.
  - `DoorFrame_Wooden.gltf` and `Door_1.gltf` welcoming entrances.
- **Downtown Skyline (8 high-rises & retail buildings)**:
  - Authentic 17m to 28m NYC/Boston towers, brownstones, and storefronts with custom physics collisions.

### 5. Controls & Android Performance
- **Desktop**: `WASD` to move, `Shift` to sprint, `Space` to jump, `O` to toggle outfit, Mouse look (`Escape` toggles capture), `R` to reset.
- **Mobile**: Touch virtual joystick, `JUMP` and `RUN` buttons, right-screen touch look swipe zone, and on-screen **Outfit Toggle Button**.

---

## Project Structure

```
city-life-online/
├── assets/
│   ├── characters/
│   │   ├── animations/             # UAL1_Standard.glb (43 animations without root motion)
│   │   ├── universal_base/         # Male & Female base models and hairstyles
│   │   └── modular_outfits/        # Peasant & Ranger outfits and modular parts
│   └── models/
│       └── downtown_city/          # 300+ glTF models from Downtown City MegaKit
├── scenes/
│   ├── player/
│   │   └── player.tscn             # CharacterBody3D, Universal Base 3D model, hair, SpringArm3D
│   ├── ui/
│   │   └── touch_controls.tscn     # Mobile virtual joystick, Jump/Run buttons, Look zone
│   └── world/
│       ├── buildings/              # MegaKit 28m, 25m, 17m buildings with collisions
│       ├── props/                  # Street lights, trees, parked cars
│       └── main_world.tscn         # Active city world scene
├── scripts/
│   ├── player/
│   │   ├── camera_controller.gd    # Smooth camera rotation and spring arm isolation
│   │   └── player.gd               # Locomotion & Animation State Machine (Idle, Walk, Sprint, Jump)
│   └── ...
└── README.md
```

---

## How to Run & Test

```powershell
& "..\..\Godot_v4.7.2-stable_win64.exe" --path .
```
*(Or press **F5** in the Godot 4 Editor)*