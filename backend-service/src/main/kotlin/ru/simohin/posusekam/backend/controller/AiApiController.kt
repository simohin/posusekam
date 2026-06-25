package ru.simohin.posusekam.backend.controller

import org.springframework.beans.factory.annotation.Value
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.service.ProductGenerationService
import ru.simohin.posusekam.backendservice.api.AiApi
import ru.simohin.posusekam.backendservice.dto.GenerateProductsRequest
import ru.simohin.posusekam.backendservice.dto.StoreProductsResponse
import java.util.UUID

@RestController
class AiApiController(
    private val productGenerationService: ProductGenerationService,
    @param:Value("\${posusekam.ai.default-items-count:4}") private val defaultItemsCount: Int
) : AiApi {

    override fun generateProducts(
        generateProductsRequest: GenerateProductsRequest
    ): ResponseEntity<StoreProductsResponse> {
        val userId = getAuthenticatedUserId()
        val itemsCount = generateProductsRequest.itemsCount ?: defaultItemsCount

        val result = productGenerationService.generateProducts(
            householdId = generateProductsRequest.householdId,
            userId = userId,
            storeDescription = generateProductsRequest.storeDescription,
            itemsCount = itemsCount
        )

        return ResponseEntity.ok(result)
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }
}
