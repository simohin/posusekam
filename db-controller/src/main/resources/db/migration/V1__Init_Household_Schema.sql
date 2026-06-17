-- Таблица Домохозяйств
CREATE TABLE households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Связь Пользователи <-> Дома (user_id пока не привязан к Auth)
CREATE TABLE household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    user_id UUID NOT NULL,
    role TEXT DEFAULT 'member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (household_id, user_id)
);

-- Продуктовые категории
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    icon TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Справочник Продуктов домохозяйства
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    unit TEXT NOT NULL DEFAULT 'шт',
    m_factor DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    expected_frequency_days INT DEFAULT 7,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Кладовая (текущие остатки — «Сусеки»)
CREATE TABLE pantry_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    current_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'full',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
