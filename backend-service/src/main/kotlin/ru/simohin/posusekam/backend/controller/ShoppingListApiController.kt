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
import ru.simohin.posusekam.backend.repository.ShoppingListRepository
import ru.simohin.posusekam.backendservice.api.ShoppingListsApi
import ru.simohin.posusekam.backendservice.dto.CreateShoppingListRequest
import ru.simohin.posusekam.backendservice.dto.ShoppingListDto
import ru.simohin.posusekam.backendservice.dto.ShoppingListItemDto
import ru.simohin.posusekam.backendservice.dto.UpdateShoppingListRequest
import ru.simohin.posusekam.models.entity.ShoppingList
import ru.simohin.posusekam.models.entity.ShoppingListItem
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

@RestController
class ShoppingListApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val storeRepository: StoreRepository,
    private val shoppingListRepository: ShoppingListRepository
) : ShoppingListsApi {

    override fun listShoppingLists(householdId: UUID): ResponseEntity<List<ShoppingListDto>> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val lists = shoppingListRepository.findByHouseholdId(householdId)
        val dtos = lists.map { toDto(it) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createShoppingList(
        householdId: UUID,
        createShoppingListRequest: CreateShoppingListRequest
    ): ResponseEntity<ShoppingListDto> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val household = householdRepository.findById(householdId).orElse(null)
            ?: return ResponseEntity.status(HttpStatus.NOT_FOUND).build()

        val storeId = createShoppingListRequest.storeId
        val store = storeRepository.findByHouseholdIdAndId(householdId, storeId)
            ?: return ResponseEntity.status(HttpStatus.NOT_FOUND).build()

        // Создаем сам список
        val shoppingList = ShoppingList(
            household = household,
            store = store,
            completed = false
        )

        // Превращаем DTO-элементы в JPA-сущности
        val items = createShoppingListRequest.items.map { itemReq ->
            ShoppingListItem(
                shoppingList = shoppingList,
                name = itemReq.name,
                categoryName = itemReq.categoryName,
                amount = itemReq.amount,
                unit = itemReq.unit,
                bought = false
            )
        }
        shoppingList.items.addAll(items)

        val saved = shoppingListRepository.save(shoppingList)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun updateShoppingList(
        householdId: UUID,
        id: UUID,
        updateShoppingListRequest: UpdateShoppingListRequest
    ): ResponseEntity<ShoppingListDto> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val shoppingList = shoppingListRepository.findByHouseholdIdAndId(householdId, id)
            ?: return ResponseEntity.notFound().build()

        // Обновляем статус
        shoppingList.completed = updateShoppingListRequest.completed
        shoppingList.updatedAt = java.time.ZonedDateTime.now()

        // Синхронизируем элементы
        shoppingList.items.clear()
        val items = updateShoppingListRequest.items.map { itemReq ->
            ShoppingListItem(
                shoppingList = shoppingList,
                name = itemReq.name,
                categoryName = itemReq.categoryName,
                amount = itemReq.amount,
                unit = itemReq.unit,
                bought = false
            )
        }
        shoppingList.items.addAll(items)

        val saved = shoppingListRepository.save(shoppingList)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun deleteShoppingList(householdId: UUID, id: UUID): ResponseEntity<Void> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(householdId, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val shoppingList = shoppingListRepository.findByHouseholdIdAndId(householdId, id)
            ?: return ResponseEntity.notFound().build()

        shoppingListRepository.delete(shoppingList)
        return ResponseEntity.noContent().build()
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(shoppingList: ShoppingList): ShoppingListDto {
        val itemDtos = shoppingList.items.map { item ->
            ShoppingListItemDto()
                .id(item.id)
                .name(item.name)
                .categoryName(item.categoryName)
                .amount(item.amount)
                .unit(item.unit)
                .bought(item.bought)
        }

        return ShoppingListDto()
            .id(shoppingList.id)
            .householdId(shoppingList.household.id)
            .storeId(shoppingList.store.id)
            .completed(shoppingList.completed)
            .createdAt(shoppingList.createdAt?.let { OffsetDateTime.ofInstant(it.toInstant(), ZoneOffset.UTC) })
            .items(itemDtos)
    }
}
