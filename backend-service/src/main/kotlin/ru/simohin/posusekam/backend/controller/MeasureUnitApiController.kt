package ru.simohin.posusekam.backend.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException
import ru.simohin.posusekam.backend.repository.HouseholdMemberRepository
import ru.simohin.posusekam.backend.repository.HouseholdRepository
import ru.simohin.posusekam.backend.repository.MeasureUnitRepository
import ru.simohin.posusekam.backendservice.api.MeasureUnitsApi
import ru.simohin.posusekam.backendservice.dto.CreateMeasureUnitRequest
import ru.simohin.posusekam.backendservice.dto.MeasureUnitDto
import ru.simohin.posusekam.models.entity.MeasureUnit
import java.util.UUID

@RestController
class MeasureUnitApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val measureUnitRepository: MeasureUnitRepository
) : MeasureUnitsApi {

    override fun listMeasureUnits(householdId: UUID): ResponseEntity<List<MeasureUnitDto>> {
        checkMembership(householdId)
        val units = measureUnitRepository.findByHouseholdId(householdId)
        val dtos = units.map { toDto(it) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createMeasureUnit(
        householdId: UUID,
        createMeasureUnitRequest: CreateMeasureUnitRequest
    ): ResponseEntity<MeasureUnitDto> {
        checkMembership(householdId)
        val household = householdRepository.findById(householdId).orElse(null)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Household not found")

        val measureUnit = MeasureUnit(
            household = household,
            name = createMeasureUnitRequest.name
        )
        val saved = measureUnitRepository.save(measureUnit)
        return ResponseEntity.ok(toDto(saved))
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

    private fun toDto(unit: MeasureUnit): MeasureUnitDto {
        return MeasureUnitDto().apply {
            id = unit.id
            name = unit.name
        }
    }
}
