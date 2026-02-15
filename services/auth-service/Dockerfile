FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080

ENV SPRING_DATASOURCE_URL=jdbc:postgresql://database:5432/auth_db
ENV SPRING_DATASOURCE_USERNAME=auth_user
ENV SPRING_DATASOURCE_PASSWORD=auth_pass_2024
ENV SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:29092
ENV SPRING_REDIS_HOST=redis
ENV SPRING_REDIS_PORT=6379

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
