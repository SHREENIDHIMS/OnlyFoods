package com.OnlyFoods.model;

import java.sql.Timestamp;
import java.util.List;

/**
 * Maps to the `orders` table.
 * restaurantName and items are joined/populated by the DAO — not stored in the table.
 */
public class Order {

    private int            orderId;
    private int            userId;
    private int            restaurantId;
    private Timestamp      orderDate;
    private double         totalAmount;
    private String         status;
    private String         paymentMode;

    // Joined fields — populated by DAO
    private String         restaurantName;
    private List<Orderitem> items;

    // ── Constructors ──────────────────────────────────────────────

    public Order() {}

    // ── Getters ──────────────────────────────────────────────────

    public int            getOrderId()        { return orderId; }
    public int            getUserId()         { return userId; }
    public int            getRestaurantId()   { return restaurantId; }
    public Timestamp      getOrderDate()      { return orderDate; }
    public double         getTotalAmount()    { return totalAmount; }
    public String         getStatus()         { return status; }
    public String         getPaymentMode()    { return paymentMode; }
    public String         getRestaurantName() { return restaurantName; }
    public List<Orderitem> getItems()         { return items; }

    // ── Setters ──────────────────────────────────────────────────

    public void setOrderId(int orderId)            { this.orderId        = orderId; }
    public void setUserId(int userId)              { this.userId         = userId; }
    public void setRestaurantId(int restaurantId)  { this.restaurantId   = restaurantId; }
    public void setOrderDate(Timestamp orderDate)  { this.orderDate      = orderDate; }
    public void setTotalAmount(double totalAmount) { this.totalAmount    = totalAmount; }
    public void setStatus(String status)           { this.status         = status; }
    public void setPaymentMode(String paymentMode) { this.paymentMode    = paymentMode; }
    public void setRestaurantName(String name)     { this.restaurantName = name; }
    public void setItems(List<Orderitem> items)    { this.items          = items; }
}