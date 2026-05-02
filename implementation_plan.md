# MASTER PLAN: HỆ THỐNG BẮN SÚNG TOÀN DIỆN

Kế hoạch này tổng hợp toàn bộ kiến trúc chúng ta đã thống nhất: **Hitscan tối ưu hiệu suất**, **Weapon Manager điều phối**, **State Machine cho logic súng**, và **Procedural Sway để xử lý mượt mà animation đi bộ**.

---

## KIẾN TRÚC TỔNG QUAN

Hệ thống được chia làm 3 khối hoạt động ĐỘC LẬP:

1. **Khối Điều Phối (Weapon Manager & Raycast):** Chỉ lo nhận input, kiểm tra điều kiện (cooldown, đạn), lấy điểm ngắm từ Camera và phát lệnh.
2. **Khối Logic Súng (Weapon State Machine):** Chỉ lo trạng thái hành động (`Idle`, `Fire`, `Reload`). Không quan tâm nhân vật đang đứng hay đi.
3. **Khối Locomotion (Sway & Bobbing):** Chạy liên tục bằng code thuần, tự động lắc lư súng dựa theo tốc độ di chuyển của người chơi.

---

## CHI TIẾT CÁC BƯỚC THỰC HIỆN

### PHẦN 1: THIẾT LẬP RAYCAST TỪ CAMERA
**[NEW] `addons/PlayerCharacter/Camera/camera_raycasts.gd`**
- Tạo script này và gắn vào node `CameraBasedRaycasts` có sẵn của bạn.
- Thêm node `AimRay` (RayCast3D, Z: -100) làm con.
- Script có hàm `get_hit_result() -> Dictionary` trả về `{hit, collider, point, normal}`.

### PHẦN 2: CHUYỂN ĐỔI WEAPON MANAGER
**[MODIFY] `addons/PlayerCharacter/Weapon_Manager.gd`**
- Thêm tham chiếu đến `camera_raycasts`.
- Hàm `attack()`: check cooldown -> check đạn -> lấy `hit_result` -> gọi `current_weapon.weapon_state_machine.send_action("fire")`.
- Hàm `reload_current_weapon()`: gọi `current_weapon.weapon_state_machine.send_action("reload")`.

### PHẦN 3: XÂY DỰNG WEAPON STATE MACHINE (Logic Súng)
**[NEW] `Weapons/StateMachine/weapon_state_machine.gd`**
- Quản lý chuyển đổi giữa các State, có hàm `send_action(action: String)`.

**[NEW] `Weapons/StateMachine/weapon_state.gd`** (Base class)
- Các hàm virtual: `enter()`, `update()`, `exit()`, `handle_input()`.

**[NEW] `Weapons/StateMachine/weapon_idle_state.gd`**
- Chờ tín hiệu "fire" hoặc "reload". Nếu có, chuyển sang state tương ứng.

**[NEW] `Weapons/StateMachine/weapon_fire_state.gd`**
- Vào state -> Gọi `weapon.fire_weapon(hit_result)` -> Bắt đầu đếm thời gian (cooldown) -> Đủ cooldown tự về `Idle`.

**[NEW] `Weapons/StateMachine/weapon_reload_state.gd`**
- Đếm thời gian dựa theo `reload_time` -> Hết thời gian gọi `weapon.perform_reload_logic()` -> Về `Idle`.

### PHẦN 4: WEAPON EQUIPPED & CÁC LAYER (Thực thi)
**[MODIFY] `Weapons/Equip/WeaponEquipped.gd`**
- Chứa các hàm thực thi được gọi bởi Fire State:
  - `apply_gameplay_layer()`: Trừ máu, Apply Impulse.
  - `apply_vfx_layer()`: Gọi Tracer bay, dán Decal lỗ đạn, Muzzle Flash.
  - `apply_feedback_layer()`: Báo cho Camera giật lùi (Recoil).

**[NEW] `Weapons/Effects/BulletTracer.gd` & `.tscn`**
- Mesh nhỏ màu vàng, bay từ `MuzzlePoint` tới `hit_point` bằng Tween rồi tự xóa.

**[NEW] `Weapons/Effects/BulletDecal.gd` & `.tscn`**
- Dán texture lỗ đạn, tự xóa sau 5 giây.

### PHẦN 5: XỬ LÝ LẮC LƯ SÚNG (Sway & Bobbing)
**[NEW] `Weapons/Equip/weapon_sway.gd`**
- Gắn script này vào Node chứa Model 3D của khẩu súng (Bên trong `RevolverEquipped`).
- Đọc `velocity` của Player.
- Dùng `sin()` và `cos()` tác động nhẹ lên `position` và `rotation` của Model súng mỗi khung hình (`_process`).
- **Lưu ý:** Hàm `bob()` ở `camera_script.gd` hiện tại của bạn đang lắc cả Camera. Bạn có thể giữ lại lắc nhẹ Camera, và dùng script này để súng lắc mạnh hơn/trễ hơn một chút để tạo cảm giác nặng.

---

## CẤU TRÚC SCENE HOÀN CHỈNH CHO MỘT KHẨU SÚNG

Ví dụ với `RevolverEquipped.tscn`:

```text
RevolverEquipped (Node3D) -> WeaponEquipped.gd
  │
  ├── Model_Holder (Node3D) -> weapon_sway.gd (Script lo lắc lư súng khi đi)
  │     └── Pistol_Mesh (MeshInstance3D)
  │
  ├── MuzzlePoint (Marker3D)
  │
  └── WeaponStateMachine (Node) -> weapon_state_machine.gd (Quản lý logic)
        ├── Idle -> weapon_idle_state.gd
        ├── Fire -> weapon_fire_state.gd
        └── Reload -> weapon_reload_state.gd
```

---

## CÁC BƯỚC TRONG EDITOR CẦN LÀM:

1. Chỉnh sửa `WeaponData` resource: thêm thông số `fire_rate`.
2. Tạo 2 scene hiệu ứng `BulletTracer` và `BulletDecal`.
3. Xây dựng lại cây Scene cho `RevolverEquipped` như cấu trúc ở trên.
4. Kéo thả các tham chiếu (node paths) trong Inspector cho chuẩn xác (đưa MuzzlePoint, TracerScene, DecalScene vào WeaponEquipped; đưa CameraRaycasts vào WeaponManager).

> [!TIP]
> Bằng cách chia nhỏ như thế này, súng sẽ đung đưa cực kỳ mượt mà khi di chuyển (nhờ `weapon_sway.gd`), nhưng khi bạn bấm bắn thì logic (trừ đạn, cooldown) vẫn được `WeaponStateMachine` quản lý tuyệt đối chính xác mà không xảy ra xung đột animation!
