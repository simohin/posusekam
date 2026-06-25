package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.util.UUID

@Entity
@Table(name = "user_settings")
data class UserSettings(
    @Id
    @Column(name = "user_id")
    val userId: UUID,

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "settings", nullable = false)
    var settings: Map<String, Any> = emptyMap()
)
