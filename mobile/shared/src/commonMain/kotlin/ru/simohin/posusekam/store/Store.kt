package ru.simohin.posusekam.store

import kotlinx.serialization.Serializable

@Serializable
data class Store(
    val id: String,
    val name: String,
    val householdId: String,
    val icon: String? = null,
    val color: String? = null,
    val createdAt: String? = null
)

@Serializable
data class CreateStoreRequest(
    val name: String,
    val icon: String? = null,
    val color: String? = null
)

@Serializable
data class UpdateStoreRequest(
    val name: String,
    val icon: String? = null,
    val color: String? = null
)
