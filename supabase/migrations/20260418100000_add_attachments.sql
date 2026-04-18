-- ════════════════════════════════════════════════════════════
-- File đính kèm cho task: bảng phụ + Storage bucket + RLS
-- ════════════════════════════════════════════════════════════

-- 1. Bảng task_attachments — 1 task có nhiều file
CREATE TABLE IF NOT EXISTS task_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) DEFAULT auth.uid(),
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,        -- đường dẫn trong Storage bucket
    mime_type TEXT,                  -- 'audio/mpeg', 'image/png', 'application/pdf'…
    file_size BIGINT,                -- bytes
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_task_attachments_task ON task_attachments(task_id);

-- RLS cho bảng — user chỉ thao tác file của task chính họ
ALTER TABLE task_attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User xem attachment của chính họ"
  ON task_attachments FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "User thêm attachment vào task của chính họ"
  ON task_attachments FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User xóa attachment của chính họ"
  ON task_attachments FOR DELETE USING (auth.uid() = user_id);

-- Bật realtime cho attachment (để khi thêm/xóa file ở thiết bị A, B tự cập nhật)
ALTER PUBLICATION supabase_realtime ADD TABLE task_attachments;


-- 2. Tạo Storage bucket 'task-attachments' (private, chỉ user đăng nhập)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'task-attachments',
    'task-attachments',
    false,                                  -- private — không cho public truy cập
    52428800,                               -- giới hạn 50 MB / file
    NULL                                    -- NULL = nhận mọi mime type
)
ON CONFLICT (id) DO NOTHING;


-- 3. Storage policies — file được lưu dưới đường dẫn '<user_id>/<task_id>/<file_name>'
--    User chỉ truy cập được file trong folder của chính họ.
CREATE POLICY "User upload file vào folder của mình"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'task-attachments'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "User xem file của mình"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'task-attachments'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "User xóa file của mình"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'task-attachments'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
