package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.util.UUID

@Entity
@Table(name = "icon_metadata")
data class IconMetadata(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false, unique = true)
    val name: String,

    @Column(name = "display_name", nullable = false)
    val displayName: String,

    @Column(nullable = false)
    val type: String,

    @Column(nullable = false)
    val category: String,

    @Column(nullable = false)
    val keywords: String
)
