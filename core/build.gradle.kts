plugins {
    kotlin("jvm")
}

dependencies {
    // Выносим сюда общие зависимости, которые нужны всем микросервисам
    api("io.swagger.core.v3:swagger-annotations:2.2.21")
    api("jakarta.validation:jakarta.validation-api:3.0.2")
    api("org.openapitools:jackson-databind-nullable:0.2.6")
}
