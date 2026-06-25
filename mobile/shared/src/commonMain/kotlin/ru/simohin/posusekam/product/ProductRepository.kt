package ru.simohin.posusekam.product

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

@Serializable
data class AiProduct(
    val name: String,
    val measureUnit: String,
    val category: String,
    val description: String? = null
)

@Serializable
data class StoreProductsResponse(
    val store_type: String,
    val products: List<AiProduct>
)

@Serializable
data class GenerateProductsRequest(
    val storeDescription: String,
    val householdId: String,
    val itemsCount: Int? = null
)

class ProductRepository(
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
    suspend fun getProducts(householdId: String, storeId: String): List<Product> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/$householdId/stores/$storeId/products") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<List<Product>>(bodyText)
        } else {
            throw Exception("Failed to fetch products: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createProduct(
        householdId: String,
        storeId: String,
        name: String,
        unit: String,
        categoryIds: List<String>? = null
    ): Product {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/$householdId/stores/$storeId/products") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateProductRequest(name = name, unit = unit, categoryIds = categoryIds))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<Product>(bodyText)
        } else {
            throw Exception("Failed to create product: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun updateProduct(
        householdId: String,
        storeId: String,
        id: String,
        name: String,
        unit: String,
        categoryIds: List<String>? = null
    ): Product {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.put("$baseUrl/api/v1/$householdId/stores/$storeId/products/$id") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(UpdateProductRequest(name = name, unit = unit, categoryIds = categoryIds))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<Product>(bodyText)
        } else {
            throw Exception("Failed to update product: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun deleteProduct(householdId: String, storeId: String, id: String) {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.delete("$baseUrl/api/v1/$householdId/stores/$storeId/products/$id") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value !in 200..299) {
            throw Exception("Failed to delete product: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun getCategories(householdId: String): List<Category> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/$householdId/categories") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<List<Category>>(bodyText)
        } else {
            throw Exception("Failed to fetch categories: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createCategory(householdId: String, name: String, icon: String? = null): Category {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/$householdId/categories") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateCategoryRequest(name = name, icon = icon))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<Category>(bodyText)
        } else {
            throw Exception("Failed to create category: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun getMeasureUnits(householdId: String): List<MeasureUnit> {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.get("$baseUrl/api/v1/$householdId/measure-units") {
            header("Authorization", "Bearer $token")
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<List<MeasureUnit>>(bodyText)
        } else {
            throw Exception("Failed to fetch measure units: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun createMeasureUnit(householdId: String, name: String): MeasureUnit {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/$householdId/measure-units") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(CreateMeasureUnitRequest(name = name))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<MeasureUnit>(bodyText)
        } else {
            throw Exception("Failed to create measure unit: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun generateProducts(storeDescription: String, householdId: String, itemsCount: Int): StoreProductsResponse {
        val token = getAccessToken() ?: throw Exception("Unauthorized: No access token")
        val response = client.post("$baseUrl/api/v1/ai/generate-products") {
            contentType(ContentType.Application.Json)
            header("Authorization", "Bearer $token")
            setBody(GenerateProductsRequest(storeDescription = storeDescription, householdId = householdId, itemsCount = itemsCount))
        }
        val bodyText = response.bodyAsText()
        if (response.status.value in 200..299) {
            return json.decodeFromString<StoreProductsResponse>(bodyText)
        } else {
            throw Exception("Failed to generate products: ${response.status}")
        }
    }
}
