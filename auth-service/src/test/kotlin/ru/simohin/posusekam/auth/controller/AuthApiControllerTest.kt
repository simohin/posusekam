package ru.simohin.posusekam.auth.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import org.hamcrest.Matchers.notNullValue
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import ru.simohin.posusekam.auth.repository.UserRepository
import ru.simohin.posusekam.auth.service.GoogleAuthService
import ru.simohin.posusekam.authservice.dto.GoogleAuthRequest

@SpringBootTest(
    properties = [
        "spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=PostgreSQL",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "posusekam.jwt.private-key-path=classpath:certs/private.pem",
        "posusekam.jwt.public-key-path=classpath:certs/public.pem"
    ]
)
@AutoConfigureMockMvc
class AuthApiControllerTest {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @Autowired
    private lateinit var userRepository: UserRepository

    @MockBean
    private lateinit var googleAuthService: GoogleAuthService

    @Test
    fun `should authenticate google token, register user and return internal JWTs`() {
        // Arrange
        val googleToken = "mocked-google-token"
        val request = GoogleAuthRequest(googleToken)

        val payload = GoogleIdToken.Payload().apply {
            email = "user@example.com"
            subject = "google-uid-12345"
            set("name", "John Doe")
            set("picture", "http://example.com/john.png")
        }

        `when`(googleAuthService.verifyToken(googleToken)).thenReturn(payload)

        // Act & Assert
        mockMvc.perform(
            post("/v1/google")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.accessToken", notNullValue()))
            .andExpect(jsonPath("$.refreshToken", notNullValue()))

        // Verify user was saved in H2 Database
        val user = userRepository.findByGoogleId("google-uid-12345")
        assertNotNull(user)
        assertEquals("user@example.com", user?.email)
        assertEquals("John Doe", user?.name)
        assertEquals("http://example.com/john.png", user?.pictureUrl)
    }

    @Test
    fun `should return 401 when google token is invalid`() {
        // Arrange
        val invalidToken = "invalid-token"
        val request = GoogleAuthRequest(invalidToken)

        `when`(googleAuthService.verifyToken(invalidToken)).thenReturn(null)

        // Act & Assert
        mockMvc.perform(
            post("/v1/google")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
        )
            .andExpect(status().isUnauthorized)
    }
}
