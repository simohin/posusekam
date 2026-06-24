-- Создание таблицы настроек пользователя (JSONB)
CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    settings JSONB NOT NULL DEFAULT '{}'::jsonb
);
