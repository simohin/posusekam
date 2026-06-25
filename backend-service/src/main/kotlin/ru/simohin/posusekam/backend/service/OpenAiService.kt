package ru.simohin.posusekam.backend.service

import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.client.RestClient
import ru.simohin.posusekam.backend.repository.OpenAiPromptRepository
import ru.simohin.posusekam.models.entity.PromptName
import ru.simohin.posusekam.backendservice.dto.StoreProductsResponse

@Service
class OpenAiService(
    private val promptRepository: OpenAiPromptRepository,
    private val objectMapper: ObjectMapper,
    @Value("\${spring.ai.openai.api-key}") private val apiKey: String
) : AiService {

    private val restClient: RestClient by lazy {
        RestClient.builder()
            .baseUrl("https://api.openai.com/v1")
            .defaultHeader("Authorization", "Bearer $apiKey")
            .defaultHeader("Content-Type", "application/json")
            .build()
    }

    override fun generateProductsList(
        storeDescription: String,
        allowedCategories: List<String>,
        allowedUnits: List<String>,
        itemsCount: Int
    ): StoreProductsResponse {
        // 1. Извлекаем промпт из БД по имени
        val promptMetadata = promptRepository.findByName(PromptName.GENERATE_PRODUCTS_LIST)
            ?: throw IllegalStateException("Prompt metadata for 'generate_products_list' not found in database.")

        // 2. Сериализуем списки параметров в JSON-строки для переменных OpenAI
        val categoriesJson = objectMapper.writeValueAsString(allowedCategories)
        val unitsJson = objectMapper.writeValueAsString(allowedUnits)

        val variables = mapOf(
            "allowed_categories" to categoriesJson,
            "allowed_units" to unitsJson,
            "items_count" to itemsCount.toString()
        )

        // 3. Выполняем запрос к OpenAI Responses API (версия 4)
        val requestBody = OpenAiResponseRequest(
            prompt = OpenAiPromptPayload(
                id = promptMetadata.id,
                version = promptMetadata.version,
                variables = variables
            ),
            input = listOf(
                OpenAiInputMessage(
                    role = "user",
                    content = storeDescription
                )
            )
        )

        val response = restClient.post()
            .uri("/responses")
            .body(requestBody)
            .retrieve()
            .body(OpenAiResponse::class.java)
            ?: throw RuntimeException("Received empty response from OpenAI Responses API")

        // 4. Извлекаем сгенерированный текст
        val jsonText = response.output
            ?.firstOrNull { it.type == "message" }
            ?.content
            ?.firstOrNull { it.type == "output_text" }
            ?.text
            ?: throw RuntimeException("Failed to extract text from OpenAI response. Response details: $response")

        // 5. Десериализуем его в структурированный DTO ответа
        return objectMapper.readValue(jsonText, StoreProductsResponse::class.java)
    }
}

// DTO для работы с OpenAI Responses API
private data class OpenAiResponseRequest(
    val prompt: OpenAiPromptPayload,
    val input: List<OpenAiInputMessage>
)

private data class OpenAiPromptPayload(
    val id: String,
    val version: String,
    val variables: Map<String, String>
)

private data class OpenAiInputMessage(
    val role: String,
    val content: String
)

private data class OpenAiResponse(
    val id: String?,
    @JsonProperty("object")
    val objectName: String?,
    val status: String?,
    val output: List<OpenAiOutputItem>?
)

private data class OpenAiOutputItem(
    val id: String?,
    val type: String?,
    val status: String?,
    val content: List<OpenAiContentItem>?
)

private data class OpenAiContentItem(
    val type: String?,
    val text: String?
)
