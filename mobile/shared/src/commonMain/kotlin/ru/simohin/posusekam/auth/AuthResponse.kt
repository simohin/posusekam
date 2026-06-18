package ru.simohin.posusekam.auth

import kotlinx.serialization.Serializable

@Serializable
data class AuthResponse(
    val accessToken: String? = null,
    val refreshToken: String? = null
)
