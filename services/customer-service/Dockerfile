# -----------------------------
# BUILD STAGE
# -----------------------------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Download dependencies offline
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# -----------------------------
# RUNTIME STAGE
# -----------------------------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy built jar
COPY --from=build /app/target/*.jar app.jar

# Expose service port
EXPOSE 8080

# Default environment variables (can be overridden by docker-compose)
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/customer_db
ENV SPRING_DATASOURCE_USERNAME=customer_user
ENV SPRING_DATASOURCE_PASSWORD=customer_pass_2024
ENV SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:29092
ENV SPRING_REDIS_HOST=redis
ENV SPRING_REDIS_PORT=6379

# Run the service
ENTRYPOINT ["java", "-jar", "app.jar"]