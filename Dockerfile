# --- Stage 1: Build the Application ---
FROM maven:3.8.6-eclipse-temurin-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and download dependencies first (to leverage Docker caching)
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Copy the rest of the source code
COPY src ./src

# Build the application (skip tests for faster builds, remove `-DskipTests` if needed)
RUN mvn clean package -DskipTests

# --- Stage 2: Create a Minimal Runtime Image ---
FROM tomcat:8.0.20-jre8

# Expose port 8080 for web traffic
EXPOSE 8080

# Copy only the built WAR file from the previous stage
COPY --from=build /app/target/maven-cloudaseem-app.war /usr/local/tomcat/webapps/

# Start Tomcat
CMD ["catalina.sh", "run"]
