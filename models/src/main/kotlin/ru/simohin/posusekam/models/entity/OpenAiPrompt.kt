package ru.simohin.posusekam.models.entity

import jakarta.persistence.*

@Entity
@Table(name = "openai_prompts")
class OpenAiPrompt(
    @Id
    @Column(name = "id", nullable = false, length = 255)
    val id: String,

    @Column(name = "name", nullable = false, unique = true, length = 255)
    val name: PromptName,

    @Column(name = "version", nullable = false, length = 50)
    val version: String
)
