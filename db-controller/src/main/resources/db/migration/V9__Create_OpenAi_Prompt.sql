-- Создание таблицы хранимых промптов OpenAI
CREATE TABLE openai_prompts (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    version VARCHAR(50) NOT NULL
);

-- Вставка первого промпта (версия 4 с поддержкой переменных)
INSERT INTO openai_prompts (id, name, version)
VALUES ('pmpt_6a3cc207a84c8196b6894af272d54f7602c362203dba01a5', 'generate_products_list', '4');
