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
import kotlinx.datetime.Clock

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
        val cachedString = settings.getStringOrNull("cached_metadata")
        val cacheTimestamp = settings.getLongOrNull("cached_metadata_time")
        val currentTime = Clock.System.now().toEpochMilliseconds()
        
        if (cachedString != null && cacheTimestamp != null) {
            val oneHourInMillis = 60 * 60 * 1000L
            if (currentTime - cacheTimestamp < oneHourInMillis) {
                try {
                    return json.decodeFromString<AppMetadataDto>(cachedString)
                } catch (e: Exception) {
                    println("KMP ERROR: Failed to decode cached metadata, will fetch fresh. Error: $e")
                }
            }
        }

        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/metadata") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            try {
                val metadata = json.decodeFromString<AppMetadataDto>(bodyText)
                // Cache it
                settings.putString("cached_metadata", bodyText)
                settings.putLong("cached_metadata_time", currentTime)
                return metadata
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
