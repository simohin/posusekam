# ADR 013: Хранение категорий продуктов и единиц измерения с привязкой к домовладениям

## Статус
Реализовано

## Контекст
1. Ранее в системе категории продуктов и единицы измерения были реализованы в виде перечислений (enum `ProductCategory` и `ProductMeasureUnit`). Это делало их глобальными для всей системы и не позволяло пользователям редактировать или добавлять собственные значения в рамках конкретных домовладений (Household).
2. Требовалось:
   - Хранить категории и единицы измерения в базе данных.
   - Сделать их уникальными и редактируемыми в рамках каждого домовладения (`household_id`).
   - При создании нового домовладения автоматически инициализировать его дефолтными категориями (из `ProductCategory`) и единицами измерения (из `ProductMeasureUnit`).
   - Обеспечить совместимость `AiService` с динамическим списком строк (`List<String>`), получаемым из базы данных, вместо жестких перечислений.
   - Защитить эндпоинт генерации продуктов, добавив проверку на членство пользователя в домовладении, для которого генерируются продукты.

## Решение

### 1. Схема базы данных и миграции
Создана миграция [V10__Create_Household_Categories_And_Units.sql](file:///Users/t.simokhin/IdeaProjects/posusekam/db-controller/src/main/resources/db/migration/V10__Create_Household_Categories_And_Units.sql), которая:
- Добавляет уникальное ограничение `UNIQUE (household_id, name)` на таблицу `categories`.
- Создает таблицу `measure_units` с аналогичным уникальным ограничением.
- Инициализирует существующие в системе домовладения ("Брусника" и "Яснолетово") дефолтным набором категорий и единиц измерения.

### 2. JPA-сущности и Репозитории
- В модуле `:models` сопоставлены сущности `Category` и `MeasureUnit` с таблицами БД.
- Созданы [CategoryRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/repository/CategoryRepository.kt) и [MeasureUnitRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/repository/MeasureUnitRepository.kt) для доступа к данным.

### 3. Автоматическая инициализация при создании домовладения
- В [HouseholdApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/controller/HouseholdApiController.kt) добавлено сохранение дефолтных категорий и единиц измерения на основе значений `ProductCategory` и `ProductMeasureUnit` сразу после успешного создания сущности `Household`.

### 4. Рефакторинг AI-интеграции
- Интерфейс [AiService.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/service/AiService.kt) и класс [OpenAiService.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/service/OpenAiService.kt) обновлены так, чтобы принимать `List<String>` для `allowedCategories` и `allowedUnits` вместо списков перечислений.
- Внедрен сервисный слой [ProductGenerationService.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/service/ProductGenerationService.kt), который проверяет права доступа пользователя к домовладению (проверяет членство), получает списки категорий и единиц измерения из БД и отправляет их в `AiService` для генерации.
- В [openapi.yaml](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/resources/api/openapi.yaml) для `GenerateProductsRequest` добавлено обязательное поле `householdId` типа UUID. Контроллер [AiApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/controller/AiApiController.kt) извлекает `householdId` и передает управление в `ProductGenerationService`.

## Результаты
1. **Кастомизация данных**: Домовладения теперь имеют изолированные списки категорий и единиц измерения в БД, доступные для редактирования.
2. **Безопасность**: Запросы к генерации продуктов теперь проверяются на членство пользователя в домовладении (`HTTP 403 Forbidden` при попытке сгенерировать продукты для чужого дома).
3. **Обратная совместимость**: Старые и новые домовладения автоматически получают стандартный набор категорий и единиц измерения, что гарантирует корректную генерацию продуктов AI-сервисом.
4. **Успешное тестирование**: Запрос к `/api/v1/ai/generate-products` с указанием `householdId` и JWT-токеном авторизации возвращает список товаров, строго ограниченный категориями и единицами измерения из базы данных этого домовладения.
