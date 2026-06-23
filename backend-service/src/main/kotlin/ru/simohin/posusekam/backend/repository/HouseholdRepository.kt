package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.Household
import java.util.UUID

@Repository
interface HouseholdRepository : JpaRepository<Household, UUID>
