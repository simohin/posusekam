package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "stores")
data class Store(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    val household: Household,

    @Column(nullable = false)
    var name: String,

    @Column(nullable = true)
    var icon: String? = null,

    @Column(nullable = true)
    var color: String? = null,

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null
)
