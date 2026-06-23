package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.Store
import java.util.UUID

@Repository
interface StoreRepository : JpaRepository<Store, UUID> {
    fun findByHouseholdId(householdId: UUID): List<Store>
    fun findByHouseholdIdAndId(householdId: UUID, id: UUID): Store?
}
