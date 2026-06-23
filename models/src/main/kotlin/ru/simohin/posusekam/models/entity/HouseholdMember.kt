package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "household_members", uniqueConstraints = [
    UniqueConstraint(columnNames = ["household_id", "user_id"])
])
data class HouseholdMember(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    val household: Household,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,

    @Column(nullable = false)
    var role: String = "member",

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null
)
