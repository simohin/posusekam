package ru.simohin.posusekam.backend.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException
import ru.simohin.posusekam.backend.repository.*
import ru.simohin.posusekam.backendservice.api.ProductsApi
import ru.simohin.posusekam.backendservice.dto.*
import ru.simohin.posusekam.models.entity.Product
import java.util.UUID

@RestController
class ProductApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val storeRepository: StoreRepository,
    private val productRepository: ProductRepository,
    private val categoryRepository: CategoryRepository
) : ProductsApi {

    override fun listProducts(householdId: UUID, storeId: UUID): ResponseEntity<List<ProductDto>> {
        checkMembership(householdId)
        val products = productRepository.findByHouseholdIdAndStoreId(householdId, storeId)
        val dtos = products.map { toDto(it) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createProduct(
        householdId: UUID,
        storeId: UUID,
        createProductRequest: CreateProductRequest
    ): ResponseEntity<ProductDto> {
        checkMembership(householdId)
        val household = householdRepository.findById(householdId).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Household not found")
        val store = storeRepository.findById(storeId).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Store not found")
        if (store.household.id != householdId) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Store does not belong to this household")
        }

        val categories = createProductRequest.categoryIds?.map { categoryId ->
            val cat = categoryRepository.findById(categoryId).orElse(null)
                ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Category $categoryId not found")
            if (cat.household.id != householdId) {
                throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Category $categoryId does not belong to this household")
            }
            cat
        }?.toMutableSet() ?: mutableSetOf()

        val product = Product(
            household = household,
            store = store,
            name = createProductRequest.name,
            unit = createProductRequest.unit,
            categories = categories
        )
        val saved = productRepository.save(product)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun updateProduct(
        householdId: UUID,
        storeId: UUID,
        id: UUID,
        updateProductRequest: UpdateProductRequest
    ): ResponseEntity<ProductDto> {
        checkMembership(householdId)
        val product = productRepository.findById(id).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found")
        if (product.household.id != householdId || product.store?.id != storeId) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Product does not belong to this household/store")
        }

        val categories = updateProductRequest.categoryIds?.map { categoryId ->
            val cat = categoryRepository.findById(categoryId).orElse(null)
                ?: throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Category $categoryId not found")
            if (cat.household.id != householdId) {
                throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Category $categoryId does not belong to this household")
            }
            cat
        }?.toMutableSet() ?: mutableSetOf()

        product.name = updateProductRequest.name
        product.unit = updateProductRequest.unit
        product.categories = categories

        val saved = productRepository.save(product)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun deleteProduct(householdId: UUID, storeId: UUID, id: UUID): ResponseEntity<Void> {
        checkMembership(householdId)
        val product = productRepository.findById(id).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found")
        if (product.household.id != householdId || product.store?.id != storeId) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Product does not belong to this household/store")
        }
        productRepository.delete(product)
        return ResponseEntity.noContent().build()
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

    private fun toDto(product: Product): ProductDto {
        return ProductDto().apply {
            id = product.id
            name = product.name
            unit = product.unit
            categories = product.categories.map { category ->
                CategoryDto().apply {
                    id = category.id
                    name = category.name
                    icon = category.icon
                }
            }
        }
    }
}
