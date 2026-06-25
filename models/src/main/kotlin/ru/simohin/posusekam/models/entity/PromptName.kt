package ru.simohin.posusekam.models.entity

import jakarta.persistence.AttributeConverter
import jakarta.persistence.Converter

enum class PromptName(val value: String) {
    GENERATE_PRODUCTS_LIST("generate_products_list");

    companion object {
        fun fromValue(value: String): PromptName {
            return entries.firstOrNull { it.value == value }
                ?: throw IllegalArgumentException("Unknown prompt name: $value")
        }
    }
}

@Converter(autoApply = true)
class PromptNameConverter : AttributeConverter<PromptName, String> {
    override fun convertToDatabaseColumn(attribute: PromptName?): String? {
        return attribute?.value
    }

    override fun convertToEntityAttribute(dbData: String?): PromptName? {
        return dbData?.let { PromptName.fromValue(it) }
    }
}
