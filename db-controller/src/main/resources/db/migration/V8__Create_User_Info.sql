-- Создание таблицы информации о пользователе (JSONB)
CREATE TABLE user_info (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    info JSONB NOT NULL DEFAULT '{}'::jsonb
);
