FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy the pre-built distribution from local build
COPY build/install/db-controller ./

# Run the startup script
ENTRYPOINT ["./bin/db-controller"]
