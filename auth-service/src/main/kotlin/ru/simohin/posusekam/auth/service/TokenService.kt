package ru.simohin.posusekam.auth.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.UUID

@Service
class TokenService(
    private val jwtEncoder: JwtEncoder,
    @Value("\${posusekam.jwt.issuer}") private val issuer: String,
    @Value("\${posusekam.jwt.access-token-expiration-seconds}") private val accessTokenExpiration: Long,
    @Value("\${posusekam.jwt.refresh-token-expiration-seconds}") private val refreshTokenExpiration: Long
) {

    fun generateAccessToken(userId: UUID, email: String): String {
        val now = Instant.now()
        val claims = JwtClaimsSet.builder()
            .issuer(issuer)
            .issuedAt(now)
            .expiresAt(now.plusSeconds(accessTokenExpiration))
            .subject(userId.toString())
            .claim("email", email)
            .claim("token_type", "access")
            .build()
        return jwtEncoder.encode(JwtEncoderParameters.from(claims)).tokenValue
    }

    fun generateRefreshToken(userId: UUID): String {
        val now = Instant.now()
        val claims = JwtClaimsSet.builder()
            .issuer(issuer)
            .issuedAt(now)
            .expiresAt(now.plusSeconds(refreshTokenExpiration))
            .subject(userId.toString())
            .claim("token_type", "refresh")
            .build()
        return jwtEncoder.encode(JwtEncoderParameters.from(claims)).tokenValue
    }
}
