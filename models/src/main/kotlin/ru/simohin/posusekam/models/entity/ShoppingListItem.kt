package ru.simohin.posusekam.models.entity

import jakarta.persistence.*
import java.time.ZonedDateTime
import java.util.UUID

@Entity
@Table(name = "shopping_list_items")
data class ShoppingListItem(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shopping_list_id", nullable = false)
    val shoppingList: ShoppingList,

    @Column(nullable = false)
    var name: String,

    @Column(name = "category_name", nullable = false)
    var categoryName: String,

    @Column(nullable = false)
    var amount: Double = 1.0,

    @Column(nullable = false)
    var unit: String = "шт",

    @Column(nullable = false)
    var bought: Boolean = false,

    @Column(name = "created_at", insertable = false, updatable = false)
    val createdAt: ZonedDateTime? = null
)
