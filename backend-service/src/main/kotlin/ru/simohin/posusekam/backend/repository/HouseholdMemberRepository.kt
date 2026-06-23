package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.HouseholdMember
import java.util.UUID

@Repository
interface HouseholdMemberRepository : JpaRepository<HouseholdMember, UUID> {
    fun findByUserId(userId: UUID): List<HouseholdMember>
    fun findByHouseholdIdAndUserId(householdId: UUID, userId: UUID): HouseholdMember?
    fun existsByHouseholdIdAndUserId(householdId: UUID, userId: UUID): Boolean
}
