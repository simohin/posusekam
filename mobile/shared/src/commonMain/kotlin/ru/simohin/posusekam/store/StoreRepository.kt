package ru.simohin.posusekam.store

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

class StoreRepository(
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
    suspend fun getStores(householdId: String): List<Store> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/$householdId/stores") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            try {
                return json.decodeFromString<List<Store>>(bodyText)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode stores. Body was: $bodyText")
                println("KMP ERROR: Exception: $e")
                throw e
            }
        } else {
            throw Exception("Failed to fetch stores: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createStore(householdId: String, name: String, icon: String? = null, color: String? = null): Store {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/$householdId/stores") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateStoreRequest(name = name, icon = icon, color = color))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            try {
                return json.decodeFromString<Store>(bodyText)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode created store. Body was: $bodyText")
                println("KMP ERROR: Exception: $e")
                throw e
            }
        } else {
            throw Exception("Failed to create store: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun updateStore(householdId: String, id: String, name: String, icon: String? = null, color: String? = null): Store {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.put("$baseUrl/api/v1/$householdId/stores/$id") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(UpdateStoreRequest(name = name, icon = icon, color = color))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            try {
                return json.decodeFromString<Store>(bodyText)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode updated store. Body was: $bodyText")
                println("KMP ERROR: Exception: $e")
                throw e
            }
        } else {
            throw Exception("Failed to update store: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun deleteStore(householdId: String, id: String) {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.delete("$baseUrl/api/v1/$householdId/stores/$id") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value !in 200..299) {
            throw Exception("Failed to delete store: ${response.status}")
        }
    }
}
