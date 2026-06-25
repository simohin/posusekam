package ru.simohin.posusekam.backend.service

import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import ru.simohin.posusekam.backend.repository.CategoryRepository
import ru.simohin.posusekam.backend.repository.HouseholdMemberRepository
import ru.simohin.posusekam.backend.repository.MeasureUnitRepository
import ru.simohin.posusekam.backendservice.dto.StoreProductsResponse
import java.util.UUID

@Service
class ProductGenerationService(
    private val householdMemberRepository: HouseholdMemberRepository,
    private val categoryRepository: CategoryRepository,
    private val measureUnitRepository: MeasureUnitRepository,
    private val aiService: AiService
) {
    fun generateProducts(
        householdId: UUID,
        userId: UUID,
        storeDescription: String,
        itemsCount: Int
    ): StoreProductsResponse {
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN, "User is not a member of this household")
        }

        val categories = categoryRepository.findByHouseholdId(householdId).map { it.name }
        val units = measureUnitRepository.findByHouseholdId(householdId).map { it.name }

        return aiService.generateProductsList(
            storeDescription = storeDescription,
            allowedCategories = categories,
            allowedUnits = units,
            itemsCount = itemsCount
        )
    }
}
