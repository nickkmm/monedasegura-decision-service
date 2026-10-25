# Build stage: compile with the Maven wrapper so the Maven version comes from .mvn/wrapper.
FROM eclipse-temurin:21.0.12.1_1-jdk AS build
WORKDIR /src
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN ./mvnw -B -q dependency:go-offline
COPY src src
RUN ./mvnw -B -q package -DskipTests

# Runtime stage: JRE only, non-root user.
FROM eclipse-temurin:21.0.12.1_1-jre-alpine
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=build /src/target/decision-service-*.jar app.jar
USER app
ENV TZ=America/Bogota
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=5 \
  CMD wget -qO- http://localhost:8080/api/v1/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
