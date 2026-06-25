package ru.simohin.posusekam.backend.service

import com.fasterxml.jackson.annotation.JsonValue

enum class ProductMeasureUnit(@JsonValue val value: String) {
    PIECE("шт"),
    LITER("л"),
    PACK("уп"),
    KG("кг"),
    GRAM("г");
}

enum class ProductCategory(@JsonValue val value: String) {
    ALCOHOL("Алкоголь"),
    SNACKS("Снеки"),
    HOT_APPETIZERS("Горячие закуски"),
    BEVERAGES("Безалкогольные напитки"),
    OTHER("Другое");
}
