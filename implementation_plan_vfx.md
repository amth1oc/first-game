# VFX System: Muzzle Flash, Hit Impacts & WeaponImpact

Xây dựng hệ thống VFX hoàn chỉnh cho FPS: **Muzzle Flash**, **Hit Impact Particles** (bụi & máu), và tích hợp tất cả vào pipeline bắn hiện tại qua `WeaponEquipped.gd`.

---

## Architecture Overview

```
WeaponData (Resource)
  └── impacts: Array[WeaponImpact]    ← NEW: mảng impact theo surface tag

WeaponImpact (Resource)              ← NEW: resource định nghĩa VFX cho 1 loại bề mặt
  ├── surface_tag: String            (e.g. "default", "flesh", "metal")
  └── impact_scene: PackedScene      (particle scene tương ứng)

WeaponEquipped.gd                    ← MODIFIED: thêm spawn_muzzle_flash, spawn_impact
  ├── muzzle_flash_scene: PackedScene
  └── spawn_muzzle_flash()
      spawn_impact(hit_result)

Scenes (Nodes + GPUParticles3D)
  ├── VFX/MuzzleFlash/muzzle_flash.tscn
  ├── VFX/Impacts/impact_dust.tscn
  └── VFX/Impacts/impact_blood.tscn
```

---

## Proposed Changes

### 1. `WeaponImpact` Resource ← [NEW]

#### [NEW] `Weapons/Definitions/WeaponImpact.gd`
Resource nhỏ chứa cặp `(surface_tag, impact_scene)`:
```gdscript
class_name WeaponImpact
extends Resource

@export var surface_tag: String = "default"
@export var impact_scene: PackedScene
```

---

### 2. `WeaponData` ← [MODIFY]

#### [MODIFY] `Weapons/Definitions/Weapon_Data.gd`
Bỏ comment cũ, thêm 2 export thực sự:
```gdscript
@export var muzzle_flash_scene: PackedScene
@export var impacts: Array[WeaponImpact] = []
```

---

### 3. Muzzle Flash Scene ← [NEW]

#### [NEW] `VFX/MuzzleFlash/muzzle_flash.tscn`
Cấu trúc node:
```
MuzzleFlash (Node3D) — script: muzzle_flash.gd
  └── GPUParticles3D  (burst, one-shot, explosively lit)
  └── OmniLight3D     (flash light, tắt sau ~0.05s)
```

#### [NEW] `VFX/MuzzleFlash/muzzle_flash.gd`
Auto-free sau khi burst xong; không cần loop.

---

### 4. Hit Impact Scenes ← [NEW]

#### [NEW] `VFX/Impacts/impact_dust.tscn`
Cho surface_tag `"default"` và `"metal"`. Hạt nhỏ màu xám/nâu, bay tán xạ.

#### [NEW] `VFX/Impacts/impact_blood.tscn`
Cho surface_tag `"flesh"`. Hạt đỏ/tím, phun mạnh rồi rơi theo trọng lực.

#### [NEW] `VFX/Impacts/impact_particle.gd`
Script dùng chung: align theo normal, tự free khi hết particles.

---

### 5. `WeaponEquipped.gd` ← [MODIFY]

#### [MODIFY] `Weapons/Equip/WeaponEquipped.gd`
Thêm 3 thứ:

1. **`spawn_muzzle_flash()`** — instantiate từ `weapon_data.muzzle_flash_scene`, attach ở `muzzle_point`, auto-free.
2. **`spawn_impact(hit_result)`** — dò `surface_tag` từ collider (kiểm tra group hoặc metadata), chọn đúng scene từ `weapon_data.impacts`, spawn + align.
3. Gọi cả 2 trong **`fire_weapon()`** tại VFX Layer.

---

### 6. Surface Tag Setup (Convention)

Để `spawn_impact` biết chọn scene nào, ta dùng **Godot group** làm surface tag:
- `"surface_flesh"` → enemy/character bodies
- `"surface_metal"` → metal objects  
- `"surface_default"` → everything else (fallback)

Không cần thêm script vào enemy — chỉ cần add group trong editor.

---

## File Structure After Changes

```
new-game/
├── VFX/
│   ├── MuzzleFlash/
│   │   ├── muzzle_flash.gd
│   │   └── muzzle_flash.tscn
│   └── Impacts/
│       ├── impact_particle.gd
│       ├── impact_dust.tscn
│       └── impact_blood.tscn
└── Weapons/
    ├── Definitions/
    │   ├── Weapon_Data.gd         (modified)
    │   └── WeaponImpact.gd        (new)
    └── Equip/
        └── WeaponEquipped.gd      (modified)
```

---

## Verification Plan

### Automated Check
- Kiểm tra GDScript parse (không lỗi cú pháp)

### Manual In-Editor
1. Mở `revolver_data.tres` → Inspector thấy field `Muzzle Flash Scene` và `Impacts` array ✓
2. Assign `muzzle_flash.tscn` vào `muzzle_flash_scene`
3. Thêm 2 phần tử vào `Impacts`: `("default", impact_dust.tscn)`, `("flesh", impact_blood.tscn)`
4. Play game → Bắn → Thấy flash tại muzzle ✓
5. Bắn vào tường → Thấy dust ✓
6. Bắn vào enemy (cần add group `surface_flesh`) → Thấy blood ✓

---

## Open Questions

> [!IMPORTANT]
> **Enemy Surface Tag**: Enemy hiện tại có script `take_damage` — bạn có muốn mình tự add group `surface_flesh` vào `enemy_scene.tscn` không? Hay bạn muốn tự làm thủ công trong editor?

> [!NOTE]
> **Muzzle Flash có OmniLight3D không?** Muzzle flash có thể rất đẹp nếu thêm ánh sáng flash ngắn (~50ms). Tuy nhiên nhiều OmniLight đồng thời có thể ảnh hưởng hiệu năng nếu bắn liên tục. Bạn muốn include hay skip phần light?
