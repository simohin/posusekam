package ru.simohin.posusekam.household

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

class HouseholdRepository(
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
    suspend fun getHouseholds(): List<Household> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/households") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value in 200..299) {
            return json.decodeFromString<List<Household>>(response.bodyAsText())
        } else {
            throw Exception("Failed to fetch households: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createHousehold(name: String, icon: String? = null): Household {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/households") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateHouseholdRequest(name, icon))
        }
        if (response.status.value in 200..299) {
            return json.decodeFromString<Household>(response.bodyAsText())
        } else {
            throw Exception("Failed to create household: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun updateHousehold(id: String, name: String, icon: String? = null): Household {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.put("$baseUrl/api/v1/households/$id") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(UpdateHouseholdRequest(name, icon))
        }
        if (response.status.value in 200..299) {
            return json.decodeFromString<Household>(response.bodyAsText())
        } else {
            throw Exception("Failed to update household: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun deleteHousehold(id: String) {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.delete("$baseUrl/api/v1/households/$id") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value !in 200..299) {
            throw Exception("Failed to delete household: ${response.status}")
        }
    }
}
