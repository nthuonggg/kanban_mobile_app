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
- **Mô hình phát triển:** Agile — làm cá nhân, chia thành các đợt phát triển (Sprint) 4–5 ngày.
- **Ngôn ngữ / Framework:** **Flutter 3.x (Dart SDK ^3.11.4)** — cho phép build 1 codebase chạy Android, iOS, Web, macOS, Windows, Linux.
- **Quản lý trạng thái:** **Riverpod 3.x** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) — reactive, hỗ trợ code-gen.
- **Backend & Database:** **Supabase** (PostgreSQL + Realtime + Authentication) — lưu dữ liệu cloud, đồng bộ realtime qua WebSocket.
- **Xác thực:** Supabase Auth (Email/Password) kết hợp `google_sign_in ^7.2.0` và OAuth deep link.
- **Lưu trữ cục bộ:** `shared_preferences ^2.5.5` — lưu task ở chế độ khách (Guest) và trạng thái phiên đăng nhập.
- **Cấu hình bảo mật:** `flutter_dotenv ^5.2.1` — tách khóa Supabase ra file `.env`, tránh commit lên Git.
- **Thiết kế giao diện:** Material 3 tùy biến + hiệu ứng **Liquid Glass / Frosted Glass** (BackdropFilter + mesh gradient).
- **Công cụ hỗ trợ:** Google AI Studio (Gemini) làm "trợ lý lập trình" theo phương pháp Vibe Coding, Visual Studio Code, Android Studio, Supabase Studio, Git.

### 3. Phương pháp tiếp cận (Vibe Coding)
Sử dụng AI (Google Gemini / Claude) làm trợ lý để:
- Sinh khung sườn code (boilerplate Flutter, Riverpod provider, repository pattern).
- Đề xuất cách thiết kế schema PostgreSQL, viết câu SQL `CREATE TABLE` kèm Row Level Security.
- Refactor code theo Clean Architecture 3 lớp (domain / data / presentation).
- Debug lỗi deep link OAuth, lỗi stream Supabase Realtime.
- Thiết kế giao diện kính mờ (Liquid Glass) từ mô tả tự nhiên.

Sinh viên đọc hiểu từng dòng code, tùy chỉnh theo yêu cầu đề bài và tự kiểm thử trước khi nhận là "xong".

---

## III. MÔ TẢ QUÁ TRÌNH PHÁT TRIỂN VÀ THIẾT KẾ

### 1. Quy trình phát triển (Agile — cá nhân)

Dự án được chia thành **3 Sprint**, mỗi Sprint khoảng 4–5 ngày:

- **Sprint 1 – Khởi tạo & MVP ngoại tuyến**
  - Thiết lập dự án Flutter, cấu hình đa nền tảng.
  - Xây dựng mô hình `TaskModel` (title, description, status, priority, createdAt).
  - Viết `LocalTaskRepository` lưu bằng `SharedPreferences` để chạy được ngay không cần backend.
  - Dựng giao diện Kanban 3 tab (Cần làm / Đang làm / Hoàn thành).

- **Sprint 2 – Tích hợp Backend Cloud**
  - Tạo project Supabase, thiết kế bảng `tasks` với PostgreSQL.
  - Viết migration SQL kèm **Row Level Security (RLS)** cô lập dữ liệu theo `user_id`.
  - Viết `SupabaseTaskRepository` thực hiện CRUD và đặc biệt là **stream realtime** qua `supabase.from('tasks').stream()`.
  - Triển khai xác thực Email/Password và **Google OAuth** với deep link `com.psntask.psntask://login-callback/`.
  - Xây `AppState` quản lý 3 trạng thái phiên: `none` / `cloud` / `guest` và `taskRepositoryProvider` tự chọn kho dữ liệu phù hợp.

- **Sprint 3 – Hoàn thiện UI/UX & Kiểm thử**
  - Thiết kế lại toàn bộ giao diện theo phong cách **"Fluid Luminary" – Liquid Glass**: `GlassContainer`, `GlassButton`, `GlassBackground` với 4 quả cầu gradient mờ ở 4 góc, hiệu ứng `BackdropFilter` blur.
  - Bổ sung **tìm kiếm theo tên** và **lọc theo độ ưu tiên** (Low / Medium / High) bằng chip.
  - Bổ sung bottom sheet kính mờ để thêm/sửa task, action sheet chuyển trạng thái.
  - Thêm **badge phân biệt** "Cloud" (xanh) / "Cục bộ" (cam) ở AppBar để người dùng biết dữ liệu đang lưu ở đâu.
  - Kiểm thử thủ công các luồng: đăng nhập, đăng xuất, chuyển chế độ khách, mất mạng, xung đột dữ liệu.

### 2. Thiết kế hệ thống (Clean Architecture 3 lớp)

Thư mục `lib/` được tổ chức theo **Feature-first + Clean Architecture**:

```
lib/
├── main.dart                             ← Entry point + AuthWrapper
├── core/
│   ├── app_state.dart                    ← Quản lý SessionType (none/cloud/guest)
│   ├── constants/supabase_constants.dart ← Đọc .env
│   ├── theme/app_theme.dart              ← Material 3 theme tùy biến
│   └── widgets/glass.dart                ← GlassContainer, GlassButton, GlassBackground
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── login_screen.dart         ← Google / Email / Guest
    │       └── email_auth_screen.dart    ← TabBar đăng nhập / đăng ký
    └── kanban/
        ├── domain/models/task_model.dart ← TaskModel, TaskStatus, TaskPriority
        ├── data/
        │   ├── task_repository.dart      ← Abstract + SupabaseTaskRepository
        │   └── local_task_repository.dart← Guest mode dùng SharedPreferences
        └── presentation/
            ├── kanban_board_screen.dart  ← Màn hình chính Kanban
            └── providers/task_provider.dart
```

**Điểm nổi bật kiến trúc:**
- **Repository Pattern:** Interface `TaskRepository` chung, có 2 cài đặt — `SupabaseTaskRepository` (cloud, realtime) và `LocalTaskRepository` (khách, SharedPreferences). Lớp trình bày không cần biết dữ liệu đang lưu ở đâu.
- **Riverpod Provider động:** `taskRepositoryProvider` tự đọc `AppState.instance.type` để trả về đúng repository. `tasksStreamProvider` là `StreamProvider.autoDispose` giúp UI cập nhật tức thì khi dữ liệu đổi.
- **Bảo mật:** Khóa Supabase đọc qua `dotenv`, không commit. Trên server bật **Row Level Security** — user không đăng nhập không đọc được bảng, user đã đăng nhập chỉ đọc được task của chính mình.

### 3. Thiết kế Cơ sở dữ liệu (Supabase / PostgreSQL)

File migration: `supabase/migrations/20260416000000_create_tasks_table.sql`

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

Có thêm **4 chính sách RLS** đảm bảo an toàn dữ liệu giữa các người dùng, và bật **Realtime** để client nhận thay đổi qua WebSocket.

### 4. Quản lý công việc

Do làm cá nhân nên không sử dụng Trello. Công việc được quản lý bằng:
- **Danh sách TODO** trực tiếp trong IDE.
- **Git commit** chia nhỏ theo từng tính năng để dễ quay lui khi có lỗi.
- **Ghi chú nhật ký Sprint** ngắn gọn sau mỗi ngày làm việc.

---

## IV. CÁC CHỨC NĂNG ĐÃ TRIỂN KHAI

### 1. Đăng nhập đa phương thức
- **Đăng nhập bằng Google** qua Supabase OAuth (mở in-app browser, trở về app qua deep link).
- **Đăng ký / Đăng nhập bằng Email + Mật khẩu** với validation (kiểm tra định dạng email, mật khẩu tối thiểu 6 ký tự).
- **Chế độ khách (Guest)** — tiếp tục sử dụng không cần tài khoản, dữ liệu lưu cục bộ bằng `SharedPreferences`.
- Tự động duy trì phiên đăng nhập giữa các lần mở app; tự động chuyển màn hình khi trạng thái thay đổi qua `onAuthStateChange`.

### 2. Bảng Kanban 3 cột
- Giao diện TabBar: **Cần làm / Đang làm / Hoàn thành**.
- Mỗi cột là một `ListView` cuộn độc lập, hiển thị thẻ công việc dưới dạng card kính mờ.
- Thẻ hiển thị: tên công việc, mô tả (tối đa 3 dòng), huy hiệu độ ưu tiên có màu (xanh/xanh dương/đỏ), dải glow màu bên trái thẻ.

### 3. Quản lý Task (CRUD)
- **Thêm mới** qua bottom sheet kính mờ: nhập tên, mô tả (tùy chọn), chọn độ ưu tiên (THẤP / VỪA / CAO).
- **Sửa** bằng cách nhấn trực tiếp vào thẻ hoặc chọn "Sửa" trong action sheet.
- **Xóa** với hộp thoại xác nhận để tránh xóa nhầm.
- **Chuyển trạng thái** qua action sheet — linh hoạt chuyển 2 chiều giữa 3 trạng thái, không chỉ tiến một chiều.
- Toast thông báo phản hồi mọi hành động (thành công hoặc lỗi).

### 4. Tìm kiếm và Lọc (Bộ lọc)
- **Tìm kiếm** theo tên công việc — không phân biệt hoa thường, lọc ngay khi gõ.
- **Lọc theo độ ưu tiên** bằng chip (Tất cả / THẤP / VỪA / CAO) với hiệu ứng chọn sáng màu chủ đạo.
- Kết hợp cả hai bộ lọc — hiển thị thông báo trạng thái rỗng phù hợp.

### 5. Đồng bộ Realtime
- Khi đăng nhập cloud, danh sách task được cập nhật tức thì qua `supabase.from('tasks').stream()`. Mở app trên 2 thiết bị — thêm task ở thiết bị A, thiết bị B cập nhật ngay trong vài trăm ms mà không cần F5.
- Khi ở chế độ khách, sử dụng `StreamController` nội bộ để UI vẫn cập nhật reactive khi dữ liệu local thay đổi.

### 6. Giao diện "Liquid Glass"
- Nền **mesh gradient** với 4 quả cầu radial mờ ở 4 góc (xanh dương, hồng, tím, xanh đậm).
- Tất cả card, dialog, bottom sheet đều dùng `BackdropFilter` blur + viền trắng mờ + đổ bóng nhẹ → cảm giác "kính mờ" sang trọng.
- Button chính dùng gradient `primary → primaryContainer` có glow, button phụ dùng kính mờ.
- **Badge "Cloud / Cục bộ"** ở AppBar giúp người dùng nhận biết dữ liệu đang lưu ở đâu.

### 7. Đa nền tảng
- Cùng 1 codebase chạy được trên Android, iOS, Web, macOS, Windows, Linux.
- Deep link OAuth được cấu hình trong `AndroidManifest.xml` với scheme `com.psntask.psntask` host `login-callback`.
- Tự ẩn nút "Đăng nhập Google" trên các nền tảng chưa hỗ trợ.

---

## V. PHÂN CÔNG CÔNG VIỆC

Đề tài do **một sinh viên thực hiện toàn bộ**:

| Thành viên | Nhiệm vụ chi tiết |
|---|---|
| **Ngô Thu Hương** | – Khởi tạo dự án Flutter đa nền tảng, cấu hình `.env`, Supabase.<br>– Thiết kế cơ sở dữ liệu PostgreSQL, viết migration SQL kèm Row Level Security.<br>– Lập trình toàn bộ lớp dữ liệu: `TaskModel`, `SupabaseTaskRepository`, `LocalTaskRepository`.<br>– Xây dựng xác thực đa phương thức (Google OAuth, Email, Guest) và `AppState` quản lý phiên.<br>– Thiết kế hệ thống component **Liquid Glass** (`GlassContainer`, `GlassButton`, `GlassBackground`).<br>– Lập trình màn hình Kanban 3 tab với tìm kiếm, lọc, CRUD.<br>– Tích hợp Supabase Realtime, xử lý stream.<br>– Kiểm thử thủ công tất cả các luồng, xử lý lỗi nhập liệu.<br>– Soạn thảo tài liệu và báo cáo. |

---

## VI. KẾT QUẢ ĐẠT ĐƯỢC VÀ HẠN CHẾ

### 1. Kết quả đạt được
- **Hoàn thành đầy đủ yêu cầu của đề bài**: Login (Google + Email), Dashboard Kanban, CRUD task, bộ lọc + tìm kiếm, dữ liệu thời gian thực qua Supabase, cấu trúc bảng PostgreSQL đúng đặc tả.
- **Vượt yêu cầu** ở một số điểm:
  - Thêm **chế độ khách (Guest)** — vẫn dùng được app khi chưa có tài khoản hoặc mất mạng.
  - Thiết kế **Repository Pattern** để thay đổi nguồn dữ liệu (cloud ↔ local) minh bạch với tầng UI.
  - Giao diện **Liquid Glass** hiện đại, đồng nhất, hoạt ảnh mượt 60fps.
  - Bảo mật dữ liệu nhiều lớp: `.env` + `dotenv` ở client, **Row Level Security** ở server.
- Áp dụng thành công **Vibe Coding** — rút ngắn thời gian lập trình khoảng 2–3 lần so với viết tay từ đầu, nhưng sinh viên vẫn nắm chắc logic do đọc kỹ từng dòng code AI sinh ra.
- Ứng dụng build chạy mượt trên Android, không crash khi kiểm thử các luồng thông thường.

### 2. Hạn chế còn tồn tại
- **Chưa hỗ trợ kéo-thả (drag & drop)** giữa các cột — hiện đang chuyển trạng thái qua action sheet. Nên bổ sung `ReorderableListView` hoặc `flutter_draggable`.
- **Chưa có hạn chót (deadline)**, **nhãn/tag** hoặc **đính kèm ảnh**.
- **Chưa có thông báo đẩy (push notification)** nhắc việc quá hạn.
- **Chưa xử lý mất mạng thực sự thông minh**: khi đăng nhập cloud mà mất mạng, app sẽ không ghi được tạm lên local để đồng bộ sau (chỉ có khách mới lưu local).
- **Chưa có test tự động** (unit test, widget test) — hiện kiểm thử hoàn toàn thủ công.
- **Luồng đăng ký email** chưa hiển thị màn hình xác nhận email đối với project Supabase bật chế độ "Confirm Email" — nếu bật sẽ cần thêm màn hình thông báo.

---

## VII. CÁC CÂU PROMPT ĐIỂN HÌNH (Vibe Coding)

Trong quá trình phát triển, sinh viên không sử dụng những câu lệnh ngắn kiểu *"viết cho tôi một màn hình kanban"*, mà sử dụng **prompt có cấu trúc** — luôn khai báo rõ **vai trò của AI**, **ngữ cảnh dự án**, **ràng buộc kỹ thuật** và **tiêu chí chấp nhận**. Cách viết này giúp AI sinh ra code chất lượng cao, đúng convention của dự án, tốn ít vòng lặp chỉnh sửa.

Dưới đây là 6 prompt điển hình đã sử dụng:

---

### Prompt 1 — Thiết kế mô hình dữ liệu Task

> **Vai trò:** Bạn là một Flutter engineer có 5 năm kinh nghiệm, tuân thủ Clean Architecture và immutable data.
> **Ngữ cảnh:** Dự án Kanban cá nhân `psntask`, backend Supabase PostgreSQL, chế độ offline dùng `SharedPreferences`.
> **Yêu cầu:** Viết class `TaskModel` đặt tại `lib/features/kanban/domain/models/task_model.dart` gồm: `id` (String), `title`, `description`, `status` (enum `todo/doing/done`), `priority` (enum `low/medium/high`), `createdAt` (DateTime).
> **Ràng buộc:**
> - Immutable — tất cả field `final`.
> - Có `factory fromJson`, `toJson`, `copyWith`.
> - `toJson` khi `id.isEmpty` thì **không** đưa field `id` vào map (để Supabase tự sinh UUID).
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
> **Ràng buộc:** Không tạo index không cần thiết. Đặt comment tiếng Việt giải thích từng policy. Dùng cú pháp chuẩn PostgreSQL 15 — không dùng extension ngoài `pgcrypto`.
> **Tiêu chí:** Chạy migration trên project Supabase mới không sinh lỗi, user A không đọc/sửa/xóa được task của user B.

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
> **Tiêu chí:** Một `AuthWrapper` dùng `AnimatedBuilder(animation: AppState.instance, ...)` chuyển được giữa `LoginScreen` và `KanbanBoardScreen` hoàn toàn tự động.

---

### Prompt 5 — Hệ thống component "Liquid Glass"

> **Vai trò:** Bạn là UI engineer chuyên về design system và visual effects trong Flutter.
> **Ngữ cảnh:** Cần một design system "Fluid Luminary" kiểu frosted glass lấy cảm hứng từ visionOS / Aéro Vitrum, áp dụng đồng nhất cho toàn app.
> **Yêu cầu:** Tạo file `lib/core/widgets/glass.dart` chứa 4 thành phần:
> 1. `GlassPalette` — các hằng màu (primary `#0058BB`, primaryContainer `#6C9FFF`, tertiary `#B90034`, v.v.).
> 2. `GlassContainer` — child + borderRadius + blur + opacity tùy chỉnh, dùng `ClipRRect` + `BackdropFilter(ImageFilter.blur(...))`, có viền trắng mờ và shadow nhẹ.
> 3. `GlassButton` — 2 chế độ: `primary=true` (gradient `primary → primaryContainer` + glow) và `primary=false` (kính mờ).
> 4. `GlassBackground` — nền màu `surface` + **4 quả cầu radial gradient** mờ ở 4 góc với màu khác nhau để tạo hiệu ứng mesh gradient.
> **Ràng buộc:** Không dùng package ngoài (`glassmorphism`, `blur`...), tất cả chỉ bằng widget built-in Flutter. Chú ý hiệu năng — `BackdropFilter` đắt, không lồng quá nhiều tầng.
> **Tiêu chí:** Chạy mượt 60fps trên Android tầm trung. Có thể dùng thay `Card`, `ElevatedButton`, `Scaffold.body` ở mọi màn hình.

---

### Prompt 6 — Deep link OAuth Supabase trên Android

> **Vai trò:** Bạn là Android engineer hiểu sâu về intent-filter và deep linking.
> **Ngữ cảnh:** Đăng nhập Google qua `Supabase.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'com.psntask.psntask://login-callback/', authScreenLaunchMode: LaunchMode.inAppBrowserView)`. Sau khi Google xác thực xong, Supabase redirect về custom scheme này và app phải nhận được.
> **Yêu cầu:**
> 1. Sửa `android/app/src/main/AndroidManifest.xml` — thêm `intent-filter` cho `MainActivity` với `action.VIEW`, `category.DEFAULT + BROWSABLE`, `data scheme="com.psntask.psntask" host="login-callback"`.
> 2. Đặt `launchMode="singleTop"` cho MainActivity để không spawn activity mới.
> 3. Ở LoginScreen chỉ hiển thị nút Google khi `kIsWeb || Platform.isAndroid || Platform.isIOS`.
> **Ràng buộc:** Không thay đổi package name. Không cần Firebase. Không hardcode URL Supabase trong code Android.
> **Tiêu chí:** Bấm "Đăng nhập Google" → mở trình duyệt trong app → chọn tài khoản → app tự quay lại `KanbanBoardScreen` với session đã lưu; không bị crash, không mở thêm tab Chrome rời.

---

## VIII. CÁC ĐƯỜNG DẪN QUAN TRỌNG

- **Link Source Code (GitHub / Drive):** *(sinh viên bổ sung khi nộp)*
- **Link APK demo (build release):** *(sinh viên bổ sung khi nộp)*
- **Video demo ứng dụng:** *(sinh viên bổ sung khi nộp)*
- **Supabase Project URL:** https://bzihpvybbfanesxpstts.supabase.co
  *(Lưu ý: `anon key` được để trong file `.env` cục bộ, không công khai trong báo cáo.)*

---

## IX. CẤU TRÚC FILE DỰ ÁN (Tham khảo)

```
psntask/
├── .env                                  ← SUPABASE_URL, SUPABASE_ANON_KEY (không commit)
├── .env.example                          ← Mẫu cấu hình
├── pubspec.yaml                          ← Khai báo dependencies
├── docs.md                               ← Đặc tả đề bài
├── android/                              ← Cấu hình deep link OAuth
├── ios/ / web/ / macos/ / windows/ / linux/
├── lib/
│   ├── main.dart
│   ├── core/ (app_state, constants, theme, widgets/glass)
│   └── features/
│       ├── auth/presentation/ (login_screen, email_auth_screen)
│       └── kanban/
│           ├── domain/models/task_model.dart
│           ├── data/ (task_repository, local_task_repository)
│           └── presentation/ (kanban_board_screen, providers/)
├── supabase/
│   ├── config.toml
│   └── migrations/20260416000000_create_tasks_table.sql
└── report/
    └── bao_cao_psntask.md                ← File báo cáo này
```

---

*Báo cáo được soạn thảo bởi Ngô Thu Hương — Lớp 22A1701D — Môn Kỹ thuật Phần mềm Ứng dụng.*
