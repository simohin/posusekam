-- 1. Таблица магазинов (stores)
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Связываем товары с магазинами (каждый товар принадлежит одному магазину)
ALTER TABLE products ADD COLUMN store_id UUID REFERENCES stores(id) ON DELETE CASCADE;

-- 3. Создаем таблицу многие-ко-многим для категорий (тегов) товара
CREATE TABLE product_categories (
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (product_id, category_id)
);

-- 4. Переносим старые связи category_id (если они были) в новую таблицу product_categories
INSERT INTO product_categories (product_id, category_id)
SELECT id, category_id FROM products WHERE category_id IS NOT NULL;

-- 5. Удаляем устаревшую колонку category_id из таблицы products
ALTER TABLE products DROP COLUMN category_id;
