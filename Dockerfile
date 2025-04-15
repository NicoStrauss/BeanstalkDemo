# Use official Eclipse Temurin base image for Java 17 (or change to 8 if using Java 8)
FROM eclipse-temurin:17-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the built jar file into the container
COPY target/springelastic-0.0.1-SNAPSHOT.jar app.jar

# Expose port 80 which is used by the load balancer for HTTP traffic
EXPOSE 80

# Optional: Add a health check so that AWS Elastic Beanstalk can monitor the container's health
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD curl -f http://localhost:80/ || exit 1

# Command to run the application on port 80
ENTRYPOINT ["java", "-jar", "app.jar", "--server.port=80"]