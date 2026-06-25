package ru.simohin.posusekam.product

import kotlinx.serialization.Serializable

@Serializable
data class Category(
    val id: String,
    val name: String,
    val icon: String? = null
)

@Serializable
data class CreateCategoryRequest(
    val name: String,
    val icon: String? = null
)

@Serializable
data class MeasureUnit(
    val id: String,
    val name: String
)

@Serializable
data class CreateMeasureUnitRequest(
    val name: String
)

@Serializable
data class Product(
    val id: String,
    val name: String,
    val unit: String,
    val categories: List<Category>
)

@Serializable
data class CreateProductRequest(
    val name: String,
    val unit: String,
    val categoryIds: List<String>? = null
)

@Serializable
data class UpdateProductRequest(
    val name: String,
    val unit: String,
    val categoryIds: List<String>? = null
)
