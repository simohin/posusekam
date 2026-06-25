package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.MeasureUnit
import java.util.UUID

@Repository
interface MeasureUnitRepository : JpaRepository<MeasureUnit, UUID> {
    fun findByHouseholdId(householdId: UUID): List<MeasureUnit>
}
