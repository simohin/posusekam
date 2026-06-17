FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy the pre-built jar from local build
COPY build/libs/auth-service-*.jar ./auth-service.jar

# Run the bootJar
ENTRYPOINT ["java", "-jar", "auth-service.jar"]
