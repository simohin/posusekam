package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.Category
import java.util.UUID

@Repository
interface CategoryRepository : JpaRepository<Category, UUID> {
    fun findByHouseholdId(householdId: UUID): List<Category>
}
