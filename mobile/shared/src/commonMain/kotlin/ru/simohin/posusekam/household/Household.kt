package ru.simohin.posusekam.household

import kotlinx.serialization.Serializable

@Serializable
data class Household(
    val id: String,
    val name: String,
    val createdAt: String? = null
)

@Serializable
data class CreateHouseholdRequest(
    val name: String
)

@Serializable
data class UpdateHouseholdRequest(
    val name: String
)
