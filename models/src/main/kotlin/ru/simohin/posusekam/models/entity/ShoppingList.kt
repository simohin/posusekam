package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "shopping_lists")
data class ShoppingList(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    val household: Household,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "store_id", nullable = false)
    val store: Store,

    @Column(nullable = false)
    var completed: Boolean = false,

    @OneToMany(mappedBy = "shoppingList", cascade = [CascadeType.ALL], orphanRemoval = true, fetch = FetchType.LAZY)
    var items: MutableList<ShoppingListItem> = mutableListOf(),

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null,

    @Column(name = "updated_at")
    var updatedAt: ZonedDateTime? = null
)
