plugins {
    kotlin("jvm")
    kotlin("plugin.spring")
    kotlin("plugin.jpa")
    id("org.springframework.boot")
    id("io.spring.dependency-management")
    id("org.openapi.generator")
}

// Применяем нашу общую логику генерации из core модуля
apply(from = project(":core").file("openapi-config.gradle"))

group = "ru.simohin.posusekam"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}



dependencies {
    // Базовые стартеры для веба и безопасности
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    
    // Spring Data JPA для работы с БД (самый стандартный и простой путь для MVP)
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.postgresql:postgresql")
    
    // Стандартная поддержка JWT (используем встроенный в Spring Security Nimbus)
    implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
    
    // Официальный клиент Google для быстрой проверки id_token "из коробки"
    implementation("com.google.api-client:google-api-client:2.4.0")

    // Поддержка Kotlin в Jackson
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")

    // Модуль с нашими Entity и DTO
    implementation(project(":models"))
    
    // Core модуль с базовыми зависимостями (Swagger аннотации и др.)
    implementation(project(":core"))

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
    testRuntimeOnly("com.h2database:h2")
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    dependsOn("openApiGenerate")
    kotlinOptions {
        freeCompilerArgs += "-Xjsr305=strict"
        jvmTarget = "21"
    }
}
