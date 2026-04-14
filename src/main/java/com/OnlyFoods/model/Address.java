package com.OnlyFoods.model;

import java.io.Serializable;

/**
 * Address model — matches the address table.
 * 
 * DB table:
 *   CREATE TABLE address (
 *       addressId    INT          PRIMARY KEY AUTO_INCREMENT,
 *       userId       INT          NOT NULL,
 *       label        VARCHAR(50)  DEFAULT 'Home',
 *       fullAddress  VARCHAR(500) NOT NULL,
 *       isDefault    BOOLEAN      DEFAULT FALSE,
 *       FOREIGN KEY (userId) REFERENCES user(userId) ON DELETE CASCADE
 *   );
 */
public class Address implements Serializable {

    private static final long serialVersionUID = 1L;

    // ── Fields ──────────────────────────────────────────────────

    private int     addressId;
    private int     userId;
    private String  label;        // "Home", "Work", "Other"
    private String  fullAddress;  // Complete address string
    private boolean isDefault;    // Whether this is the default address

    // ── Constructors ─────────────────────────────────────────────

    public Address() {}

    public Address(int userId, String label, String fullAddress, boolean isDefault) {
        this.userId      = userId;
        this.label       = label;
        this.fullAddress = fullAddress;
        this.isDefault   = isDefault;
    }

    // ── Getters ──────────────────────────────────────────────────

    public int     getAddressId()   { return addressId; }
    public int     getUserId()      { return userId; }
    public String  getLabel()       { return label; }
    public String  getFullAddress() { return fullAddress; }
    public boolean isDefault()      { return isDefault; }

    // ── Setters ──────────────────────────────────────────────────

    public void setAddressId(int addressId)         { this.addressId   = addressId; }
    public void setUserId(int userId)               { this.userId      = userId; }
    public void setLabel(String label)              { this.label       = label; }
    public void setFullAddress(String fullAddress)  { this.fullAddress = fullAddress; }
    public void setDefault(boolean isDefault)       { this.isDefault   = isDefault; }

    // ── toString ─────────────────────────────────────────────────

    @Override
    public String toString() {
        return "Address{" +
               "addressId=" + addressId +
               ", userId=" + userId +
               ", label='" + label + '\'' +
               ", fullAddress='" + fullAddress + '\'' +
               ", isDefault=" + isDefault +
               '}';
    }
}