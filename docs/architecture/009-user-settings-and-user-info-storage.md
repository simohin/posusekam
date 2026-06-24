# ADR 009: Механизм динамических настроек и информации о пользователе (UserSettings и UserInfo)

## Статус
Реализовано

## Контекст
В рамках расширения возможностей профиля пользователя и кастомизации интерфейса возникла необходимость реализовать:
1. **Динамические настройки (`UserSettings`):** Способность пользователя сохранять настройки интерфейса и поведения приложения (например, скрыть приветственную карточку «Управление покупками» прямо на главном экране) с синхронизацией по сети и локальным кэшированием для быстрой работы при запуске (offline-first). Также требовалась функция полного сброса настроек с удалением записи на сервере.
2. **Динамический профиль (`UserInfo`):** Возможность собирать и хранить детальные данные профиля пользователя, предоставляемые провайдерами авторизации (имя, фамилия, отображаемое имя, ссылка на аватарку), в формате, совместимом с Google, Apple и Telegram.

## Решение

### 1. Бэкенд и База данных (Spring Boot + PostgreSQL)
*   Созданы Flyway миграции:
    *   `V7__Create_User_Settings.sql` — таблица `user_settings` (колонки `user_id` UUID PK, `settings` JSONB).
    *   `V8__Create_User_Info.sql` — таблица `user_info` (колонки `user_id` UUID PK, `info` JSONB).
*   В модуле `models` реализованы JPA-сущности `UserSettings` и `UserInfo` с использованием Jackson `JsonMapConverter` для автоматического маппинга JSONB в `Map<String, Any>`.
*   В OpenAPI-спецификацию добавлены эндпоинты `/v1/settings` (GET, PUT, PATCH, DELETE) и `/v1/user-info` (GET, PUT, PATCH).
*   В `backend-service` реализованы соответствующие контроллеры (`SettingsApiController` и `UserInfoApiController`). PATCH-запросы поддерживают слияние (merge) JSON-объектов. DELETE-запрос для настроек удаляет строку из БД (сброс к дефолту).
*   В `auth-service` в [AuthApiController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/auth-service/src/main/kotlin/ru/simohin/posusekam/auth/controller/AuthApiController.kt) добавлено автозаполнение/обновление таблицы `user_info` при входе/регистрации через Google на основе данных из ID токена (`given_name`, `family_name`, `name`, `picture`).

### 2. Клиентский KMP Shared-модуль
*   В пакете `settings` созданы сериализуемый класс `UserSettings` (с полем `hidePurchaseManagement`) и репозиторий [SettingsRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/settings/SettingsRepository.kt).
*   В пакете `userinfo` созданы класс `UserInfo` и репозиторий [UserInfoRepository.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/shared/src/commonMain/kotlin/ru/simohin/posusekam/userinfo/UserInfoRepository.kt).
*   Оба репозитория реализуют offline-first кэширование через мультиплатформенную библиотеку `Settings` (сохраняющую данные в `NSUserDefaults` на iOS).
*   Оба репозитория предоставляют колбэки `observeSettings` / `observeUserInfo` для удобного и потокобезопасного наблюдения за изменениями реактивного `StateFlow` из Swift-кода.

### 3. SwiftUI iOS Приложение
*   [AuthViewModel.swift](file:///Users/t.simokhin/IdeaProjects/posusekam/mobile/iosApp/iosApp/AuthViewModel.swift) обновлен для наблюдения за `UserSettings` и `UserInfo`. Загрузка данных с сервера происходит при запуске и при логине. При входе через Google данные профиля извлекаются из SDK Google Sign-In и сразу синхронизируются на бэкенд.
*   **Главная страница (`OverviewTab`):**
    *   Информационная карточка «Управление покупками» скрывается, если флаг `hidePurchaseManagement` равен `true`.
    *   На карточку добавлены кнопка «крестик» (сверху-справа) и текстовая кнопка «Не показывать больше». Обе кнопки вызывают `updateHidePurchaseManagement(hide: true)`, что мгновенно скрывает карточку и отправляет PUT-запрос.
*   **Профиль пользователя (`ProfileView`):**
    *   Аватар и имя пользователя теперь в первую очередь отображаются из динамического `UserInfo` (с падением на JWT `userProfile`, если данные еще не подгрузились).
    *   Имя форматируется автоматически из `displayName` или комбинации `firstName + lastName`.
    *   Добавлена кнопка «Сбросить настройки» красного цвета. Она вызывает `resetUserSettings()`, которая очищает локальный кэш, удаляет запись из базы данных на сервере и выводит всплывающее подтверждение (`SwiftUI Alert`).

## Результаты
*   Реализована гибкая и масштабируемая система настроек и профилей на базе динамического JSONB на бэкенде.
*   Достигнут отзывчивый UX: локальное кэширование предотвращает "моргание" интерфейса при запуске, а изменения синхронизируются в фоне.
*   Обеспечена совместимость с будущими провайдерами авторизации (Apple, Telegram).
*   Все сервисы успешно задеплоены и работают в локальном кластере k3s.
