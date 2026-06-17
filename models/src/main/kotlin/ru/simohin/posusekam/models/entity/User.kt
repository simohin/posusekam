package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false, unique = true)
    var email: String,

    @Column(name = "google_id", unique = true)
    var googleId: String? = null,

    var name: String? = null,

    @Column(name = "picture_url")
    var pictureUrl: String? = null,

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null
)
