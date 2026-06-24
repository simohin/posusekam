package ru.simohin.posusekam.backend.controller

import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.repository.UserSettingsRepository
import ru.simohin.posusekam.backendservice.api.SettingsApi
import ru.simohin.posusekam.backendservice.dto.UpdateSettingsRequest
import ru.simohin.posusekam.backendservice.dto.UserSettingsDto
import ru.simohin.posusekam.models.entity.UserSettings
import java.util.UUID

@RestController
class SettingsApiController(
    private val userSettingsRepository: UserSettingsRepository
) : SettingsApi {

    override fun getSettings(): ResponseEntity<UserSettingsDto> {
        val userId = getAuthenticatedUserId()
        val userSettings = userSettingsRepository.findById(userId).orElseGet {
            UserSettings(userId = userId, settings = emptyMap())
        }
        return ResponseEntity.ok(toDto(userSettings))
    }

    @Transactional
    override fun updateSettings(updateSettingsRequest: UpdateSettingsRequest): ResponseEntity<UserSettingsDto> {
        val userId = getAuthenticatedUserId()
        val userSettings = userSettingsRepository.findById(userId).orElseGet {
            UserSettings(userId = userId, settings = emptyMap())
        }
        userSettings.settings = updateSettingsRequest.settings ?: emptyMap()
        val saved = userSettingsRepository.save(userSettings)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun patchSettings(requestBody: Map<String, Any>): ResponseEntity<UserSettingsDto> {
        val userId = getAuthenticatedUserId()
        val userSettings = userSettingsRepository.findById(userId).orElseGet {
            UserSettings(userId = userId, settings = emptyMap())
        }
        val currentMap = userSettings.settings.toMutableMap()
        currentMap.putAll(requestBody)
        userSettings.settings = currentMap
        val saved = userSettingsRepository.save(userSettings)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun deleteSettings(): ResponseEntity<Void> {
        val userId = getAuthenticatedUserId()
        if (userSettingsRepository.existsById(userId)) {
            userSettingsRepository.deleteById(userId)
        }
        return ResponseEntity.noContent().build()
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(userSettings: UserSettings): UserSettingsDto {
        return UserSettingsDto()
            .userId(userSettings.userId)
            .settings(userSettings.settings)
    }
}
