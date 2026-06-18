package ru.simohin.posusekam.auth.service

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.util.Collections

@Service
class GoogleAuthService(
    @Value("\${posusekam.google.client-id}") private val googleClientId: String
) {
    private val verifier: GoogleIdTokenVerifier by lazy {
        val clientIds = googleClientId.split(",").map { it.trim() }
        GoogleIdTokenVerifier.Builder(NetHttpTransport(), GsonFactory.getDefaultInstance())
            .setAudience(clientIds)
            .build()
    }

    fun verifyToken(idTokenString: String): GoogleIdToken.Payload? {
        return try {
            val idToken: GoogleIdToken = verifier.verify(idTokenString) ?: return null
            idToken.payload
        } catch (e: Exception) {
            null
        }
    }
}
