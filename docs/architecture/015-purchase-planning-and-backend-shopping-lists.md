# ADR 015: Планирование закупок и хранение списков покупок на бэкенде

## Статус
Реализовано

## Контекст
1. Ранее вкладка «Калькулятор» (`CalculatorTab`) была заглушкой, а списки покупок/запланированных товаров отсутствовали.
2. Требовалось реализовать:
   - Функционал планирования закупок с Tinder-подобным интерфейсом свайпа карточек товаров выбранного магазина.
   - Механику отметки «нужен товар или нет» (свайп вправо — нужно, влево — не нужно) с быстрым редактированием количества прямо на карточке.
   - Экран саммари (итоги планирования) с возможностью подтвердить список, удалить товары, добавить существующие товары из каталога или создать новый товар через форму `ProductFormSheet`.
   - Перенос хранения списков покупок с локального `UserDefaults` на бэкенд через CRUD API.
   - Рефакторинг карточки редактирования в готовом списке: она должна открываться в том же интерфейсе Tinder-свайпа (только для редактируемого товара) вместо всплывающего модального оверлея.
   - Программную анимацию улетания карточки и отображения наклеек «НАДО» / «НЕ НАДО» при нажатии на кнопки-иконки крестика или галочки.

## Решение

### 1. Проектирование REST API (`openapi.yaml`)
В OpenAPI спецификацию бэкенда добавлены CRUD-эндпоинты для управления списками покупок домовладения:
*   `GET /v1/{householdId}/shopping-lists` — получение всех списков покупок.
*   `POST /v1/{householdId}/shopping-lists` — создание нового списка покупок.
*   `PUT /v1/{householdId}/shopping-lists/{id}` — обновление позиций и статуса завершенности списка.
*   `DELETE /v1/{householdId}/shopping-lists/{id}` — удаление списка покупок.

### 2. Схема базы данных и бэкенд (`db-controller`, `backend-service`)
*   Создан SQL-скрипт Flyway-миграции [V11__Create_Shopping_Lists_Schema.sql](file:///Users/t.simokhin/IdeaProjects/posusekam/db-controller/src/main/resources/db/migration/V11__Create_Shopping_Lists_Schema.sql) для создания таблиц `shopping_lists` и `shopping_list_items`.
*   Созданы JPA-сущности `ShoppingList` и `ShoppingListItem` в модуле `:models`.
*   Реализованы JPA-репозитории и REST-контроллер `ShoppingListApiController` в модуле `:backend-service`.

### 3. Клиентский репозиторий в KMP-модуле (`mobile/shared`)
*   Реализована сериализуемая модель данных [ShoppingList.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/shoppinglist/ShoppingList.kt).
*   Создан репозиторий [ShoppingListRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/shoppinglist/ShoppingListRepository.kt) для взаимодействия с сетевыми эндпоинтами бэкенда через Ktor HttpClient.

### 4. iOS-приложение (`mobile/iosApp`)
*   В [AuthViewModel.swift](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/iosApp/iosApp/AuthViewModel.swift) интегрирован `ShoppingListRepository`, добавлены функции `fetchShoppingLists()`, `createShoppingList()`, `updateShoppingList()`, `deleteShoppingList()`.
*   В [iosApp.swift](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/iosApp/iosApp/iosApp.swift):
    - Вкладка `PurchasePlanningTab` переведена с локального хранения `UserDefaults` на сетевое состояние `authViewModel.shoppingLists`.
    - Изменен интерфейс `TinderCardView` — в него инкапсулированы кнопки крестика и галочки с программной анимацией сдвига и вращения карточки (с эффектом «улетания» влево/вправо и отображением наклеек «НАДО» / «НЕ НАДО»).
    - Полностью удален кастомный попап редактирования товара `editCardView`. Теперь нажатие на товар в саммари-списке переводит вью в режим редактирования одной карточки в `tinderSwipeView` с кнопкой «Назад» в тулбаре для возврата без сохранения.

### 5. Эксплуатация и исправление неполадок
При развертывании была решена проблема с ошибкой `503 Service Unavailable` бэкенда:
*   Для выполнения новой миграции `V11` из кластера Kubernetes была удалена старая неизменяемая задача `job.batch/db-controller`.
*   После повторного запуска Helm-чарта задача успешно применила миграцию к базе данных, создав таблицы.
*   Перезапущенный под `backend-service` прошел валидацию схемы таблиц Hibernate JPA и перешел в статус `Running`.

## Результаты
1. **Синхронизация списков**: Списки покупок домовладения теперь сохраняются и обновляются на бэкенде.
2. **Удобный UX**: Внедрен полноценный Tinder-интерфейс планирования покупок с согласованной анимацией свайпов и кликов и бесшовным редактированием карточек в том же стиле.
3. **Надежность инфраструктуры**: Налажена автоматическая работа схемы БД при обновлении сущностей.
