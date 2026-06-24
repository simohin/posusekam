package ru.simohin.posusekam.models.entity

import jakarta.persistence.AttributeConverter
import jakarta.persistence.Converter
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue

@Converter(autoApply = false)
class JsonMapConverter : AttributeConverter<Map<String, Any>, String> {
    private val mapper = jacksonObjectMapper()

    override fun convertToDatabaseColumn(attribute: Map<String, Any>?): String {
        return attribute?.let { mapper.writeValueAsString(it) } ?: "{}"
    }

    override fun convertToEntityAttribute(dbData: String?): Map<String, Any> {
        if (dbData.isNullOrBlank()) return emptyMap()
        return try {
            mapper.readValue(dbData)
        } catch (e: Exception) {
            emptyMap()
        }
    }
}
