package com.OnlyFoods.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection — thin JDBC connection factory for OnlyFoods.
 *
 * Configuration is read from system properties so the same WAR
 * works in development (application.properties / VM args) and
 * production (Tomcat context.xml / environment variables) without
 * touching source code.
 *
 * Recommended: set these as JVM arguments in your run config or
 * in Tomcat's setenv.sh:
 *
 *   -Ddb.url=jdbc:mysql://localhost:3306/onlyfoods?useSSL=false&serverTimezone=UTC
 *   -Ddb.user=root
 *   -Ddb.password=yourpassword
 *
 * Fallback defaults are provided for local development.
 *
 * NOTE: This is a simple per-request connection factory.
 * For production traffic, replace with a HikariCP or c3p0 connection
 * pool to avoid opening a new TCP connection on every DAO call.
 */
public class DBConnection {

    private static final String URL =
        System.getProperty("db.url",
            "jdbc:mysql://localhost:3306/onlyfoods" +
            "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true");

    private static final String USER =
        System.getProperty("db.user", "root");

    private static final String PASSWORD =
        System.getProperty("db.password", "root");

    static {
        try {
            // Explicit driver load — required for some servlet containers
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "MySQL JDBC driver not found. Add mysql-connector-j to your classpath.\n" + e);
        }
    }

    /**
     * Returns a new JDBC connection.
     * Always use in a try-with-resources block:
     *
     *   try (Connection con = DBConnection.getDBConnection()) { … }
     *
     * @throws SQLException if a database access error occurs
     */
    public static Connection getDBConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Utility class — no instantiation
    private DBConnection() {}
}
