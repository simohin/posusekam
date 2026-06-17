# Stage 1: Build
FROM gradle:8.8-jdk21-alpine AS builder
WORKDIR /app

# Copy the entire project to the builder to resolve all Gradle dependencies and settings
COPY . .

# Build the db-controller distribution
RUN ./gradlew :db-controller:installDist --no-daemon

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy the built distribution from the builder stage
COPY --from=builder /app/db-controller/build/install/db-controller ./

# Run the startup script
ENTRYPOINT ["./bin/db-controller"]
