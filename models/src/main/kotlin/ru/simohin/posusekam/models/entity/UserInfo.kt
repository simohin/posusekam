package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.util.UUID

@Entity
@Table(name = "user_info")
data class UserInfo(
    @Id
    @Column(name = "user_id")
    val userId: UUID,

    @Convert(converter = JsonMapConverter::class)
    @Column(name = "info", columnDefinition = "jsonb", nullable = false)
    var info: Map<String, Any> = emptyMap()
)
