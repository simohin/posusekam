-- Добавление уникального ограничения на категорию в рамках одного домовладения
ALTER TABLE categories ADD CONSTRAINT categories_household_id_name_key UNIQUE (household_id, name);

-- Создание таблицы единиц измерения (measure_units)
CREATE TABLE measure_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (household_id, name)
);

-- Заполнение дефолтных категорий для уже существующих домов
INSERT INTO categories (household_id, name)
SELECT id, unnest(ARRAY['Алкоголь', 'Снеки', 'Горячие закуски', 'Безалкогольные напитки', 'Другое'])
FROM households
ON CONFLICT (household_id, name) DO NOTHING;

-- Заполнение дефолтных единиц измерения для уже существующих домов
INSERT INTO measure_units (household_id, name)
SELECT id, unnest(ARRAY['шт', 'л', 'уп', 'кг', 'г'])
FROM households
ON CONFLICT (household_id, name) DO NOTHING;
