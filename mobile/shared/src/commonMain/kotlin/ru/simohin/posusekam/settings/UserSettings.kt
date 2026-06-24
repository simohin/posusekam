package ru.simohin.posusekam.settings

import kotlinx.serialization.Serializable

@Serializable
data class UserSettings(
    val hidePurchaseManagement: Boolean = false
)

@Serializable
data class UserSettingsDto(
    val userId: String,
    val settings: UserSettings
)

@Serializable
data class UpdateSettingsRequest(
    val settings: UserSettings
)
