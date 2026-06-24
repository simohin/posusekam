package ru.simohin.posusekam.userinfo

import kotlinx.serialization.Serializable

@Serializable
data class UserInfo(
    val firstName: String? = null,
    val lastName: String? = null,
    val displayName: String? = null,
    val avatarUrl: String? = null,
    val providerId: String? = null,
    val providerUserId: String? = null
)

@Serializable
data class UserInfoDto(
    val userId: String,
    val info: UserInfo
)

@Serializable
data class UpdateUserInfoRequest(
    val info: UserInfo
)
