package ru.simohin.posusekam.backend.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.simohin.posusekam.models.entity.OpenAiPrompt
import ru.simohin.posusekam.models.entity.PromptName

@Repository
interface OpenAiPromptRepository : JpaRepository<OpenAiPrompt, String> {
    fun findByName(name: PromptName): OpenAiPrompt?
}
