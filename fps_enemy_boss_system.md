# Hệ thống Enemy & Boss — FPS Anime Stylized

> **Góc nhìn:** First-person (FPS) · **Tone:** Anime / stylized, over-the-top  
> **Triết lý thiết kế:** Mọi enemy phải "đọc được" từ góc nhìn 80° FOV. Telegraph bằng âm thanh + visual phía trước — không tấn công bất ngờ từ sau lưng mà không có warning.

---

## Bộ kỹ năng player (9 skill)

| Kỹ năng | Mô tả ngắn |
|---------|-----------|
| Dash | Lao người tức thì theo hướng |
| Sprint | Chạy nhanh liên tục |
| Đu dây | Bắn dây, đu/leo lên cao |
| Wall run | Chạy trên tường thẳng đứng |
| Tạo lực nâng | Nâng và ném vật thể / enemy từ xa |
| Ground Slam | Dậm nhảy từ trên không xuống |
| Trượt | Trượt sát đất né đòn / vượt chướng ngại |
| Súng | Bắn tầm xa|
| Katana | Chém cận chiến|
| Bullet Time / Focus | Làm chậm thời gian| 

---

## Tier 1 — Enemy thường (dạy kỹ năng cơ bản)

### Trảm kích *(Cận chiến)*

Enemy lao thẳng vào mặt player với tốc độ cao. Tay giơ vũ khí nhìn thấy rõ khi charge — đó là telegraph. Không có warning âm thanh trước khi tấn công, chỉ có visual.

**Counter chính:** Dash sang ngang → Katana vào lưng, hoặc Trượt dưới chân → đứng dậy đánh.  
**Skill cốt lõi:** Dash · Katana · Trượt  
**FPS note:** Khi Trảm Kích lao vào, cả FOV bị lấp bởi thân hình nó — instinct né là cực kỳ tự nhiên.

---

### Tay súng nhảy *(Tầm xa)*

Nhảy liên tục khi bắn — đầu bobbing làm khó aim bình thường. Luôn cố giữ khoảng cách với player.

**Counter chính:** Wall run để tiếp cận nhanh từ sườn, hoặc Focus để slow-aim headshot.  
**Skill cốt lõi:** Súng · Wall run · Focus  
**FPS note:** Đứng yên bắn không hiệu quả — phải di chuyển liên tục, đây là bài học movement FPS cơ bản.

---

### Khiên đứng *(Phòng thủ)*

Lấp đầy hành lang, tiến từ từ, không thể bắn xuyên khiên từ phía trước.

**Counter chính:** Đu dây lên trần vượt qua → Ground Slam từ trên xuống đỉnh đầu, hoặc Tạo lực nâng nhấc khiên đi.  
**Skill cốt lõi:** Đu dây · Ground Slam · Tạo lực nâng  
**FPS note:** Cú Ground Slam từ trên xuống trong FPS = cinematic moment nhất tier 1.

---

## Tier 2 — Enemy đặc biệt (yêu cầu phối hợp 2+ skill)

### Trùm tường *(Lập thể)*

Bò trên tường và trần nhà. Trong FPS, nhìn lên thấy nó đang bò xuống tạo cảm giác bị săn đuổi. Tấn công từ góc kỳ lạ, khó predict.

**Counter chính:** Wall run để đưa mình vào cùng mặt phẳng chiến đấu → Súng ở tầm gần, hoặc Đu dây lên tiếp cận trực tiếp.  
**Skill cốt lõi:** Wall run · Đu dây · Súng  
**FPS note:** Camera nhìn lên khi bắn trần nhà = cảm giác vulnerable cực mạnh — đây là áp lực tâm lý chủ ý.

---

### Phù thủy trọng lực *(Kiểm soát)*

Kéo vật thể và đôi khi cả player bay về phía nó. Trong FPS, vật thể bay xuyên FOV tạo cảm giác hỗn loạn thực sự.

**Counter chính:** Tạo lực nâng bắt vật thể đang bay → ném ngược lại vào nó, hoặc Dash ra khỏi vùng hút → Súng.  
**Skill cốt lõi:** Tạo lực nâng · Dash · Súng  
**FPS note:** "Ném lại" bằng Tạo lực nâng trong FPS là một trong những moment cảm giác ngầu nhất — momentum của vật thể từ nó quay lại hạ nó.

---

### Bóng ma nhân bản *(Ảo giác)*

Tạo 2 bản sao di chuyển cùng pattern. Katana xuyên qua bản sao, không xuyên bản thật. Trong FPS bị tấn công từ clone không thấy rất nguy hiểm.

**Counter chính:** Kích hoạt Focus → bản sao mờ dần, bản thật hiện rõ → Katana.  
**Skill cốt lõi:** Focus · Katana · Sprint  
**FPS note:** Âm thanh bước chân của clone và bản thật khác nhau — cần sound design hỗ trợ mechanic này. Tai nghe là lợi thế.

---

## Tier 3 — Elite / Mini-boss (encounter dừng lại chiến đấu)

### Kiếm sĩ gương *(Elite)*

Phản lại mọi đòn bằng đòn tương tự — bắn súng thì nó bắn lại, katana thì nó katana. Không thể spam một skill. Trong FPS, thấy tay mình vung katana và ngay lập tức thấy kiếm nó phản lại = căng thẳng tối đa.

**Counter chính:** Đổi skill liên tục mỗi 2 hit — không để nó "học" pattern. Focus để nhìn thấy animation phản công sớm hơn 0.3s.  
**Skill cốt lõi:** Tất cả skill · Focus · Đổi skill liên tục  
**Thiết kế đặc biệt:** Nếu player dùng cùng 1 skill 3 lần, Kiếm Sĩ Gương tạo phản công đặc biệt của skill đó với damage x2.

---

### Mech săn mồi *(Elite)*

Mech 4 chân với laser tracking đầu. Tia laser đỏ quét qua FOV = instinct né tức thì. Giáp cực dày ở mặt trước và hai bên.

**Counter chính:** Ground Slam qua đầu nó → thấy ống dẫn nhiên liệu ở lưng (điểm yếu duy nhất) → Súng hoặc Katana vào điểm đó.  
**Skill cốt lõi:** Ground Slam · Wall run · Đu dây  
**FPS note:** Phải ở phía sau nó để thấy điểm yếu — mechanic ép player tư duy vị trí 3D.

---

## Boss 1 — Kensei "Kiếm Không Thân"

> **Dạy:** Katana rhythm · Dash timing · Focus · Sprint  
> **FPS hook:** Bộ giáp rỗng bay lơ lửng — camera nhìn lên thấy nó "nhìn xuống" player tạo áp lực tâm lý. Kiếm dài 3m nhìn thấy trong FOV từ 10m.

### Phase 1 — Duel khoảng cách (HP 100% → 65%)

Tấn công 3-hit từ xa, kiếm "vươn dài" siêu thực. Luôn có **parry window 0.25s** khi kiếm cắm đất sau combo.

- Parry đúng → Kensei bị stun 1.5s, nhận damage x3
- Sai parry → bị slam vào tường gần nhất, choáng 0.5s
- **Cách đọc telegraph:** Kiếm phát sáng nhẹ trước 0.3s khi bắt đầu vươn ra

### Phase 2 — Teleport blitz (HP 65% → 30%)

Biến mất và tái xuất ngay trong FOV cực gần (~2m trước mặt). Âm thanh "xoáy không khí" telegraph 0.4s trước khi xuất hiện.

- Nghe âm thanh → Dash sang ngang ngay lập tức
- Đứng yên khi nó xuất hiện = nhận full combo không thể né
- **Cách đọc:** Vệt không khí méo dạng nhỏ xuất hiện 0.4s trước khi nó teleport đến vị trí đó

### Phase 3 — Tách thành 5 mảnh (HP 30% → 0%)

Giáp phân rã thành 5 mảnh tự hành di chuyển độc lập. Chỉ mảnh chứa lõi mới nhận damage thực.

- **Bình thường:** 5 mảnh trông giống nhau, tấn công ngẫu nhiên
- **Khi dùng Focus:** Slow-mo + mảnh chứa lõi phát sáng yếu
- Không dùng Focus trong phase này = gần như không thắng được
- **Đây là "aha moment" bắt buộc:** Player phải tự khám phá rằng Focus là chìa khóa

---

## Boss 2 — Valkyrie "Thần Chiến Cơ Học"

> **Dạy:** Ground Slam · Đu dây · Tạo lực nâng · Súng tầm xa  
> **FPS hook:** Khổng lồ — khi nhìn thẳng vào mặt nó, FOV bị lấp ~60%. Cảm giác "nhỏ bé" trong FPS mạnh hơn third-person rất nhiều. Camera rung khi nó bước = feedback vật lý.

### Phase 1 — Shockwave mặt đất (HP 100% → 60%)

Giậm chân tạo sóng chấn lan rộng hình vòng. Trong FPS: mặt đất nứt tiến về phía mình = cực kỳ cinematic.

- Counter: Trượt, nhảy, hoặc chạy lên tường gần đó
- Điểm yếu: khớp gối bị lộ 1.5s sau mỗi Stomp
- **Cách gây damage:** Đu dây lên cao → Ground Slam xuống đúng khớp gối = damage lớn + interrupt stomp tiếp theo

### Phase 2 — Bay và bắn phá (HP 60% → 25%)

Valkyrie cất cánh, bắn missile tracking từ trên. Trong FPS: nhìn xuống từ trên cao thấy Valkyrie = đảo ngược power dynamic hoàn toàn.

- Phải Đu dây lên các cột/sàn trên cao trong arena
- Từ trên cao: bắn vào bộ phận phản lực ở vai (điểm yếu)
- Missile tracking: Dash + đổi hướng liên tục để phá lock-on
- **Arena design cần có:** Ít nhất 3-4 điểm neo Đu dây ở độ cao 8-12m

### Phase 3 — Magnetic core (HP 25% → 0%)

Lõi từ tính kích hoạt, kéo mọi vật thể (và bộ phận súng/tay của player trên màn hình) về phía nó.

- Cảm giác tay/súng mình "bị hút" qua hand model animation
- Mảnh vỡ từ phase 1-2 còn rơi vãi trong arena
- **Cách thắng:** Tạo lực nâng nhặt mảnh vỡ → ném vào lõi trong khi đang cưỡng lại lực hút
- Hai lực đối kháng nhau = feedback vật lý độc đáo nhất game

---

## Boss cuối — SIGMA "Tổng Hợp Tuyệt Đối"

> **Kiểm tra:** Toàn bộ 9 kỹ năng — không có pattern cố định  
> **FPS hook:** Hình dạng thay đổi theo phase — phase 1 là humanoid (mắt nhìn ngang tầm), phase 2 siêu lớn (camera nhìn lên), phase 3 là khắp nơi (không có điểm nhìn rõ). Góc nhìn FPS làm 3 phase này cảm giác như 3 boss khác nhau hoàn toàn.

### Phase 1 — Sao chép (HP 100% → 65%)

SIGMA theo dõi và copy skill player dùng nhiều nhất, rồi phản lại bằng chính skill đó.

- **Penalty system:** Dùng cùng 1 skill 3 lần liên tiếp → SIGMA counter với skill đó ở damage x2
- Buộc player rotate toàn bộ kit liên tục
- **Cách đọc:** SIGMA "flash" màu của skill nó sắp copy trong 0.5s trước khi phản lại
- **Mục tiêu thiết kế:** Player phải vừa chiến đấu, vừa track xem mình đã dùng skill gì

### Phase 2 — Biến đổi arena (HP 65% → 30%)

Arena thay đổi layout mỗi 20 giây, mỗi layout ép dùng skill khác nhau:

| Layout | Đặc điểm | Skill bắt buộc |
|--------|----------|----------------|
| Hành lang hẹp | Không có chỗ wall run | Trượt · Dash · Katana |
| Không gian mở | Khoảng trống lớn, nhiều tầng | Đu dây · Ground Slam · Súng |
| Mê cung | Tường cao dày đặc | Wall run · Sprint · Tạo lực nâng |

SIGMA di chuyển theo layout, luôn ở vị trí yêu cầu player dùng đúng skill của layout đó.

### Phase 3 — Khắp nơi cùng lúc (HP 30% → 0%)

SIGMA phân tán thành nhiều điểm tấn công đồng thời từ mọi hướng. Không có "cơ thể" duy nhất.

- Âm thanh định hướng là tất cả — tiếng footstep, charge, whoosh từ hướng tấn công tiếp theo
- Focus + Katana + Súng phải dùng liên tiếp theo điểm tấn công
- Không có pattern cố định để học thuộc — phải đọc real-time
- **Điều kiện thắng:** Phá hủy đồng thời 3+ điểm tấn công trong 2s bằng skill khác nhau

---

## Ma trận kỹ năng

| Enemy / Boss | Dash | Wall run | Đu dây | Nâng | Slam | Trượt | Súng | Katana | Focus |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Trảm kích | ● | ○ | ○ | ○ | ◐ | ● | ◐ | ● | ○ |
| Tay súng nhảy | ○ | ● | ○ | ○ | ○ | ○ | ● | ○ | ● |
| Khiên đứng | ○ | ○ | ● | ● | ● | ○ | ○ | ○ | ○ |
| Trùm tường | ○ | ● | ● | ○ | ○ | ○ | ● | ◐ | ○ |
| Phù thủy trọng lực | ● | ○ | ○ | ● | ○ | ○ | ● | ○ | ◐ |
| Bóng ma nhân bản | ◐ | ○ | ○ | ○ | ○ | ○ | ○ | ● | ● |
| Kiếm sĩ gương (Elite) | ● | ◐ | ○ | ◐ | ◐ | ◐ | ◐ | ● | ● |
| Mech săn mồi (Elite) | ◐ | ● | ● | ○ | ● | ○ | ● | ◐ | ○ |
| **Kensei (Boss 1)** | ● | ○ | ○ | ○ | ○ | ◐ | ◐ | ● | ● |
| **Valkyrie (Boss 2)** | ○ | ○ | ● | ● | ● | ◐ | ● | ○ | ○ |
| **SIGMA (Boss cuối)** | ● | ● | ● | ● | ● | ● | ● | ● | ● |

> ● Cốt lõi — không có không thắng &nbsp;|&nbsp; ◐ Hữu ích — dùng được &nbsp;|&nbsp; ○ Không cần thiết

---

## Đường cong progression

```
Đầu game          Giữa game           Gần cuối          Cuối game
    │                  │                   │                 │
Tier 1 enemy  →  Tier 2 + Boss 1  →  Tier 3 + Boss 2  →  SIGMA
(học từng skill)  (phối hợp skill)   (master skill)     (toàn bộ)
```

Mỗi enemy tier và boss được đặt ở thời điểm player vừa được dạy đủ skill để counter — không quá sớm (frustrating), không quá muộn (trivial).

---

## Yêu cầu thiết kế màn chơi (Arena Design)

Để hệ thống hoạt động, môi trường phải hỗ trợ:

- **Wall run:** Tường liên tục đủ dài để chạy ít nhất 3-4 bước (tối thiểu 6m)
- **Đu dây:** Điểm neo ở độ cao 6-12m, phân bố đều trong arena
- **Ground Slam:** Độ cao tối thiểu 5 đơn vị để trigger animation đầy đủ
- **Tạo lực nâng:** Vật thể tương tác được (thùng, xe, trụ kim loại) rải khắp arena
- **FPS sightline:** Không có góc khuất hoàn toàn — enemy luôn telegraph trong tầm nhìn 80° FOV trước khi tấn công

---

## Combo kỹ năng "Anime moment"

Những combo này nên được game reward bằng camera effect / slowmo nhỏ:

| Tên combo | Chuỗi kỹ năng | Effect |
|-----------|---------------|--------|
| Aerial execution | Đu dây → Ground Slam trên đầu → Katana finish | Camera slowmo 0.3s lúc Katana |
| Gravity juggle | Tạo lực nâng nâng enemy → Súng liên tục → Slam khi rơi | Particle burst khi Slam |
| Wall chain | Wall run → Đu dây sang tường khác → Dash vào + Katana | Screen flash trắng khi Katana hit |
| Focus snipe | Focus → aim headshot → release = bullet time kết thúc | Thời gian đóng băng 0.1s khi trúng |
