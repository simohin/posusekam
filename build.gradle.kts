plugins {
    kotlin("jvm") version "2.0.0" apply false
    kotlin("plugin.spring") version "2.0.0" apply false
    kotlin("plugin.jpa") version "2.0.0" apply false
    id("org.springframework.boot") version "3.3.0" apply false
    id("io.spring.dependency-management") version "1.1.5" apply false
    id("org.openapi.generator") version "7.5.0" apply false
    
    // Kotlin Multiplatform & Android plugins from version catalog
    alias(libs.plugins.kotlin.multiplatform) apply false
    alias(libs.plugins.android.kmp.library) apply false
    alias(libs.plugins.android.application) apply false
    id("com.android.library") version "8.5.0" apply false
    alias(libs.plugins.kotlinx.serialization) apply false
    alias(libs.plugins.buildConfig) apply false
    alias(libs.plugins.maven.publish) apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://repo.spring.io/milestone") }
    }
}
