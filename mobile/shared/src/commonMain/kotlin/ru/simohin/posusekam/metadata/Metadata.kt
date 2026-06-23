package ru.simohin.posusekam.metadata

import kotlinx.serialization.Serializable

@Serializable
data class AppMetadataDto(
    val icons: List<IconMetadataDto>
)

@Serializable
data class IconMetadataDto(
    val name: String,
    val displayName: String,
    val type: String,
    val category: String,
    val keywords: String
)
