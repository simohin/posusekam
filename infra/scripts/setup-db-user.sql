-- Выполнять от имени суперпользователя (postgres)

-- 1. Создаем пользователя (роль) приложения
CREATE USER posusekam WITH ENCRYPTED PASSWORD 'NEW_SECURE_PASSWORD';

-- 2. Если база данных уже создана, меняем ее владельца
ALTER DATABASE posusekam OWNER TO posusekam;

-- 3. Выдаем права на саму БД
GRANT ALL PRIVILEGES ON DATABASE posusekam TO posusekam;

-- === ВНИМАНИЕ: Следующие команды нужно выполнять, подключившись непосредственно к базе `posusekam` ===
-- В psql переключиться можно командой: \c posusekam

-- 4. Передаем права на использование схемы public
GRANT ALL ON SCHEMA public TO posusekam;

-- 5. Если в базе уже есть созданные таблицы, передаем права на них
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO posusekam;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO posusekam;

-- 6. Делаем так, чтобы все новые таблицы, создаваемые в будущем (например, миграциями), были доступны пользователю
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO posusekam;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO posusekam;
