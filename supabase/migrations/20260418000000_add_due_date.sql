-- Thêm cột due_date (hạn hoàn thành) — NULL cho task không có hạn.
ALTER TABLE tasks
    ADD COLUMN IF NOT EXISTS due_date TIMESTAMPTZ NULL;
