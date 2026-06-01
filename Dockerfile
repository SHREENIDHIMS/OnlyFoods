# ─────────────────────────────────────────────
# Stage 1: Build the WAR using Maven
# ─────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first (layer caching — only re-downloads deps if pom changes)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the full source
COPY src ./src

# Build the WAR file
RUN mvn clean package -DskipTests -B

# ─────────────────────────────────────────────
# Stage 2: Deploy WAR to Tomcat 10.1
# ─────────────────────────────────────────────
FROM tomcat:10.1-jdk17-temurin

# Remove default Tomcat apps (cleaner deploy)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR — deployed at root context (/)
COPY --from=builder /app/target/OnlyFoods.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat default port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
