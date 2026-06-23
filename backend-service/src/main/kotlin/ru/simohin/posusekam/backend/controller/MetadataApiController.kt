package ru.simohin.posusekam.backend.controller

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.RestController
import ru.simohin.posusekam.backend.repository.IconMetadataRepository
import ru.simohin.posusekam.backendservice.api.MetadataApi
import ru.simohin.posusekam.backendservice.dto.AppMetadataDto
import ru.simohin.posusekam.backendservice.dto.IconMetadataDto

@RestController
class MetadataApiController(
    private val iconMetadataRepository: IconMetadataRepository
) : MetadataApi {

    override fun getMetadata(): ResponseEntity<AppMetadataDto> {
        val icons = iconMetadataRepository.findAll()
        val dtos = icons.map {
            IconMetadataDto(
                it.name,
                it.displayName,
                it.type,
                it.category,
                it.keywords
            )
        }
        val appMetadataDto = AppMetadataDto(dtos)
        return ResponseEntity.ok(appMetadataDto)
    }
}
