-- Создание таблицы пользователей (Auth)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    google_id TEXT UNIQUE,
    name TEXT,
    picture_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Добавляем внешний ключ к household_members, так как в V1 мы оставили user_id просто как UUID
ALTER TABLE household_members 
    ADD CONSTRAINT fk_household_members_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
