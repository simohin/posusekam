package ru.simohin.posusekam.backend.controller

import org.springframework.http.ResponseEntity
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.repository.UserInfoRepository
import ru.simohin.posusekam.backendservice.api.UserInfoApi
import ru.simohin.posusekam.backendservice.dto.UpdateUserInfoRequest
import ru.simohin.posusekam.backendservice.dto.UserInfoDto
import ru.simohin.posusekam.models.entity.UserInfo
import java.util.UUID

@RestController
class UserInfoApiController(
    private val userInfoRepository: UserInfoRepository
) : UserInfoApi {

    override fun getUserInfo(): ResponseEntity<UserInfoDto> {
        val userId = getAuthenticatedUserId()
        val userInfo = userInfoRepository.findById(userId).orElseGet {
            UserInfo(userId = userId, info = emptyMap())
        }
        return ResponseEntity.ok(toDto(userInfo))
    }

    @Transactional
    override fun updateUserInfo(updateUserInfoRequest: UpdateUserInfoRequest): ResponseEntity<UserInfoDto> {
        val userId = getAuthenticatedUserId()
        val userInfo = userInfoRepository.findById(userId).orElseGet {
            UserInfo(userId = userId, info = emptyMap())
        }
        userInfo.info = updateUserInfoRequest.info ?: emptyMap()
        val saved = userInfoRepository.save(userInfo)
        return ResponseEntity.ok(toDto(saved))
    }

    @Transactional
    override fun patchUserInfo(requestBody: Map<String, Any>): ResponseEntity<UserInfoDto> {
        val userId = getAuthenticatedUserId()
        val userInfo = userInfoRepository.findById(userId).orElseGet {
            UserInfo(userId = userId, info = emptyMap())
        }
        val currentMap = userInfo.info.toMutableMap()
        currentMap.putAll(requestBody)
        userInfo.info = currentMap
        val saved = userInfoRepository.save(userInfo)
        return ResponseEntity.ok(toDto(saved))
    }

    private fun getAuthenticatedUserId(): UUID {
        val authentication = SecurityContextHolder.getContext().authentication
            ?: throw IllegalStateException("Not authenticated")
        val jwt = authentication.principal as? Jwt
            ?: throw IllegalStateException("Principal is not a JWT")
        return UUID.fromString(jwt.subject)
    }

    private fun toDto(userInfo: UserInfo): UserInfoDto {
        return UserInfoDto()
            .userId(userInfo.userId)
            .info(userInfo.info)
    }
}
