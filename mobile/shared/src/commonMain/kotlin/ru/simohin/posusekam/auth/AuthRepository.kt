package ru.simohin.posusekam.auth

import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import com.russhwolf.settings.Settings

class AuthRepository(
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

    companion object {
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_REFRESH_TOKEN = "refresh_token"
    }

    @Throws(Exception::class)
    suspend fun authenticateWithGoogle(idToken: String): AuthResponse {
        val response: HttpResponse = client.post("$baseUrl/auth/v1/google") {
            contentType(ContentType.Application.Json)
            setBody(GoogleAuthRequest(idToken))
        }

        if (response.status.value in 200..299) {
            val bodyText = response.bodyAsText()
            val authResponse = json.decodeFromString<AuthResponse>(bodyText)
            
            authResponse.accessToken?.let { settings.putString(KEY_ACCESS_TOKEN, it) }
            authResponse.refreshToken?.let { settings.putString(KEY_REFRESH_TOKEN, it) }
            
            return authResponse
        } else {
            throw Exception("Authentication failed with status: ${response.status}")
        }
    }

    fun getAccessToken(): String? = settings.getStringOrNull(KEY_ACCESS_TOKEN)
    fun getRefreshToken(): String? = settings.getStringOrNull(KEY_REFRESH_TOKEN)
    
    fun logout() {
        settings.remove(KEY_ACCESS_TOKEN)
        settings.remove(KEY_REFRESH_TOKEN)
    }

    fun isAuthenticated(): Boolean = getAccessToken() != null
}
