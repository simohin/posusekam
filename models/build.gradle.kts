plugins {
    kotlin("jvm")
    kotlin("plugin.jpa")
}

group = "ru.simohin.posusekam"
version = "0.0.1-SNAPSHOT"



dependencies {
    // Подключаем только JPA API для аннотаций @Entity, @Table, @Id и т.д.
    // Так модуль останется легким и не будет тянуть весь Spring Boot, если не нужно.
    api("jakarta.persistence:jakarta.persistence-api:3.1.0")
    
    // Аннотации Jackson для будущих DTO
    api("com.fasterxml.jackson.core:jackson-annotations:2.17.1")
}
