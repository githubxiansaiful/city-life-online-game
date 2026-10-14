# CityLifeOnline - 3D Open World Prototype (Godot 4)

A modular, Android-optimized third-person open-world game prototype built with **Godot 4.7** and **GDScript**, featuring Quaternius's **Downtown City MegaKit** Boston/NYC-style architecture.

---

## Live Features: Downtown City MegaKit Integration

### 1. Authentic Boston & NYC Modular Architecture
The procedural boxes have been replaced with the official **Downtown City MegaKit** 3D glTF models with full physical collisions:
- **West Tower & East Tower** ([scenes/world/buildings/building_large.tscn](file:///D:/godot-game/game/city-life-online/scenes/world/buildings/building_large.tscn)):
  - Authentic 28-meter tall NYC/Boston commercial high-rise (`Building_Large_2.gltf`).
  - Features brick & slate facade, ornate windows, and slate cornices with `BoxShape3D` collision (`20.6m x 28.0m x 16.6m`).
- **West & East Medium Apartments** ([scenes/world/buildings/building_medium.tscn](file:///D:/godot-game/game/city-life-online/scenes/world/buildings/building_medium.tscn)):
  - Authentic 25-meter tall Boston brownstone apartment building (`Building_Medium_2_001.gltf`).
  - Detailed multi-tier windows, brick textures, and entrance trim with `BoxShape3D` collision (`15.0m x 25.0m x 13.0m`).
- **West & East Small Storefronts** ([scenes/world/buildings/building_small.tscn](file:///D:/godot-game/game/city-life-online/scenes/world/buildings/building_small.tscn)):
  - Authentic 17-meter tall street-level commercial townhouse (`Building_Small_1.gltf`).
  - Ground-floor store entrance and decorative trim with `BoxShape3D` collision (`12.5m x 17.0m x 14.5m`).

### 2. Street Furniture & Urban Props from MegaKit
- **Security Bollards** (`Prop_Bollard.gltf`): 4 pedestrian protection bollards lining the crosswalk sidewalk corners.
- **Urban Planters** (`Prop_Planter_Single.gltf`): Street greenery planters placed on the sidewalks.
- **Street Manhole Covers** (`Prop_ManholeCover.gltf`): Embedded directly into the asphalt boulevard.
- **Rooftop & Alley AC Units** (`Prop_ACUnit.gltf`): Detailed air conditioning compressor units mounted along building walls.

### 3. Locomotion, Camera & Vehicles
- **Stylized 3D Human Character**: Articulated head, hair, sunglasses, streetwear jacket, arms, hands, denim pants, and sneakers with real-time procedural walking/sprinting and jump animations.
- **Smooth Third-Person Camera**: Orbiting camera with `SpringArm3D` collision dampening and GTA-style downward angle.
- **Vehicles & Atmosphere**: Curbside parked cars (Red Sedan, Blue SUV, Silver Compact), street lights, trees, and soft sunlight.