package ru.simohin.posusekam.metadata

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.*
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import com.russhwolf.settings.Settings

class MetadataRepository(
    private val baseUrl: String = "https://dev.simohin.ru"
) {
    private val settings: Settings = Settings()
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = HttpClient {
        install(ContentNegotiation) {
            json(json)
        }
        install(Logging) {
            level = LogLevel.ALL
        }
    }

    private fun getAccessToken(): String? = settings.getStringOrNull("access_token")

    @Throws(Exception::class)
    suspend fun getMetadata(): AppMetadataDto {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/metadata") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            try {
                return json.decodeFromString<AppMetadataDto>(bodyText)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode metadata. Body was: $bodyText")
                println("KMP ERROR: Exception: $e")
                throw e
            }
        } else {
            throw Exception("Failed to fetch metadata: ${response.status}")
        }
    }
}
