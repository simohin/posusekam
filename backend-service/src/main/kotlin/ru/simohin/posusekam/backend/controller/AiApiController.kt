package ru.simohin.posusekam.backend.controller

import org.springframework.beans.factory.annotation.Value
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.service.AiService
import ru.simohin.posusekam.backend.service.ProductCategory
import ru.simohin.posusekam.backend.service.ProductMeasureUnit
import ru.simohin.posusekam.backendservice.api.AiApi
import ru.simohin.posusekam.backendservice.dto.GenerateProductsRequest
import ru.simohin.posusekam.backendservice.dto.StoreProductsResponse

@RestController
class AiApiController(
    private val aiService: AiService,
    @Value("\${posusekam.ai.default-items-count:4}") private val defaultItemsCount: Int
) : AiApi {

    override fun generateProducts(
        generateProductsRequest: GenerateProductsRequest
    ): ResponseEntity<StoreProductsResponse> {
        // 1. Определяем количество товаров (из запроса или дефолтное из конфига)
        val itemsCount = generateProductsRequest.itemsCount ?: defaultItemsCount

        // 2. Подставляем все значения из enum (пользователь их не передает)
        val allowedCategories = ProductCategory.entries
        val allowedUnits = ProductMeasureUnit.entries

        // 3. Вызываем бизнес-слой генерации
        val result = aiService.generateProductsList(
            storeDescription = generateProductsRequest.storeDescription,
            allowedCategories = allowedCategories,
            allowedUnits = allowedUnits,
            itemsCount = itemsCount
        )

        return ResponseEntity.ok(result)
    }
}
