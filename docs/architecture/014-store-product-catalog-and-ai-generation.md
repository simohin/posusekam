# ADR 014: Каталог товаров магазина и интеграция AI-генерации в мобильном приложении

## Статус
Реализовано

## Контекст
1. Ранее в системе отсутствовал полноценный каталог товаров (Products), привязанный к магазинам (Stores).
2. Требовалось реализовать:
   - Просмотр списка товаров в конкретном магазине.
   - Ручное создание, редактирование и удаление товаров.
   - Интеграцию с ИИ-генератором товаров (`generateProducts` эндпоинт), если в магазине нет товаров, с возможностью автоматического пакетного сохранения предложенных товаров в базу данных.
   - Управление кастомными категориями и единицами измерения домовладения в интерфейсе добавления/редактирования товара.
   - Изоляцию данных на бэкенде: проверка прав доступа пользователя (состоит ли в домовладении) при любых операциях с товарами, категориями и единицами измерения.

## Решение

### 1. Проектирование REST API (`openapi.yaml`)
В [openapi.yaml](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/resources/api/openapi.yaml) добавлены REST эндпоинты для ресурсов:
*   `/v1/{householdId}/stores/{storeId}/products` — список и создание товаров.
*   `/v1/{householdId}/stores/{storeId}/products/{id}` — редактирование и удаление товара.
*   `/v1/{householdId}/categories` — список и создание категорий.
*   `/v1/{householdId}/measure-units` — список и создание единиц измерения.

### 2. Реализация на бэкенде (`backend-service`)
*   Создана JPA-сущность [Product.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/models/src/main/kotlin/ru/simohin/posusekam/models/entity/Product.kt) со связью `ManyToMany` к категориям и полем `unit: String`.
*   Созданы контроллеры [ProductApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/controller/ProductApiController.kt), [CategoryApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/controller/CategoryApiController.kt), [MeasureUnitApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/backend-service/src/main/kotlin/ru/simohin/posusekam/backend/controller/MeasureUnitApiController.kt) с проверкой членства пользователя в домовладении.

### 3. Shared KMP-модуль (`mobile/shared`)
*   Внедрены Serializable-модели [Product.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/product/Product.kt) и клиентский [ProductRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/product/ProductRepository.kt) для взаимодействия с API через Ktor HttpClient.

### 4. iOS-приложение (`mobile/iosApp`)
*   В [AuthViewModel.swift](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/iosApp/iosApp/AuthViewModel.swift) добавлены асинхронные методы работы с репозиторием продуктов, категорий, единиц измерения и AI-генерации.
*   В [iosApp.swift](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/iosApp/iosApp/iosApp.swift) добавлены:
    - Переход на экран товаров `StoreProductsView` при нажатии на карточку магазина.
    - Экран `StoreProductsView` со списком товаров, контекстным меню действий (редактирование/удаление) и плашкой AI-генерации.
    - Интерактивный диалог `AiGenerationPromptSheet` для ввода описания ассортимента магазина. При генерации выполняется автоматический разбор результатов ИИ: если категория или единица измерения отсутствуют в базе домовладения, они автоматически создаются, после чего продукты пакетно импортируются в магазин.
    - Интерактивный лист `ProductFormSheet` для создания/редактирования товара с inline-добавлением новых категорий и единиц измерения прямо во время заполнения формы.

## Результаты
1. **Каталог товаров**: Полностью реализован и протестирован сквозной флоу управления каталогом товаров магазина.
2. **AI-генерация «в один клик»**: Пользователь может мгновенно наполнить новый магазин товарами на основе текстового описания (например, "Пивной бар: разливное пиво, арахис, сушеная рыба"), при этом система автоматически создает недостающие категории и единицы измерения в рамках домовладения.
3. **Безопасность**: Защищены все эндпоинты бэкенда.
