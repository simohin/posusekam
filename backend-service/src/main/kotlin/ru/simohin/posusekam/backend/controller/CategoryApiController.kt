package ru.simohin.posusekam.backend.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException
import ru.simohin.posusekam.backend.repository.CategoryRepository
import ru.simohin.posusekam.backend.repository.HouseholdMemberRepository
import ru.simohin.posusekam.backend.repository.HouseholdRepository
import ru.simohin.posusekam.backendservice.api.CategoriesApi
import ru.simohin.posusekam.backendservice.dto.CategoryDto
import ru.simohin.posusekam.backendservice.dto.CreateCategoryRequest
import ru.simohin.posusekam.models.entity.Category
import java.util.UUID

@RestController
class CategoryApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val categoryRepository: CategoryRepository
) : CategoriesApi {

    override fun listCategories(householdId: UUID): ResponseEntity<List<CategoryDto>> {
        checkMembership(householdId)
        val categories = categoryRepository.findByHouseholdId(householdId)
        val dtos = categories.map { toDto(it) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createCategory(
        householdId: UUID,
        createCategoryRequest: CreateCategoryRequest
    ): ResponseEntity<CategoryDto> {
        checkMembership(householdId)
        val household = householdRepository.findById(householdId).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Household not found")

        val category = Category(
            household = household,
            name = createCategoryRequest.name,
            icon = createCategoryRequest.icon
        )
        val saved = categoryRepository.save(category)
        return ResponseEntity.ok(toDto(saved))
    }

    private fun checkMembership(householdId: UUID) {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            throw ResponseStatusException(HttpStatus.FORBIDDEN, "User is not a member of this household")
        }
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(category: Category): CategoryDto {
        return CategoryDto().apply {
            id = category.id
            name = category.name
            icon = category.icon
        }
    }
}
