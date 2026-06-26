package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.ShoppingList
import java.util.UUID

@Repository
interface ShoppingListRepository : JpaRepository<ShoppingList, UUID> {
    fun findByHouseholdId(householdId: UUID): List<ShoppingList>
    fun findByHouseholdIdAndId(householdId: UUID, id: UUID): ShoppingList?
    fun findByHouseholdIdAndStoreId(householdId: UUID, storeId: UUID): List<ShoppingList>
}
