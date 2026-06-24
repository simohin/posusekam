package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.util.UUID

@Entity
@Table(name = "user_settings")
data class UserSettings(
    @Id
    @Column(name = "user_id")
    val userId: UUID,

    @Convert(converter = JsonMapConverter::class)
    @Column(name = "settings", columnDefinition = "jsonb", nullable = false)
    var settings: Map<String, Any> = emptyMap()
)
