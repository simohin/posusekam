package ru.simohin.posusekam.db

import org.flywaydb.core.Flyway
import org.slf4j.LoggerFactory
import java.io.File
import java.util.Properties

fun main() {
    val logger = LoggerFactory.getLogger("DbMigrator")
    logger.info("Starting db-controller migration job...")

    // In Kubernetes with Vault Agent Injector, the secrets are rendered to a file.
    val vaultSecretPath = System.getenv("VAULT_SECRET_PATH") ?: "/vault/secrets/database"
    val vaultFile = File(vaultSecretPath)

    var jdbcUrl = System.getenv("DB_URL") ?: ""
    var dbUser = System.getenv("DB_USER") ?: ""
    var dbPassword = System.getenv("DB_PASSWORD") ?: ""

    if (vaultFile.exists()) {
        logger.info("Found Vault secrets file at $vaultSecretPath. Loading properties...")
        val props = Properties()
        vaultFile.inputStream().use { props.load(it) }
        
        props.getProperty("url")?.let { jdbcUrl = it }
        props.getProperty("username")?.let { dbUser = it }
        props.getProperty("password")?.let { dbPassword = it }
    } else {
        logger.info("Vault secrets file not found at $vaultSecretPath, using Environment Variables.")
    }

    if (jdbcUrl.isBlank() || dbUser.isBlank() || dbPassword.isBlank()) {
        logger.error("Missing database credentials. URL, USER, and PASSWORD must be provided.")
        System.exit(1)
    }

    logger.info("Connecting to Database: $jdbcUrl with user: $dbUser")

    try {
        val flyway = Flyway.configure()
            .dataSource(jdbcUrl, dbUser, dbPassword)
            .load()

        val result = flyway.migrate()
        if (result.success) {
            logger.info("Migration successful. Applied ${result.migrationsExecuted} migrations.")
            System.exit(0)
        } else {
            logger.error("Migration failed without exceptions.")
            System.exit(1)
        }
    } catch (e: Exception) {
        logger.error("Error during migration: ${e.message}", e)
        System.exit(1)
    }
}
