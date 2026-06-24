package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "households")
data class Household(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    var name: String,

    @Column(nullable = true)
    var icon: String? = null,

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null
)
