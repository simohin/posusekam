# ADR 003: Архитектура авторизации (API-First Token Exchange)

## Статус
Реализовано

## Контекст
Основной клиент — мобильное приложение Kotlin Multiplatform (iOS, Android). В перспективе — Web SPA. Необходима поддержка авторизации через Apple, Google и Telegram. Приложение должно строиться по микросервисной архитектуре (Spring Cloud).

## Решение
Выбран подход **"Token Exchange"** с разработкой собственного `auth-service` на Spring Boot.

### Поток данных:
1. Мобильные клиенты используют нативные SDK (Google Sign-In, Sign in with Apple) для авторизации на устройстве и получения внешнего `id_token`.
2. Клиент отправляет полученный токен в `auth-service` через REST API (`POST /auth/v1/google`).
3. `auth-service` криптографически проверяет токен с помощью официального `GoogleIdTokenVerifier`.
4. Если пользователь валиден, `auth-service` регистрирует его в БД (или обновляет существующий профиль) и выпускает собственный внутренний JWT (Access + Refresh).
5. Все внутренние микросервисы доверяют только нашему внутреннему JWT, выступая в роли **OAuth2 Resource Server**.

### Безопасность и хранение ключей подписи и настроек (Vault):
1. RSA-ключи (приватный и публичный) для генерации JWT-токенов, а также `google_client_id` хранятся в HashiCorp Vault по пути `secret/posusekam/auth-service`.
2. В K3s настроен **Vault Agent Injector**, который с помощью аннотаций монтирует эти секреты в под:
   - Ключи по путям `/vault/secrets/private.pem` и `/vault/secrets/public.pem`.
   - Свойства в файл `/vault/secrets/application.properties` (например, `posusekam.google.client-id`).
3. Приложение автоматически загружает эти секреты при запуске с помощью `spring.config.import: "optional:file:/vault/secrets/application.properties"` в `application.yml`.
4. Для локальной разработки используются временные ключи в `auth-service/src/main/resources/certs/` (директория добавлена в `.gitignore`) и значения по умолчанию.

### Преимущества:
- Идеальный нативный UX для iOS/Android без редиректов в браузер.
- Единый подход для Web (One Tap) и KMP.
- Полный контроль над специфичной интеграцией Telegram (валидация HMAC).
- Безопасное хранение ключевой информации в Vault без жесткого кодирования секретов в IaC.

