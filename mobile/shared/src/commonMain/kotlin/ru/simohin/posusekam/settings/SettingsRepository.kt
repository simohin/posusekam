package ru.simohin.posusekam.settings

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.*
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import com.russhwolf.settings.Settings
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.encodeToString

class SettingsRepository(
    private val baseUrl: String = "https://dev.simohin.ru"
) {
    private val settings: Settings = Settings()
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = HttpClient {
        install(ContentNegotiation) {
            json(json)
        }
        install(Logging) {
            level = LogLevel.ALL
        }
    }

    private val _settingsFlow = MutableStateFlow(loadLocalSettings())
    val settingsFlow: StateFlow<UserSettings> = _settingsFlow.asStateFlow()

    private var onSettingsChanged: ((UserSettings) -> Unit)? = null

    fun observeSettings(onChanged: (UserSettings) -> Unit) {
        this.onSettingsChanged = onChanged
        onChanged(_settingsFlow.value)
    }

    private fun getAccessToken(): String? = settings.getStringOrNull("access_token")

    private fun loadLocalSettings(): UserSettings {
        val jsonStr = settings.getStringOrNull("user_settings") ?: return UserSettings()
        return try {
            json.decodeFromString<UserSettings>(jsonStr)
        } catch (e: Exception) {
            println("KMP ERROR: Failed to decode local settings: $e")
            UserSettings()
        }
    }

    private fun saveLocalSettings(userSettings: UserSettings) {
        try {
            val jsonStr = json.encodeToString(userSettings)
            settings.putString("user_settings", jsonStr)
            _settingsFlow.value = userSettings
            onSettingsChanged?.invoke(userSettings)
        } catch (e: Exception) {
            println("KMP ERROR: Failed to save local settings: $e")
        }
    }

    @Throws(Exception::class)
    suspend fun loadSettingsFromServer() {
        val token = getAccessToken() ?: return // Do nothing if not logged in
        val response = client.get("$baseUrl/api/v1/settings") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value in 200..299) {
            val bodyText = response.bodyAsText()
            try {
                val dto = json.decodeFromString<UserSettingsDto>(bodyText)
                saveLocalSettings(dto.settings)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode remote settings. Body: $bodyText. Error: $e")
            }
        }
    }

    @Throws(Exception::class)
    suspend fun updateSettings(newSettings: UserSettings) {
        // Save locally first for responsive UI
        saveLocalSettings(newSettings)

        // Then sync to backend
        val token = getAccessToken() ?: return
        val response = client.put("$baseUrl/api/v1/settings") {
            header("Authorization", "Bearer $token")
            contentType(ContentType.Application.Json)
            setBody(UpdateSettingsRequest(newSettings))
        }
        if (response.status.value !in 200..299) {
            println("KMP ERROR: Failed to sync settings with server: ${response.status}")
        }
    }

    @Throws(Exception::class)
    suspend fun resetSettings() {
        // Clear locally
        settings.remove("user_settings")
        val defaultSettings = UserSettings()
        _settingsFlow.value = defaultSettings
        onSettingsChanged?.invoke(defaultSettings)

        // Sync deletion with backend
        val token = getAccessToken() ?: return
        val response = client.delete("$baseUrl/api/v1/settings") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value !in 200..299 && response.status.value != 404) {
            println("KMP ERROR: Failed to delete settings on server: ${response.status}")
        }
    }
}
