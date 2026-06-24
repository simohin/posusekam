package ru.simohin.posusekam.userinfo

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

class UserInfoRepository(
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

    private val _userInfoFlow = MutableStateFlow(loadLocalUserInfo())
    val userInfoFlow: StateFlow<UserInfo?> = _userInfoFlow.asStateFlow()

    private var onUserInfoChanged: ((UserInfo?) -> Unit)? = null

    fun observeUserInfo(onChanged: (UserInfo?) -> Unit) {
        this.onUserInfoChanged = onChanged
        onChanged(_userInfoFlow.value)
    }

    private fun getAccessToken(): String? = settings.getStringOrNull("access_token")

    private fun loadLocalUserInfo(): UserInfo? {
        val jsonStr = settings.getStringOrNull("user_info_cache") ?: return null
        return try {
            json.decodeFromString<UserInfo>(jsonStr)
        } catch (e: Exception) {
            println("KMP ERROR: Failed to decode local user info: $e")
            null
        }
    }

    private fun saveLocalUserInfo(userInfo: UserInfo?) {
        try {
            if (userInfo != null) {
                val jsonStr = json.encodeToString(userInfo)
                settings.putString("user_info_cache", jsonStr)
            } else {
                settings.remove("user_info_cache")
            }
            _userInfoFlow.value = userInfo
            onUserInfoChanged?.invoke(userInfo)
        } catch (e: Exception) {
            println("KMP ERROR: Failed to save local user info: $e")
        }
    }

    @Throws(Exception::class)
    suspend fun loadUserInfoFromServer() {
        val token = getAccessToken() ?: return // Do nothing if not logged in
        val response = client.get("$baseUrl/api/v1/user-info") {
            header("Authorization", "Bearer $token")
        }
        if (response.status.value in 200..299) {
            val bodyText = response.bodyAsText()
            try {
                val dto = json.decodeFromString<UserInfoDto>(bodyText)
                saveLocalUserInfo(dto.info)
            } catch (e: Exception) {
                println("KMP ERROR: Failed to decode remote user info. Body: $bodyText. Error: $e")
            }
        }
    }

    @Throws(Exception::class)
    suspend fun updateUserInfo(newInfo: UserInfo) {
        // Save locally first
        saveLocalUserInfo(newInfo)

        // Sync with server
        val token = getAccessToken() ?: return
        val response = client.put("$baseUrl/api/v1/user-info") {
            header("Authorization", "Bearer $token")
            contentType(ContentType.Application.Json)
            setBody(UpdateUserInfoRequest(newInfo))
        }
        if (response.status.value !in 200..299) {
            println("KMP ERROR: Failed to sync user info with server: ${response.status}")
        }
    }

    fun clearLocalCache() {
        saveLocalUserInfo(null)
    }
}
