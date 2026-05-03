shader_type canvas_item;

// Biến điều khiển độ sâu (khoảng cách) mà màu đỏ lan xuống từ phía trên
// Giá trị càng lớn, màu đỏ càng lan xuống thấp
uniform float fade_depth : hint_range(0.0, 1.0) = 0.4; 

void fragment() {
    // Lấy màu hiện tại của ColorRect (Modulate)
    COLOR = COLOR;
    
    // UV.y chạy từ 0.0 (đỉnh) đến 1.0 (đáy).
    // Chúng ta không dùng UV.x nên hiệu ứng sẽ trải dài toàn bộ chiều ngang.
    float dist = UV.y; 

    // smoothstep(độ_sâu, 0.0, khoảng_cách_hiện_tại)
    // Nó tạo ra gradient từ trong suốt (ở dưới) sang đậm (ở trên cùng).
    float mask = smoothstep(fade_depth, 0.0, dist);
    
    // Áp dụng mask vào kênh alpha
    COLOR.a *= mask;
}