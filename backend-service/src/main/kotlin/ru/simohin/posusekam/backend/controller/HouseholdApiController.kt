package ru.simohin.posusekam.backend.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.repository.HouseholdMemberRepository
import ru.simohin.posusekam.backend.repository.HouseholdRepository
import ru.simohin.posusekam.backend.repository.UserRepository
import ru.simohin.posusekam.backendservice.api.HouseholdsApi
import ru.simohin.posusekam.backendservice.dto.CreateHouseholdRequest
import ru.simohin.posusekam.backendservice.dto.HouseholdDto
import ru.simohin.posusekam.backendservice.dto.UpdateHouseholdRequest
import ru.simohin.posusekam.models.entity.Household
import ru.simohin.posusekam.models.entity.HouseholdMember
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

@RestController
class HouseholdApiController(
    private val householdRepository: HouseholdRepository,
    private val householdMemberRepository: HouseholdMemberRepository,
    private val userRepository: UserRepository
) : HouseholdsApi {

    override fun listHouseholds(): ResponseEntity<List<HouseholdDto>> {
        val userId = getAuthenticatedUserId()
        val memberships = householdMemberRepository.findByUserId(userId)
        val dtos = memberships.map { toDto(it.household) }
        return ResponseEntity.ok(dtos)
    }

    @Transactional
    override fun createHousehold(createHouseholdRequest: CreateHouseholdRequest): ResponseEntity<HouseholdDto> {
        val userId = getAuthenticatedUserId()
        val user = userRepository.findById(userId).orElse(null)
            ?: return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build()

        val household = Household(
            name = createHouseholdRequest.name,
            icon = createHouseholdRequest.icon
        )
        val savedHousehold = householdRepository.save(household)

        val membership = HouseholdMember(
            household = savedHousehold,
            user = user,
            role = "owner"
        )
        householdMemberRepository.save(membership)

        return ResponseEntity.ok(toDto(savedHousehold))
    }

    @Transactional
    override fun updateHousehold(id: UUID, updateHouseholdRequest: UpdateHouseholdRequest): ResponseEntity<HouseholdDto> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(id, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        val household = householdRepository.findById(id).orElse(null)
            ?: return ResponseEntity.notFound().build()

        household.name = updateHouseholdRequest.name
        household.icon = updateHouseholdRequest.icon
        val saved = householdRepository.save(household)

        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun deleteHousehold(id: UUID): ResponseEntity<Void> {
        val userId = getAuthenticatedUserId()
        if (!householdMemberRepository.existsByHouseholdIdAndUserId(id, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }

        if (!householdRepository.existsById(id)) {
            return ResponseEntity.notFound().build()
        }

        householdRepository.deleteById(id)
        return ResponseEntity.noContent().build()
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(household: Household): HouseholdDto {
        return HouseholdDto()
            .id(household.id)
            .name(household.name)
            .icon(household.icon)
            .createdAt(household.createdAt?.let { OffsetDateTime.ofInstant(it.toInstant(), ZoneOffset.UTC) })
    }
}
