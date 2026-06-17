package ru.simohin.posusekam.auth.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.auth.repository.UserRepository
import ru.simohin.posusekam.auth.service.GoogleAuthService
import ru.simohin.posusekam.auth.service.TokenService
import ru.simohin.posusekam.authservice.api.GoogleAuthApi
import ru.simohin.posusekam.authservice.dto.AuthResponse
import ru.simohin.posusekam.authservice.dto.GoogleAuthRequest
import ru.simohin.posusekam.models.entity.User

@RestController
class AuthApiController(
    private val googleAuthService: GoogleAuthService,
    private val userRepository: UserRepository,
    private val tokenService: TokenService
) : GoogleAuthApi {

    override fun authenticateGoogle(googleAuthRequest: GoogleAuthRequest): ResponseEntity<AuthResponse> {
        val payload = googleAuthService.verifyToken(googleAuthRequest.idToken)
            ?: return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build()

        val email = payload.email ?: return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
        val googleId = payload.subject
        val name = payload["name"] as? String
        val pictureUrl = payload["picture"] as? String

        // 1. Поиск по googleId
        var user = userRepository.findByGoogleId(googleId)

        if (user == null) {
            // 2. Если не нашли по Google ID, ищем по email (для связывания аккаунтов)
            user = userRepository.findByEmail(email)
            if (user != null) {
                user.googleId = googleId
                if (user.name == null) user.name = name
                if (user.pictureUrl == null) user.pictureUrl = pictureUrl
                user = userRepository.save(user)
            } else {
                // 3. Регистрация нового пользователя
                val newUser = User(
                    email = email,
                    googleId = googleId,
                    name = name,
                    pictureUrl = pictureUrl
                )
                user = userRepository.save(newUser)
            }
        } else {
            // Обновляем данные пользователя при входе, если они изменились в Google
            var changed = false
            if (user.email != email) {
                user.email = email
                changed = true
            }
            if (user.name != name) {
                user.name = name
                changed = true
            }
            if (user.pictureUrl != pictureUrl) {
                user.pictureUrl = pictureUrl
                changed = true
            }
            if (changed) {
                user = userRepository.save(user)
            }
        }

        val userId = user.id ?: return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()

        val accessToken = tokenService.generateAccessToken(userId, user.email)
        val refreshToken = tokenService.generateRefreshToken(userId)

        val response = AuthResponse()
            .accessToken(accessToken)
            .refreshToken(refreshToken)

        return ResponseEntity.ok(response)
    }
}
