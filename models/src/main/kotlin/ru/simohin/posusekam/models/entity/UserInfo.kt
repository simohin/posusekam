package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.util.UUID

@Entity
@Table(name = "user_info")
data class UserInfo(
    @Id
    @Column(name = "user_id")
    val userId: UUID,

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "info", nullable = false)
    var info: Map<String, Any> = emptyMap()
)
