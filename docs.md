XÂY DỰNG HỆ THỐNG QUẢN LÝ DỰ ÁN CÁ NHÂN
(PERSONAL TASK KANBAN)

1. Giới thiệu bài toán
Trong bối cảnh làm việc hiện đại, việc quản lý công việc theo mô hình Kanban (To-do, Doing, Done) là cực kỳ phổ biến. Sinh viên cần xây dựng một ứng dụng web hoặc mobile app cho phép người dùng quản lý các nhiệm vụ cá nhân, phân loại theo trạng thái và lưu trữ dữ liệu bền vững trên Cloud.
2. Yêu cầu kỹ thuật (Tech Stack)
Sinh viên bắt buộc sử dụng quy trình Vibe Coding với các công cụ sau:
UI/UX Design: Stitch (Dùng AI để generate giao diện từ prompt).
Frontend & Logic: Antigravity hoặc AI Studio (Dùng AI để viết code Flutter/React/Next.js và xử lý logic).
Backend & Database: Supabase (PostgreSQL để lưu trữ dữ liệu và Realtime updates).
3. Các chức năng cần thực hiện (Requirements)
A. Chức năng chính:
Login: Đăng ký tài khoản và đăng nhập bằng Google email.
Dashboard: Hiển thị danh sách các thẻ công việc (Tasks) dưới dạng cột Kanban.
Quản lý Task: Thêm mới task (Tên task, Mô tả, Độ ưu tiên: Low/Medium/High).
Cập nhật trạng thái task (Kéo thả hoặc nhấn nút chuyển cột).
Xóa task.
Bộ lọc: Tìm kiếm task theo tên hoặc lọc theo mức độ ưu tiên.
Real-time: Dữ liệu tự động cập nhật khi có thay đổi trong Database.
B. Cấu trúc Database (Supabase):
Tạo bảng tasks gồm các trường:
id: uuid (Primary Key)
created_at: timestamp
title: text
description: text
status: text (Mặc định: 'todo', 'doing', 'done')
priority: text (Low, Medium, High)
