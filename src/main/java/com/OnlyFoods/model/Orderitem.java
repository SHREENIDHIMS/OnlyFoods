package com.OnlyFoods.model;

/**
 * Maps to the `orderitem` table.
 * menuName is a joined field — populated by DAO, not stored in the table.
 */
public class Orderitem {

    private int    orderItemId;
    private int    orderId;
    private int    menuId;
    private int    quantity;
    private double totalPrice;

    // Joined field — populated by DAO
    private String menuName;

    // ── Constructors ──────────────────────────────────────────────

    public Orderitem() {}

    // ── Getters ──────────────────────────────────────────────────

    public int    getOrderItemId() { return orderItemId; }
    public int    getOrderId()     { return orderId; }
    public int    getMenuId()      { return menuId; }
    public int    getQuantity()    { return quantity; }
    public double getTotalPrice()  { return totalPrice; }
    public String getMenuName()    { return menuName; }

    // ── Setters ──────────────────────────────────────────────────

    public void setOrderItemId(int orderItemId)  { this.orderItemId = orderItemId; }
    public void setOrderId(int orderId)          { this.orderId     = orderId; }
    public void setMenuId(int menuId)            { this.menuId      = menuId; }
    public void setQuantity(int quantity)        { this.quantity    = quantity; }
    public void setTotalPrice(double totalPrice) { this.totalPrice  = totalPrice; }
    public void setMenuName(String menuName)     { this.menuName    = menuName; }
}