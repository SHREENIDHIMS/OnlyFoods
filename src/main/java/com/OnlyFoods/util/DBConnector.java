package com.OnlyFoods.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnector - Database connection utility
 * Reads credentials from environment variables for cloud deployment.
 *
 * Required environment variables:
 *   DB_URL      e.g. jdbc:mysql://your-host:3306/onlyfoods?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
 *   DB_USER     e.g. root
 *   DB_PASS     e.g. yourpassword
 *
 * For LOCAL development, set these in your OS environment or IDE run config.
 * For Railway/cloud, set these in the platform's environment variables panel.
 */
public class DBConnector {

    // Read from environment variables — NEVER hardcode credentials
    private static final String URL  = System.getenv("DB_URL");
    private static final String USER = System.getenv("DB_USER");
    private static final String PASS = System.getenv("DB_PASS");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found. Add mysql-connector-j to pom.xml", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (URL == null || USER == null || PASS == null) {
            throw new SQLException(
                "Database environment variables not set. " +
                "Please set DB_URL, DB_USER, and DB_PASS."
            );
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
