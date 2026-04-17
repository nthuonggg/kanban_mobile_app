CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) DEFAULT auth.uid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'todo',
    priority TEXT NOT NULL DEFAULT 'medium'
);

-- Bảo mật Row Level Security (RLS) để cô lập dữ liệu theo từng User ID
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cho phép User xem task của chính họ" 
ON tasks FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Cho phép User tạo task của chính họ" 
ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Cho phép User cập nhật task của chính họ" 
ON tasks FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Cho phép User xóa task của chính họ" 
ON tasks FOR DELETE USING (auth.uid() = user_id);

-- Bật kết nối Realtime cho bảng tasks
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
