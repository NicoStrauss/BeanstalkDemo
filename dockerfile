# Use official Eclipse Temurin base image for Java 17 (or change to 8 if you're using Java 8)
FROM eclipse-temurin:17-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the built jar file into the container
COPY target/springelastic-0.0.1-SNAPSHOT.jar application.jar

# Expose the port your app runs on (optional)
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "application.jar"]