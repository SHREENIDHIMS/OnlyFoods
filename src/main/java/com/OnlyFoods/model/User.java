package com.OnlyFoods.model;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * User model — matches the User table exactly.
 * Implements Serializable so it can be stored in HttpSession safely.
 *
 * DB table:
 *   CREATE TABLE User (
 *       userId        INT          PRIMARY KEY AUTO_INCREMENT,
 *       username      VARCHAR(100) NOT NULL,
 *       password      VARCHAR(255) NOT NULL,   -- BCrypt hash
 *       email         VARCHAR(100) NOT NULL UNIQUE,
 *       phone         VARCHAR(15),
 *       address       VARCHAR(255),
 *       role          VARCHAR(20)  DEFAULT 'USER',
 *       createdDate   DATE,
 *       lastLoginDate DATE
 *   );
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    // ── Fields ──────────────────────────────────────────────────

    private int       userId;
    private String    username;
    private String    password;       // BCrypt hash — never plaintext
    private String    email;
    private String    phone;
    private String    address;
    private String    role;
    private LocalDate createdDate;
    private LocalDate lastLoginDate;

    // ── Constructors ─────────────────────────────────────────────

    public User() {}

    public User(String username, String password, String email,
                String phone, String address, String role, LocalDate createdDate) {
        this.username    = username;
        this.password    = password;
        this.email       = email;
        this.phone       = phone;
        this.address     = address;
        this.role        = role;
        this.createdDate = createdDate;
    }

    // ── Getters ──────────────────────────────────────────────────

    public int       getUserId()       { return userId; }
    public String    getUsername()     { return username; }
    public String    getPassword()     { return password; }
    public String    getEmail()        { return email; }
    public String    getPhone()        { return phone; }
    public String    getAddress()      { return address; }
    public String    getRole()         { return role; }
    public LocalDate getCreatedDate()  { return createdDate; }
    public LocalDate getLastLoginDate(){ return lastLoginDate; }

    // ── Setters ──────────────────────────────────────────────────

    public void setUserId(int userId)                   { this.userId        = userId; }
    public void setUsername(String username)             { this.username      = username; }
    public void setPassword(String password)             { this.password      = password; }
    public void setEmail(String email)                   { this.email         = email; }
    public void setPhone(String phone)                   { this.phone         = phone; }
    public void setAddress(String address)               { this.address       = address; }
    public void setRole(String role)                     { this.role          = role; }
    public void setCreatedDate(LocalDate createdDate)    { this.createdDate   = createdDate; }
    public void setLastLoginDate(LocalDate lastLoginDate){ this.lastLoginDate = lastLoginDate; }

    // ── toString (safe — never includes password) ────────────────

    @Override
    public String toString() {
        return "User{userId=" + userId +
               ", username='" + username + '\'' +
               ", email='"    + email    + '\'' +
               ", role='"     + role     + '\'' + '}';
    }
}