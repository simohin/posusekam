-- Создание таблицы списков покупок (shopping_lists)
CREATE TABLE shopping_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание таблицы товаров в списке покупок (shopping_list_items)
CREATE TABLE shopping_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id UUID REFERENCES shopping_lists(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    category_name TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    unit TEXT NOT NULL DEFAULT 'шт',
    bought BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индекс для быстрого поиска по домовладению
CREATE INDEX idx_shopping_lists_household_id ON shopping_lists(household_id);
-- Индекс для быстрого поиска по магазину
CREATE INDEX idx_shopping_lists_store_id ON shopping_lists(store_id);
