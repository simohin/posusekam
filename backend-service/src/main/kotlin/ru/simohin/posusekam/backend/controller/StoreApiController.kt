package ru.simohin.posusekam.backend.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.repository.HouseholdMemberRepository
import ru.simohin.posusekam.backend.repository.HouseholdRepository
import ru.simohin.posusekam.backend.repository.StoreRepository
import ru.simohin.posusekam.backendservice.api.StoresApi
import ru.simohin.posusekam.backendservice.dto.CreateStoreRequest
import ru.simohin.posusekam.backendservice.dto.StoreDto
import ru.simohin.posusekam.backendservice.dto.UpdateStoreRequest
import ru.simohin.posusekam.models.entity.Store
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

@RestController
class StoreApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val storeRepository: StoreRepository
) : StoresApi {

    override fun listStores(householdId: UUID): ResponseEntity<List<StoreDto>> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val stores = storeRepository.findByHouseholdId(householdId)
        val dtos = stores.map { toDto(it) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createStore(householdId: UUID, createStoreRequest: CreateStoreRequest): ResponseEntity<StoreDto> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val household = householdRepository.findById(householdId).orElse(null)
            ?: return ResponseEntity.status(HttpStatus.NOT_FOUND).build()

        val store = Store(
            household = household,
            name = createStoreRequest.name,
            icon = createStoreRequest.icon,
            color = createStoreRequest.color
        )
        val saved = storeRepository.save(store)

        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun updateStore(householdId: UUID, id: UUID, updateStoreRequest: UpdateStoreRequest): ResponseEntity<StoreDto> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val store = storeRepository.findByHouseholdIdAndId(householdId, id)
            ?: return ResponseEntity.notFound().build()

        store.name = updateStoreRequest.name
        store.icon = updateStoreRequest.icon
        store.color = updateStoreRequest.color
        val saved = storeRepository.save(store)

        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun deleteStore(householdId: UUID, id: UUID): ResponseEntity<Void> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val store = storeRepository.findByHouseholdIdAndId(householdId, id)
            ?: return ResponseEntity.notFound().build()

        storeRepository.delete(store)
        return ResponseEntity.noContent().build()
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(store: Store): StoreDto {
        return StoreDto()
            .id(store.id)
            .name(store.name)
            .householdId(store.household.id)
            .icon(store.icon)
            .color(store.color)
            .createdAt(store.createdAt?.let { OffsetDateTime.ofInstant(it.toInstant(), ZoneOffset.UTC) })
    }
}
