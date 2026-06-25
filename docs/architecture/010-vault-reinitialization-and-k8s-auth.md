# ADR 010: Переинициализация HashiCorp Vault, настройка Kubernetes Auth и ротация JWT ключей

## Статус
Реализовано

## Контекст
В результате утери ключей распечатывания (unseal keys) локального инстанса HashiCorp Vault в кластере `k3s`, зависимые сервисы (`auth-service`, `backend-service` и `db-controller`) не могли запуститься, так как Vault Agent Injector блокировал инициализацию подов из-за недоступности секретов. 

Требовалось:
1. Выполнить полную очистку и переустановку инстанса Vault с сохранением конфигурации Helm.
2. Провести инициализацию и распечатывание (unseal) свежего Vault.
3. Настроить заново метод аутентификации Kubernetes Auth.
4. Сгенерировать новые RSA-ключи для JWT и записать все необходимые секреты (БД, JWT, Google Client ID) в Vault.
5. Обеспечить корректный перезапуск и старт всех микросервисов.

## Решение

### 1. Переустановка и очистка Vault
*   Удален старый релиз Vault:
    ```bash
    helm uninstall vault -n vault
    ```
*   Удален Persistent Volume Claim (PVC) для полной очистки заблокированных данных:
    ```bash
    kubectl delete pvc data-vault-0 -n vault
    ```
*   Установлен чистый релиз Vault с использованием существующих настроек:
    ```bash
    helm upgrade --install vault hashicorp/vault -n vault -f infra/helm/third-party/vault/values.yaml
    ```

### 2. Инициализация и Unseal
*   Vault успешно инициализирован:
    ```bash
    kubectl exec -n vault vault-0 -- vault operator init -format=json
    ```
    Были получены 5 ключей распечатывания и Root Token. Данные сохранены в файл [`.env`](file:///Users/t.simokhin/IdeaProjects/posusekam/.env).
*   Выполнен unseal с применением первых 3 ключей:
    ```bash
    kubectl exec -n vault vault-0 -- vault operator unseal <KEY>
    ```
*   Включен secrets engine `kv-v2` по пути `secret/`:
    ```bash
    kubectl exec -n vault vault-0 -- env VAULT_TOKEN="..." vault secrets enable -path=secret kv-v2
    ```

### 3. Автоматизация Kubernetes Auth и политик
*   Обновлен и запущен скрипт [`infra/scripts/vault-auth-setup.sh`](file:///Users/t.simokhin/IdeaProjects/posusekam/infra/scripts/vault-auth-setup.sh):
    *   В скрипт добавлен автоматический импорт `VAULT_TOKEN` из `.env`.
    *   Создана политика доступа к БД `posusekam-db-read` и политика для работы с JWT/Google-аутентификацией `posusekam-auth-read`.
    *   Настроены три Kubernetes-роли в Vault:
        *   `db-migrator` (для ServiceAccount `db-migrator`) с доступом к `secret/data/posusekam/database`.
        *   `auth-service` (для ServiceAccount `auth-service`) с доступом к `secret/data/posusekam/auth-service`.
        *   `backend-service` (для ServiceAccount `backend-service`) с доступом к `secret/data/posusekam/auth-service` (только чтение публичного ключа для проверки подписи JWT).

### 4. Генерация ключей и запись секретов
*   Сгенерирована новая пара 2048-битных RSA-ключей для JWT:
    ```bash
    openssl genpkey -algorithm RSA -out /tmp/private.pem -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in /tmp/private.pem -out /tmp/public.pem
    ```
*   С помощью скрипта создана структура секрета и записана в Vault по пути `secret/data/posusekam/auth-service`:
    *   `private_key` — приватный ключ JWT.
    *   `public_key` — публичный ключ JWT.
    *   `google_client_id` — загружен из `.env`.
*   Записаны учетные данные базы данных по пути `secret/data/posusekam/database`:
    *   `url` — `jdbc:postgresql://192.168.0.106:5432/postgres` (обновлен по указанию пользователя).
    *   `username` — `posusekam`
    *   `password` — `47Gumito`
*   В конфигурационных файлах Helm [`auth-service/values.yaml`](file:///Users/t.simokhin/IdeaProjects/posusekam/infra/helm/apps/auth-service/values.yaml) и [`backend-service/values.yaml`](file:///Users/t.simokhin/IdeaProjects/posusekam/infra/helm/apps/backend-service/values.yaml) путь к БД также обновлен на `/postgres`.

### 5. Перезапуск и валидация
*   Выполнено обновление Helm-релизов и перезапуск деплойментов:
    ```bash
    kubectl delete job db-controller --ignore-not-found
    helm upgrade --install db-controller ./infra/helm/apps/db-controller
    helm upgrade --install auth-service ./infra/helm/apps/auth-service
    helm upgrade --install backend-service ./infra/helm/apps/backend-service
    ```
*   **Результаты запуска подов:**
    *   `db-controller-xzjkm` успешно запустился, прочитал учетные данные из Vault-файла `/vault/secrets/database` и применил все 8 миграций Flyway на базу данных `postgres`.
    *   `auth-service-7f9c5fd4fd-2wzpj` успешно стартанул (2/2 READY), примонтировал из Vault приватный и публичный RSA-ключи, а также `google_client_id` и успешно подключился к обновленной БД.
    *   `backend-service-5987c85775-m5znc` успешно запустился (2/2 READY), примонтировал публичный ключ для валидации JWT и подключился к БД.

## Результаты
*   Полностью восстановлена работоспособность инфраструктуры безопасности и секретов в кластере k3s.
*   Повышена безопасность за счет ротации JWT ключей.
*   Все поды приложений успешно функционируют и используют динамическую инжекцию секретов через Vault Agent Sidecars.
