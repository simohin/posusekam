package ru.simohin.posusekam.shoppinglist

import kotlinx.serialization.Serializable

@Serializable
data class ShoppingListItem(
    val id: String,
    val name: String,
    val categoryName: String,
    val amount: Double,
    val unit: String,
    val bought: Boolean
)

@Serializable
data class ShoppingList(
    val id: String,
    val householdId: String,
    val storeId: String,
    val completed: Boolean,
    val createdAt: String? = null,
    val items: List<ShoppingListItem>
)

@Serializable
data class CreateShoppingListItemRequest(
    val name: String,
    val categoryName: String,
    val amount: Double,
    val unit: String
)

@Serializable
data class CreateShoppingListRequest(
    val storeId: String,
    val items: List<CreateShoppingListItemRequest>
)

@Serializable
data class UpdateShoppingListRequest(
    val completed: Boolean,
    val items: List<CreateShoppingListItemRequest>
)
