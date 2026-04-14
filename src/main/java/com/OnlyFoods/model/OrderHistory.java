package com.OnlyFoods.model;

import java.sql.Timestamp;
import java.util.List;

/**
 * OrderHistory — lightweight read-only DTO for displaying a user's past orders.
 *
 * This was previously an empty class. It now mirrors the fields returned by
 * OrderHistoryDAOImpl and is used on the profile / order-history page.
 *
 * Note: for full order detail (with items) use the Order model directly.
 *       OrderHistory is a summary row — items are optional.
 */
public class OrderHistory {

    private int            orderId;
    private int            userId;
    private int            restaurantId;
    private String         restaurantName;
    private Timestamp      orderDate;
    private double         totalAmount;
    private String         status;
    private String         paymentMode;
    private List<Orderitem> items;          // populated only for detail view

    // ── Constructors ──────────────────────────────────────────────

    public OrderHistory() {}

    // ── Getters / Setters ─────────────────────────────────────────

    public int    getOrderId()          { return orderId; }
    public void   setOrderId(int id)    { this.orderId = id; }

    public int    getUserId()           { return userId; }
    public void   setUserId(int id)     { this.userId = id; }

    public int    getRestaurantId()                    { return restaurantId; }
    public void   setRestaurantId(int restaurantId)    { this.restaurantId = restaurantId; }

    public String getRestaurantName()                  { return restaurantName; }
    public void   setRestaurantName(String name)       { this.restaurantName = name; }

    public Timestamp getOrderDate()                    { return orderDate; }
    public void      setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }

    public double getTotalAmount()                     { return totalAmount; }
    public void   setTotalAmount(double totalAmount)   { this.totalAmount = totalAmount; }

    public String getStatus()                          { return status; }
    public void   setStatus(String status)             { this.status = status; }

    public String getPaymentMode()                     { return paymentMode; }
    public void   setPaymentMode(String paymentMode)   { this.paymentMode = paymentMode; }

    public List<Orderitem> getItems()                  { return items; }
    public void            setItems(List<Orderitem> items) { this.items = items; }
}