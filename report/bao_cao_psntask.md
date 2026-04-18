# BÁO CÁO MÔN HỌC: KỸ THUẬT PHẦN MỀM ỨNG DỤNG

**Đề tài:** Xây dựng Ứng dụng Mobile Quản lý Công việc Cá nhân theo mô hình Kanban (*Personal Task Kanban*)

---

## I. THÔNG TIN SINH VIÊN THỰC HIỆN

| Họ tên | Mã SV / Lớp | Email | Vai trò |
|---|---|---|---|
| Ngô Thu Hương | 22A1701D0110 | ngothekhuyen205@gmail.com | Thực hiện toàn bộ đề tài (Thiết kế – Lập trình – Kiểm thử – Báo cáo) |

---

## II. GIỚI THIỆU VÀ PHÂN TÍCH YÊU CẦU BÀI TOÁN

### 1. Mục tiêu
Xây dựng một ứng dụng **Mobile đa nền tảng (Android/iOS)** cho phép người dùng cá nhân quản lý công việc theo mô hình **Kanban** (Cần làm → Đang làm → Hoàn thành), lưu trữ dữ liệu **bền vững trên Cloud** với khả năng **đồng bộ thời gian thực** giữa nhiều thiết bị và **hoạt động ngoại tuyến** khi chưa đăng nhập.

### 2. Công nghệ sử dụng

Ứng dụng được viết bằng **Flutter 3.x** (Dart SDK ^3.11.4) để có thể build cùng một codebase chạy được trên Android, iOS, Web và cả desktop. Quản lý trạng thái dùng **Riverpod 3.x**, lưu dữ liệu cloud qua **Supabase** (PostgreSQL + Realtime + Auth), còn dữ liệu cục bộ ở chế độ khách thì lưu qua `shared_preferences`.

Phần xác thực kết hợp Supabase Auth (Email/Password) với `google_sign_in` và OAuth deep link mở trong Chrome Custom Tab. Khóa Supabase được tách ra file `.env` qua `flutter_dotenv` để không commit lên Git. Giao diện dùng Material 3 tùy biến cộng với hệ thống component **Liquid Glass** (BackdropFilter + mesh gradient) lấy cảm hứng từ visionOS và bộ mock "Aéro Vitrum".

Quy trình làm việc theo Agile cá nhân, chia thành các Sprint ngắn 4–5 ngày. Công cụ hỗ trợ gồm Visual Studio Code, Android Studio, Supabase Studio, Git và các trợ lý AI (Google AI Studio, Claude, Anthropic Stitch) đóng vai trò "pair programmer" theo phương pháp Vibe Coding.

### 3. Phương pháp tiếp cận (Vibe Coding)

Trong dự án này, AI không thay thế lập trình viên mà đóng vai trò trợ lý: sinh khung sườn code (boilerplate Flutter, Riverpod provider, repository pattern), đề xuất schema PostgreSQL kèm Row Level Security, refactor theo Clean Architecture, hỗ trợ debug các lỗi khó như deep link OAuth hay stream Supabase, và sinh giao diện kính mờ từ mô tả tự nhiên + ảnh tham chiếu.

Phương châm khi làm việc với AI là **đọc hiểu từng dòng code trước khi nhận**: mỗi đoạn code được sinh ra đều được rà lại logic, đối chiếu với yêu cầu đề bài và tự kiểm thử trên thiết bị thật. Điều này giúp giữ được khả năng giải thích và chỉnh sửa độc lập, tránh phụ thuộc vào AI khi xảy ra lỗi ngoài kịch bản.

---

## III. MÔ TẢ QUÁ TRÌNH PHÁT TRIỂN VÀ THIẾT KẾ

### 1. Quy trình phát triển (Agile — cá nhân)

Dự án chia thành 4 Sprint ngắn, mỗi Sprint khoảng 4–5 ngày, làm xong gốc trước rồi mới tinh chỉnh hình thức.

**Sprint 1 — Khởi tạo và bản chạy được không cần mạng.** Bước đầu thiết lập dự án Flutter đa nền tảng, dựng `TaskModel` cơ bản (title, description, status, priority, createdAt) và viết `LocalTaskRepository` lưu qua `SharedPreferences`. Giao diện Kanban 3 tab Cần làm / Đang làm / Hoàn thành được dựng trước để có thể demo logic ngay mà chưa cần backend.

**Sprint 2 — Tích hợp Supabase.** Tạo project Supabase, thiết kế bảng `tasks` trên PostgreSQL kèm Row Level Security cô lập dữ liệu theo `user_id`. Viết `SupabaseTaskRepository` thực hiện CRUD và đặc biệt là stream realtime qua `supabase.from('tasks').stream()`. Triển khai xác thực Email/Password cùng Google OAuth với deep link `com.psntask.psntask://login-callback/` mở trong Chrome Custom Tab. Đồng thời xây `AppState` quản lý 3 trạng thái phiên (`none` / `cloud` / `guest`) và `taskRepositoryProvider` tự chọn kho dữ liệu phù hợp.

**Sprint 3 — Hoàn thiện CRUD và bộ lọc.** Bổ sung sửa task (bấm vào card mở lại bottom sheet để sửa toàn bộ trường), confirm dialog trước khi xóa và trước khi đăng xuất, cùng SnackBar floating phản hồi mọi thao tác (đỏ khi lỗi). Thêm tìm kiếm theo tên và lọc theo độ ưu tiên bằng chip; thêm date picker chọn hạn hoàn thành trong sheet. Cuối Sprint, tách Supabase URL và anon key ra file `.env` (đã `.gitignore`), bổ sung `.env.example` để dễ chia sẻ.

**Sprint 4 — Liquid Glass và tính năng nâng cao.** Thiết kế lại toàn bộ giao diện theo phong cách "Fluid Luminary" lấy cảm hứng từ bộ mock Aéro Vitrum, xây hệ thống component dùng chung gồm `GlassContainer`, `GlassButton`, `GlassBackground` với 4 quả cầu radial gradient ở 4 góc và hiệu ứng `BackdropFilter` blur 20–30 px. Cấu trúc shell được tách thành 3 tab điều hướng bởi thanh Bottom Navigation pill nổi (`GlassBottomNav`): Bảng (Kanban), Hoạt động (`StatsScreen`) và Hồ sơ (`ProfileScreen`). Sprint này cũng thêm các tính năng được đánh giá có giá trị nhất với người dùng cuối: kéo-thả giữa các cột (`LongPressDraggable` + `DragTarget` trên tab header), trường `due_date` với badge thông minh phân tầng theo mức khẩn, menu sắp xếp trong cột với 4 lựa chọn, vòng tròn tiến độ tự vẽ bằng `CustomPaint` ở trang Hoạt động và trang Hồ sơ với avatar gradient cùng nút đăng xuất có xác nhận.

### 2. Thiết kế hệ thống (Clean Architecture + Feature-first)

Thư mục `lib/` được tổ chức như sau:

```
lib/
├── main.dart                                   ← Entry point + AuthWrapper + SystemUiOverlayStyle
├── core/
│   ├── app_state.dart                          ← Singleton ChangeNotifier — SessionType: none/cloud/guest
│   ├── constants/supabase_constants.dart       ← Đọc URL/anon key từ .env qua flutter_dotenv
│   ├── theme/app_theme.dart                    ← Material 3 tùy biến — palette "Fluid Luminary"
│   └── widgets/
│       ├── glass.dart                          ← GlassPalette, GlassContainer, GlassButton, GlassBackground
│       └── glass_bottom_nav.dart               ← Bottom nav kiểu pill nổi với active item gradient
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── login_screen.dart               ← Google / Email / Guest
    │       └── email_auth_screen.dart          ← TabBar đăng nhập / đăng ký, validation form
    ├── kanban/
    │   ├── domain/models/task_model.dart       ← TaskModel (id, title, desc, status, priority, createdAt, dueDate)
    │   ├── data/
    │   │   ├── task_repository.dart            ← Abstract TaskRepository + SupabaseTaskRepository
    │   │   └── local_task_repository.dart      ← LocalTaskRepository singleton (SharedPreferences)
    │   └── presentation/
    │       ├── kanban_board_screen.dart        ← Màn Kanban (3 tab + drag-drop + sort + filter)
    │       └── providers/task_provider.dart    ← taskRepositoryProvider + tasksStreamProvider
    ├── shell/
    │   └── main_shell.dart                     ← Stack: IndexedStack(3 trang) + GlassBottomNav nổi
    ├── stats/
    │   └── stats_screen.dart                   ← Ring progress + stat cards + priority breakdown
    └── profile/
        └── profile_screen.dart                 ← Avatar, mode badge, account info, đăng xuất
```

Điểm cần lưu ý về kiến trúc: lớp `TaskRepository` là interface chung, hai cài đặt `SupabaseTaskRepository` và `LocalTaskRepository` được chọn động trong `taskRepositoryProvider` dựa trên `AppState.instance.type`, nên tầng UI hoàn toàn không biết dữ liệu đang đến từ cloud hay từ máy. `tasksStreamProvider` là `StreamProvider.autoDispose`, do đó mỗi khi dữ liệu thay đổi (cả ở Supabase Realtime lẫn trong `StreamController` của bản local) thì giao diện tự cập nhật ngay. Shell dùng `IndexedStack` để 3 tab giữ nguyên state khi chuyển — quay lại Kanban không phải tải lại stream từ đầu.

Về bảo mật, ứng dụng chia làm hai lớp: ở client thì khóa Supabase được đọc qua `dotenv` từ file `.env` (đã đưa vào `.gitignore`), còn ở server thì mọi truy cập bảng `tasks` đều phải đi qua Row Level Security với điều kiện `auth.uid() = user_id`. Người chưa đăng nhập không đọc được dữ liệu nào, người đã đăng nhập chỉ thấy task của chính mình.

### 3. Thiết kế Cơ sở dữ liệu (Supabase / PostgreSQL)

#### Migration ban đầu
File: `supabase/migrations/20260416000000_create_tasks_table.sql`

```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) DEFAULT auth.uid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'todo',     -- 'todo' | 'doing' | 'done'
    priority TEXT NOT NULL DEFAULT 'medium'  -- 'low'  | 'medium'| 'high'
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User xem task của chính họ"
  ON tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "User tạo task của chính họ"
  ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "User cập nhật task của chính họ"
  ON tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "User xóa task của chính họ"
  ON tasks FOR DELETE USING (auth.uid() = user_id);

ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
```

#### Migration bổ sung — Hạn hoàn thành
File: `supabase/migrations/20260418000000_add_due_date.sql`

```sql
ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS due_date TIMESTAMPTZ NULL;
```

Có **4 chính sách RLS** đảm bảo an toàn dữ liệu giữa các người dùng và bật **Realtime** để client nhận thay đổi qua WebSocket.

### 4. Quản lý công việc

Do làm cá nhân nên không sử dụng công cụ quản lý dự án nhóm. Công việc được quản lý bằng:
- **Danh sách TODO** trực tiếp trong IDE.
- **Git commit** chia nhỏ theo từng tính năng để dễ quay lui khi có lỗi.
- **Ghi chú nhật ký Sprint** ngắn gọn sau mỗi ngày làm việc.

---

## IV. CÁC CHỨC NĂNG ĐÃ TRIỂN KHAI

### 1. Đăng nhập đa phương thức

Người dùng có ba lựa chọn để bắt đầu sử dụng. Lựa chọn thứ nhất là đăng nhập bằng Google qua Supabase OAuth — luồng này được thiết kế "in-app" bằng cách mở Chrome Custom Tab (`LaunchMode.inAppBrowserView`) thay vì WebView, vừa được Google cho phép vừa cho cảm giác mượt như các app hiện đại. Sau khi xác thực xong, Supabase redirect về deep link `com.psntask.psntask://login-callback/` đã đăng ký trong `AndroidManifest.xml`.

Lựa chọn thứ hai là đăng ký hoặc đăng nhập bằng email và mật khẩu. Form có validation nhẹ (định dạng email và mật khẩu tối thiểu 6 ký tự), nút mắt để hiện/ẩn mật khẩu. Lựa chọn thứ ba là chế độ khách: bỏ qua đăng nhập và lưu task trực tiếp lên `SharedPreferences` của máy. Phiên đăng nhập được duy trì giữa các lần mở app, và mọi thay đổi trạng thái đều được lắng nghe qua `Supabase.auth.onAuthStateChange`, nên việc chuyển giữa các màn hình diễn ra hoàn toàn tự động.

### 2. Bảng Kanban và quản lý Task

Bảng chính gồm 3 tab Cần làm / Đang làm / Hoàn thành; mỗi cột là một `ListView` cuộn độc lập với các card kính mờ. Mỗi card hiển thị pill độ ưu tiên (THẤP/VỪA/CAO), tên công việc, mô tả tối đa 3 dòng, badge hạn (nếu có) và một dải màu 4 px bên trái theo độ ưu tiên.

Tất cả các thao tác CRUD đều được hỗ trợ: thêm mới qua bottom sheet kính mờ (nhập tên, mô tả, độ ưu tiên, hạn), đọc realtime qua `tasksStreamProvider`, sửa bằng cách bấm vào card (sheet mở lại với dữ liệu cũ, sửa được mọi trường), xóa với hộp thoại xác nhận kèm tên task để tránh xóa nhầm. Chuyển trạng thái có thể làm theo hai cách: mở action sheet để chọn cột mới, hoặc kéo-thả thẳng. Mọi thao tác đều có SnackBar floating phản hồi, hiển thị màu đỏ khi gặp lỗi mạng hoặc server.

### 3. Kéo-thả giữa các cột

Để chuyển status nhanh, người dùng có thể long-press một card khoảng 280 ms — máy rung nhẹ và card "lift up" để báo hiệu đã vào chế độ kéo. Khi đang kéo, một card "ma" hiện ra dưới ngón tay, xoay nhẹ và đổ bóng theo màu độ ưu tiên. Ba tab header trên cùng đồng thời trở thành drop target: tab nào được hover sẽ sáng viền xanh chủ đạo. Thả tay vào tab khác sẽ cập nhật `status`, tự chuyển tab và hiện SnackBar xác nhận; thả vào cùng cột thì bị chặn ngay từ `onWillAcceptWithDetails`.

### 4. Hạn hoàn thành (Due date)

Mỗi task có thể được gán một hạn hoàn thành tùy chọn qua date picker Material 3 (đã việt hóa). Trên card, hạn được hiển thị bằng badge thông minh phân tầng theo mức khẩn: đỏ khi đã quá hạn, cam cho hôm nay hoặc ngày mai, xanh dương cho khoảng còn dưới 7 ngày, xám cho ngày xa hơn, và gạch ngang khi task đã hoàn thành. Cách phối màu này cho phép người dùng nhận diện việc gấp chỉ trong một cái liếc.

### 5. Tìm kiếm, Lọc và Sắp xếp

Phía trên bảng Kanban có một thanh tìm kiếm theo tên công việc (lọc ngay khi gõ, không phân biệt hoa thường) và một dải chip lọc theo độ ưu tiên (Tất cả / THẤP / VỪA / CAO). Hai bộ lọc kết hợp được với nhau; nếu không tìm thấy, ứng dụng hiển thị thông báo "Không có việc nào khớp bộ lọc" thay vì bảng rỗng vô nghĩa.

Bên cạnh đó, một nút sắp xếp trên header mở ra menu 4 chế độ — Mới nhất trước (mặc định), Cũ nhất trước, Theo độ ưu tiên (Cao → Vừa → Thấp), và Theo hạn (gần nhất trước, task không có hạn xuống cuối). Lựa chọn áp dụng đồng thời cho cả 3 cột.

### 6. Đồng bộ Realtime

Khi đăng nhập cloud, dữ liệu được kéo về qua `supabase.from('tasks').stream()` và cập nhật ngay khi có thay đổi: mở app trên hai thiết bị, thêm task ở thiết bị A thì thiết bị B nhận trong vài trăm milisecond mà không cần làm mới. Ở chế độ khách, một `StreamController.broadcast()` nội bộ giữ vai trò tương tự để UI vẫn cập nhật reactive khi dữ liệu local đổi.

### 7. Trang Hoạt động (Stats)

Trang Hoạt động cung cấp một cái nhìn tổng quát về tiến độ. Trung tâm là một vòng tròn tiến độ vẽ tay bằng `CustomPaint` (gradient từ primary đến primaryContainer) với phần trăm hoàn thành lớn ở giữa. Bên dưới là 4 ô thống kê (Hoàn thành, Đang làm, Cần làm, Tổng) sắp xếp 2×2 với màu phân biệt; cuối trang là biểu đồ phân bổ theo độ ưu tiên dùng `LinearProgressIndicator` để thể hiện tỉ lệ tương đối. Khi chưa có dữ liệu, trang hiển thị empty state với hướng dẫn thay vì ring 0% trống.

### 8. Trang Hồ sơ

Trang Hồ sơ tập trung tất cả thông tin tài khoản và thao tác phiên. Trên cùng là avatar 108×108 px với gradient xanh chủ đạo — chữ cái đầu email cho chế độ Cloud hoặc icon Person cho chế độ Guest. Một badge ngay dưới avatar phân biệt rõ "Đã đồng bộ Cloud" và "Cục bộ — chỉ máy này". Bên dưới chia làm hai khu vực: Tài khoản (phương thức đăng nhập, ngày tạo) và Ứng dụng (giới thiệu app, đăng xuất với confirm dialog).

### 9. Bottom Navigation và giao diện chung

Thanh điều hướng dưới cùng là một pill nổi kính mờ chiếm gần hết chiều rộng, gồm 3 tab Bảng / Hoạt động / Hồ sơ. Tab đang chọn biến thành một nút lớn gradient xanh (icon + label nằm cạnh nhau), các tab còn lại là icon + label xám phía dưới. Vì shell dùng `IndexedStack` nên việc chuyển giữa 3 tab không gây mất state.

Toàn bộ giao diện áp dụng phong cách "Liquid Glass" thống nhất: nền mesh gradient với 4 quả cầu radial mờ ở 4 góc, mọi card / dialog / sheet đều có `BackdropFilter` blur cộng viền trắng mờ và đổ bóng nhẹ. Button chính dùng gradient có glow, button phụ là kính mờ. Status bar được set icon đậm để hợp nền sáng. Toàn bộ chữ là tiếng Việt.

### 10. Đa nền tảng

Cùng một codebase chạy được trên Android, iOS, Web, macOS, Windows và Linux. Deep link OAuth chỉ áp dụng cho Android (đã cấu hình trong `AndroidManifest.xml` với scheme `com.psntask.psntask` host `login-callback`); trên các nền tảng chưa hỗ trợ Google Sign-In, nút Google được tự động ẩn để không gây nhầm lẫn.

---

## V. PHÂN CÔNG CÔNG VIỆC

Đề tài do **một sinh viên thực hiện toàn bộ**:

| Thành viên | Nhiệm vụ chi tiết |
|---|---|
| **Ngô Thu Hương** | – Khởi tạo dự án Flutter đa nền tảng, cấu hình `.env`, Supabase.<br>– Thiết kế cơ sở dữ liệu PostgreSQL, viết 2 file migration SQL kèm Row Level Security.<br>– Lập trình toàn bộ lớp dữ liệu: `TaskModel`, `SupabaseTaskRepository`, `LocalTaskRepository`.<br>– Xây dựng xác thực đa phương thức (Google OAuth Custom Tab, Email/Password, Guest) và `AppState` quản lý phiên.<br>– Thiết kế hệ thống component **Liquid Glass** (`GlassContainer`, `GlassButton`, `GlassBackground`, `GlassBottomNav`).<br>– Lập trình màn hình Kanban đầy đủ CRUD + bộ lọc + tìm kiếm + sắp xếp + kéo-thả.<br>– Lập trình trang **Hoạt động** với CustomPaint vẽ vòng tròn tiến độ + biểu đồ phân bổ.<br>– Lập trình trang **Hồ sơ** với avatar gradient, badge mode và đăng xuất có xác nhận.<br>– Tích hợp Supabase Realtime, xử lý stream broadcast cho cả cloud và local.<br>– Cấu hình deep link Android + Custom Tab.<br>– Kiểm thử thủ công tất cả các luồng, xử lý lỗi nhập liệu, lỗi mạng.<br>– Soạn thảo tài liệu và báo cáo. |

---

## VI. KẾT QUẢ ĐẠT ĐƯỢC VÀ HẠN CHẾ

### 1. Kết quả đạt được

Ứng dụng đã hoàn thành đầy đủ các yêu cầu trong đề bài: đăng nhập bằng Google và Email, Dashboard Kanban, CRUD task, bộ lọc + tìm kiếm, dữ liệu thời gian thực qua Supabase và cấu trúc bảng PostgreSQL đúng đặc tả. Đề bài cho phép chuyển trạng thái bằng kéo-thả hoặc nút bấm; ứng dụng triển khai cả hai để người dùng tự chọn.

Ngoài yêu cầu, một số phần được bổ sung để cho ra một sản phẩm thực sự dùng được chứ không dừng ở mức demo: chế độ khách giúp app vẫn chạy được khi chưa có tài khoản hoặc mất mạng; repository pattern cho phép chuyển nguồn dữ liệu giữa cloud và local mà không ảnh hưởng tầng UI; hạn hoàn thành với badge thông minh phân tầng theo mức khẩn; trang Hoạt động hiển thị tiến độ tổng quát; trang Hồ sơ quản lý phiên; menu sắp xếp với 4 chế độ. Hệ thống component Liquid Glass áp dụng đồng nhất cho toàn app, hoạt ảnh mượt 60 fps trên emulator Android tầm trung.

Về bảo mật, khóa Supabase được tách ra `.env` ở client và Row Level Security canh giữ ở server — kết hợp lại đảm bảo người dùng không thấy được dữ liệu của nhau ngay cả khi có ai đó tự ý gọi API trực tiếp. Phương pháp Vibe Coding giúp rút ngắn thời gian lập trình đáng kể (ước khoảng 2–3 lần), nhưng từng dòng code đều được đọc lại để bảo đảm sinh viên hiểu và có thể giải thích logic khi cần.

### 2. Hạn chế còn tồn tại

Ứng dụng chưa có thông báo đẩy (push notification) để nhắc việc quá hạn — hiện chỉ thể hiện qua badge trên card. Ở chế độ Cloud, khi mất mạng app sẽ không ghi tạm được lên local rồi đồng bộ sau (chỉ chế độ Guest mới có cơ chế cache). Một số tính năng bổ trợ thường gặp ở các app quản lý việc chuyên dụng cũng chưa có, gồm nhãn (tag/label), đính kèm ảnh, quên mật khẩu (đã có sẵn `Supabase.auth.resetPasswordForEmail()`, chỉ chưa thiết kế UI), và toggle Dark/Light thủ công (đang cố định theme Light để đảm bảo phong cách Liquid Glass nhất quán).

Về phía mã nguồn, dự án chưa có test tự động — toàn bộ kiểm thử hiện được thực hiện thủ công trên thiết bị. Phần state management còn dùng API legacy `Provider`/`StreamProvider` của Riverpod, chưa migrate sang `Notifier`/`StreamNotifier` mới (vẫn hoạt động bình thường, chỉ là sẽ dần bị thay thế ở các phiên bản tương lai).

---

## VII. CÁC CÂU PROMPT ĐIỂN HÌNH (Vibe Coding)

Trong quá trình phát triển, sinh viên không sử dụng những câu lệnh ngắn kiểu *"viết cho tôi một màn hình kanban"*, mà sử dụng **prompt có cấu trúc** — luôn khai báo rõ **vai trò của AI**, **ngữ cảnh dự án**, **ràng buộc kỹ thuật** và **tiêu chí chấp nhận**. Cách viết này giúp AI sinh ra code chất lượng cao, đúng convention của dự án, tốn ít vòng lặp chỉnh sửa.

Dưới đây là 8 prompt điển hình đã sử dụng:

---

### Prompt 1 — Thiết kế mô hình dữ liệu Task

> **Vai trò:** Bạn là một Flutter engineer có 5 năm kinh nghiệm, tuân thủ Clean Architecture và immutable data.
> **Ngữ cảnh:** Dự án Kanban cá nhân `psntask`, backend Supabase PostgreSQL, chế độ offline dùng `SharedPreferences`.
> **Yêu cầu:** Viết class `TaskModel` đặt tại `lib/features/kanban/domain/models/task_model.dart` gồm: `id` (String), `title`, `description`, `status` (enum `todo/doing/done`), `priority` (enum `low/medium/high`), `createdAt` (DateTime), `dueDate` (DateTime?, tùy chọn).
> **Ràng buộc:**
> - Immutable — tất cả field `final`.
> - Có `factory fromJson`, `toJson`, `copyWith` (kèm cờ `clearDueDate` để xóa hạn).
> - `toJson` khi `id.isEmpty` thì **không** đưa field `id` vào map (để Supabase tự sinh UUID); khi `dueDate == null` thì **không** đưa field `due_date` vào map.
> - `status` và `priority` dùng `enum.values.firstWhere` với `orElse` phòng khi server trả giá trị lạ.
> **Tiêu chí:** Code compile sạch với `flutter analyze`, không dùng package ngoài, đảm bảo tương thích với schema `tasks` của Supabase đã thiết kế.

---

### Prompt 2 — Repository Pattern hai nguồn dữ liệu

> **Vai trò:** Bạn là kiến trúc sư phần mềm chuyên về mobile. Bạn hiểu Repository Pattern và Stream-based reactive programming.
> **Ngữ cảnh:** App Flutter có **hai chế độ chạy**: đăng nhập Supabase (cloud, realtime) và khách (local, `SharedPreferences`). UI không được biết đang dùng nguồn nào.
> **Yêu cầu:**
> 1. Viết abstract class `TaskRepository` với các phương thức: `streamTasks()`, `addTask()`, `updateTask()`, `updateTaskStatus()`, `deleteTask()`.
> 2. Cài đặt `SupabaseTaskRepository` dùng `supabase.from('tasks').stream(primaryKey: ['id']).order('created_at', ascending: false)`.
> 3. Cài đặt `LocalTaskRepository` singleton dùng `SharedPreferences` + `StreamController.broadcast()` để emit mỗi khi cache đổi, có `_ensureLoaded()` để lazy-load JSON từ key `guest_tasks`.
> **Ràng buộc:**
> - Cả hai cài đặt **cùng interface**, không lộ chi tiết nguồn dữ liệu lên lớp presentation.
> - `LocalTaskRepository` phải sinh `id` bằng `DateTime.now().microsecondsSinceEpoch.toString()` để không trùng.
> - Không dùng FFI hay native plugin ngoài `shared_preferences`.
> **Tiêu chí:** Đổi nguồn chỉ bằng cách thay Provider trong Riverpod, không sửa 1 dòng ở Widget.

---

### Prompt 3 — Schema SQL + Row Level Security

> **Vai trò:** Bạn là PostgreSQL DBA, am hiểu Supabase Auth và Realtime.
> **Ngữ cảnh:** App đa user, mỗi user chỉ được thao tác task của chính mình. Cần nhận cập nhật realtime qua WebSocket.
> **Yêu cầu:** Viết một file migration duy nhất đặt tại `supabase/migrations/<timestamp>_create_tasks_table.sql` để:
> 1. Tạo bảng `tasks`: `id UUID` PK `gen_random_uuid()`, `user_id UUID` FK `auth.users(id)` default `auth.uid()`, `created_at TIMESTAMPTZ` default `NOW()`, `title TEXT NOT NULL`, `description TEXT`, `status TEXT NOT NULL DEFAULT 'todo'`, `priority TEXT NOT NULL DEFAULT 'medium'`.
> 2. Bật RLS và viết 4 policy SELECT / INSERT / UPDATE / DELETE kèm điều kiện `auth.uid() = user_id`. INSERT dùng `WITH CHECK`, các policy còn lại dùng `USING`.
> 3. Thêm bảng vào publication `supabase_realtime`.
> **Ràng buộc:** Không tạo index không cần thiết. Đặt comment tiếng Việt giải thích từng policy. Dùng cú pháp chuẩn PostgreSQL 15.
> **Tiêu chí:** Chạy migration trên project Supabase mới không sinh lỗi, user A không đọc/sửa/xóa được task của user B. Sau đó viết một migration thứ hai `add_due_date.sql` chỉ chứa `ALTER TABLE tasks ADD COLUMN IF NOT EXISTS due_date TIMESTAMPTZ NULL;` — tách riêng để dễ rollback nếu cần.

---

### Prompt 4 — Quản lý phiên đăng nhập 3 trạng thái

> **Vai trò:** Bạn là Flutter engineer chuyên về state management.
> **Ngữ cảnh:** App có 3 kiểu phiên: `none` (chưa đăng nhập), `cloud` (đăng nhập Supabase), `guest` (bỏ qua đăng nhập, lưu local). Phải bền qua lần mở app sau và phản ứng ngay khi Supabase auth đổi.
> **Yêu cầu:**
> - Viết class `AppState extends ChangeNotifier` kiểu singleton (`AppState.instance`).
> - Hàm `init()`: đọc khóa `guest_mode` từ `SharedPreferences` và `Supabase.instance.client.auth.currentSession` rồi xác định `SessionType`.
> - Lắng nghe `auth.onAuthStateChange`: khi có session thì tự tắt guest mode và set `cloud`; khi mất session thì về `none`.
> - Hàm `enterGuestMode()` và `signOut()` — `signOut` phải gọi `Supabase.auth.signOut()` khi đang ở cloud.
> **Ràng buộc:** Không dùng Riverpod hay Provider cho lớp này (vì phải khởi tạo trước `runApp`). Phải `notifyListeners()` mỗi khi `_type` đổi.
> **Tiêu chí:** Một `AuthWrapper` dùng `AnimatedBuilder(animation: AppState.instance, ...)` chuyển được giữa `LoginScreen` và `MainShell` hoàn toàn tự động.

---

### Prompt 5 — Hệ thống component "Liquid Glass"

> **Vai trò:** Bạn là UI engineer chuyên về design system và visual effects trong Flutter.
> **Ngữ cảnh:** Cần một design system "Fluid Luminary" kiểu frosted glass lấy cảm hứng từ visionOS / Aéro Vitrum (đính kèm 4 ảnh mock), áp dụng đồng nhất cho toàn app.
> **Yêu cầu:** Tạo file `lib/core/widgets/glass.dart` chứa 4 thành phần:
> 1. `GlassPalette` — các hằng màu (primary `#0058BB`, primaryContainer `#6C9FFF`, tertiary `#B90034`, v.v.).
> 2. `GlassContainer` — child + borderRadius + blur + opacity tùy chỉnh, dùng `ClipRRect` + `BackdropFilter(ImageFilter.blur(...))`, có viền trắng mờ và shadow nhẹ.
> 3. `GlassButton` — 2 chế độ: `primary=true` (gradient `primary → primaryContainer` + glow) và `primary=false` (kính mờ).
> 4. `GlassBackground` — nền màu `surface` + **4 quả cầu radial gradient** mờ ở 4 góc với màu khác nhau để tạo hiệu ứng mesh gradient.
> **Ràng buộc:** Không dùng package ngoài (`glassmorphism`, `blur`...), tất cả chỉ bằng widget built-in Flutter. Chú ý hiệu năng — `BackdropFilter` đắt, không lồng quá nhiều tầng.
> **Tiêu chí:** Chạy mượt 60fps trên Android tầm trung. Có thể dùng thay `Card`, `ElevatedButton`, `Scaffold.body` ở mọi màn hình.

---

### Prompt 6 — Deep link OAuth Supabase + Custom Tab trên Android

> **Vai trò:** Bạn là Android engineer hiểu sâu về intent-filter và deep linking.
> **Ngữ cảnh:** Đăng nhập Google qua `Supabase.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'com.psntask.psntask://login-callback/', authScreenLaunchMode: LaunchMode.inAppBrowserView)`. Sau khi Google xác thực xong, Supabase redirect về custom scheme này và app phải nhận được. Trải nghiệm phải giống các app hiện đại như SoundCloud (Custom Tab trượt từ dưới lên), không bị Google chặn vì lỗi `disallowed_useragent` của WebView.
> **Yêu cầu:**
> 1. Sửa `android/app/src/main/AndroidManifest.xml` — thêm `intent-filter` cho `MainActivity` với `action.VIEW`, `category.DEFAULT + BROWSABLE`, `data scheme="com.psntask.psntask" host="login-callback"`.
> 2. Đặt `launchMode="singleTop"` cho MainActivity để không spawn activity mới.
> 3. Trong Supabase Dashboard → Authentication → URL Configuration, thêm `com.psntask.psntask://login-callback/` vào Redirect URLs.
> 4. Ở LoginScreen chỉ hiển thị nút Google khi `kIsWeb || Platform.isAndroid || Platform.isIOS`.
> **Ràng buộc:** Không thay đổi package name. Không cần Firebase. Không hardcode URL Supabase trong code Android.
> **Tiêu chí:** Bấm "Đăng nhập Google" → mở Custom Tab trong app → chọn tài khoản → app tự quay lại với session đã lưu; không bị crash, không mở thêm tab Chrome rời.

---

### Prompt 7 — Kéo-thả task giữa các cột

> **Vai trò:** Bạn là Flutter UX engineer chuyên về gesture và animation.
> **Ngữ cảnh:** Màn `KanbanBoardScreen` đang dùng `TabBarView` với 3 cột (Cần làm / Đang làm / Hoàn thành). Mỗi card task ở trong `_TaskCard`, đã có `onTap` mở sheet sửa. Cần thêm tính năng kéo-thả mà không phá vỡ thao tác tap.
> **Yêu cầu:**
> 1. Bọc `_TaskCard` trong `LongPressDraggable<TaskModel>` với `delay: Duration(milliseconds: 280)` để không xung đột với scroll.
> 2. `onDragStarted`: gọi `HapticFeedback.mediumImpact()`.
> 3. `feedback`: tạo widget `_DragFeedback` — một card "ma" rộng 300 px, xoay nhẹ 0.02 radian, viền + shadow màu theo độ ưu tiên, có icon `drag_indicator`.
> 4. `childWhenDragging`: hiển thị card gốc với `Opacity(0.35)` để biết item đang được kéo.
> 5. Mỗi `Tab` trong `TabBar` được bọc bằng `DragTarget<TaskModel>` — `onWillAcceptWithDetails` chặn drop cùng cột; `onAcceptWithDetails` gọi `updateTaskStatus()`, `_tabController.animateTo(index)` và hiện SnackBar.
> 6. Trong builder của `DragTarget`, khi `candidate.isNotEmpty` → highlight tab bằng nền + viền màu primary.
> **Ràng buộc:** Không dùng package ngoài. Không phá vỡ scroll trong `ListView`. Tap vẫn mở sheet sửa.
> **Tiêu chí:** Long-press 280 ms → rung nhẹ → kéo card → tab header sáng lên khi hover → thả → status đổi + tab tự chuyển + toast hiện. Tap vẫn hoạt động bình thường.

---

### Prompt 8 — Trang Hoạt động với Ring Progress tự vẽ

> **Vai trò:** Bạn là Flutter engineer chuyên về CustomPaint và data visualization.
> **Ngữ cảnh:** Cần một trang `StatsScreen` hiển thị tỉ lệ task hoàn thành dưới dạng vòng tròn tiến độ (style giống mock Aéro Vitrum) và biểu đồ phân bổ theo độ ưu tiên. Không dùng package biểu đồ ngoài.
> **Yêu cầu:**
> 1. Lấy dữ liệu từ `tasksStreamProvider` qua `ref.watch`.
> 2. Tính toán: tổng, số done/doing/todo, số task theo từng priority, % hoàn thành.
> 3. Vẽ vòng tròn tiến độ bằng `CustomPainter`:
>    - Background ring xám nhạt, stroke width 14, `StrokeCap.round`.
>    - Foreground arc dùng `LinearGradient(primary → primaryContainer)`, bắt đầu từ `-π/2` (12 giờ) quay theo chiều kim đồng hồ.
> 4. Hiển thị 4 ô thống kê (2 × 2): Hoàn thành, Đang làm, Cần làm, Tổng — mỗi ô có icon nhỏ + label nhỏ caps + con số 36 px w900.
> 5. Section "Phân bổ theo độ ưu tiên" với 3 hàng `LinearProgressIndicator` thể hiện tỉ lệ Cao / Vừa / Thấp.
> 6. Khi `total == 0`: hiển thị **trạng thái rỗng** (icon + thông điệp), không hiển thị ring 0%.
> **Ràng buộc:** Không dùng `fl_chart`, `syncfusion_flutter_charts`, ... Tất cả chỉ bằng widget Flutter built-in + `CustomPaint`.
> **Tiêu chí:** Cập nhật realtime khi task đổi (vì dùng `tasksStreamProvider`). Nhìn sang trọng, không "AI quá".

---

## VIII. CÁC ĐƯỜNG DẪN QUAN TRỌNG

- **Link Source Code (GitHub / Drive):** *(sinh viên bổ sung khi nộp)*
- **Link APK demo (build release):** *(sinh viên bổ sung khi nộp)*
- **Video demo ứng dụng:** *(sinh viên bổ sung khi nộp)*
- **Supabase Project URL:** https://bzihpvybbfanesxpstts.supabase.co
  *(Lưu ý: `anon key` được để trong file `.env` cục bộ, không công khai trong báo cáo. `service_role key` không bao giờ đưa vào client.)*

---

*Báo cáo được soạn thảo bởi Ngô Thu Hương — Lớp 22A1701D — Môn Kỹ thuật Phần mềm Ứng dụng.*
