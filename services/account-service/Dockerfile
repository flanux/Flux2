# -----------------------------
# BUILD STAGE
# -----------------------------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# -----------------------------
# RUNTIME STAGE
# -----------------------------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy built jar
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Optional: default env vars (can be overridden by docker-compose)
ENV SPRING_REDIS_HOST=redis
ENV SPRING_REDIS_PORT=6379
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/account_db
ENV SPRING_DATASOURCE_USERNAME=account_user
ENV SPRING_DATASOURCE_PASSWORD=account_pass_2024
ENV SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:29092

# Run app
ENTRYPOINT ["java", "-jar", "app.jar"]