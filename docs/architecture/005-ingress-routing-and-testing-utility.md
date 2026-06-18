# ADR 005: Глобальный роутинг Ingress и инструмент тестирования (Test Login)

## Статус
Реализовано

## Контекст
1. Ранее каждый сервис генерировал собственный Ingress-ресурс через Helm-чарты. Это затрудняло централизованное управление SSL-сертификатами (Let's Encrypt), CORS, редиректами и маршрутизацией через единый входной узел (Edge).
2. Для проверки интеграции Google Sign-In в реальной среде (K3s) требовался удобный инструмент тестирования, позволяющий наглядно увидеть прохождение авторизационных потоков (как Redirect Flow для получения Auth Code, так и Credential Flow для получения ID Token) прямо в браузере.

## Решение
Приняты следующие архитектурные решения:

### 1. Переход на глобальный Edge Ingress
* **Отключение встроенных ингрессов:** В `values.yaml` Helm-чарта `auth-service` отключена генерация локального Ingress (`ingress.enabled: false`).
* **Глобальный роутер:** Создан централизованный внешний манифест [dev-ingress.yaml](file:///Users/t.simokhin/IdeaProjects/k3s_config/dev-ingress.yaml) (ресурс `global-edge-router`), обслуживающий домен `dev.simohin.ru`.
* **Автоматический SSL/TLS:** Маршрутизация привязана строго к HTTPS-порту 443 (`websecure`). Для автоматического выпуска и продления доверенного SSL-сертификата от Let's Encrypt используется аннотация `cert-manager.io/cluster-issuer: "letsencrypt-prod"`.

### 2. Внедрение утилиты тестирования (Test Login Page)
* **Контроллер:** В модуль `auth-service` добавлен [TestLoginController.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/auth-service/src/main/kotlin/ru/simohin/posusekam/auth/controller/TestLoginController.kt), обслуживающий эндпоинт `/test-login` (полный путь `/auth/test-login`).
* **Безопасность:** В [SecurityConfig.kt](file:///Users/t.simokhin/IdeaProjects/posusekam/auth-service/src/main/kotlin/ru/simohin/posusekam/auth/config/SecurityConfig.kt) добавлен публичный доступ к `/test-login` без авторизации:
  ```kotlin
  .requestMatchers("/v1/google", "/test-login").permitAll()
  ```
* **Интерфейс и потоки:** Страница возвращает адаптивный темный интерфейс (с использованием Google Fonts и CSS-переменных), поддерживающий два флоу:
  1. **OAuth2 Code Flow (Redirect):** Генерирует ссылку на вход Google с указанием нашего `client_id` и динамического `redirect_uri` (`https://dev.simohin.ru/auth/test-login`), после редиректа перехватывает и выводит на экран параметр `code`.
  2. **Credential Flow (ID Token):** Рендерит кнопку Google Sign-In, получает `id_token` от Google API, декодирует его структуру, отправляет POST-запрос на `/auth/v1/google` и выводит итоговый ответ бэкенда с внутренними JWT (`accessToken`, `refreshToken`).

## Последствия
* **Удобство разработки:** Появилась песочница для быстрой проверки изменений в логике авторизации без необходимости запуска мобильного клиента.
* **Централизованный трафик:** Вся маршрутизация теперь описана в одном месте, исключая конфликты портов и доменов между релизами Helm.
* **Полноценный SSL/TLS:** Трафик шифруется легитимным сертификатом Let's Encrypt, что предотвращает блокировки запросов со стороны Google SDK и браузеров.
