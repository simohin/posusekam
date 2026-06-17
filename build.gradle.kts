plugins {
    kotlin("jvm") version "2.0.0" apply false
    kotlin("plugin.spring") version "2.0.0" apply false
    kotlin("plugin.jpa") version "2.0.0" apply false
    id("org.springframework.boot") version "3.3.0" apply false
    id("io.spring.dependency-management") version "1.1.5" apply false
    id("org.openapi.generator") version "7.5.0" apply false
}

allprojects {
    repositories {
        mavenCentral()
    }
}
