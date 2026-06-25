package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.Product
import java.util.UUID

@Repository
interface ProductRepository : JpaRepository<Product, UUID> {
    fun findByStoreId(storeId: UUID): List<Product>
    fun findByHouseholdIdAndStoreId(householdId: UUID, storeId: UUID): List<Product>
}
