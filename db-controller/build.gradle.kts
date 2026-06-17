plugins {
    kotlin("jvm") version "2.0.0"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.flywaydb:flyway-core:10.15.2")
    implementation("org.flywaydb:flyway-database-postgresql:10.15.2")
    implementation("org.postgresql:postgresql:42.7.3")
    implementation("ch.qos.logback:logback-classic:1.5.6")
}

application {
    mainClass.set("ru.simohin.posusekam.db.MainKt")
}
