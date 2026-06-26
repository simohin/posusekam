package ru.simohin.posusekam.shoppinglist

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
import kotlinx.serialization.Serializable

class ShoppingListRepository(
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
    suspend fun getShoppingLists(householdId: String): List<ShoppingList> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/$householdId/shopping-lists") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<List<ShoppingList>>(bodyText)
        } else {
            throw Exception("Failed to fetch shopping lists: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createShoppingList(
        householdId: String,
        storeId: String,
        items: List<CreateShoppingListItemRequest>
    ): ShoppingList {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/$householdId/shopping-lists") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateShoppingListRequest(storeId = storeId, items = items))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<ShoppingList>(bodyText)
        } else {
            throw Exception("Failed to create shopping list: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun updateShoppingList(
        householdId: String,
        id: String,
        completed: Boolean,
        items: List<CreateShoppingListItemRequest>
    ): ShoppingList {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.put("$baseUrl/api/v1/$householdId/shopping-lists/$id") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(UpdateShoppingListRequest(completed = completed, items = items))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<ShoppingList>(bodyText)
        } else {
            throw Exception("Failed to update shopping list: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun deleteShoppingList(householdId: String, id: String) {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.delete("$baseUrl/api/v1/$householdId/shopping-lists/$id") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value !in 200..299) {
            throw Exception("Failed to delete shopping list: ${response.status}")
        }
    }
}
