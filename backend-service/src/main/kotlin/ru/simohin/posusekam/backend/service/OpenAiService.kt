package ru.simohin.posusekam.backend.service

import org.springframework.ai.chat.model.ChatModel
import org.springframework.stereotype.Service

@Service
class OpenAiService(
    private val chatModel: ChatModel
) {
    /**
     * Простой вызов OpenAI для генерации текста по промпту.
     * Функционал будет расширяться в будущем.
     */
    fun generateText(prompt: String): String {
        return chatModel.call(prompt)
    }
}
