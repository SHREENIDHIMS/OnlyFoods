package com.OnlyFoods.model;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

/**
 * Maps to the `cart` table.
 * Items are keyed by menuId for O(1) lookup and duplicate merging.
 *
 * FIX: createdAt / updatedAt changed from java.util.Date → java.sql.Timestamp
 *      to match what JDBC returns for TIMESTAMP columns and what CartDAOImpl sets.
 */
public class Cart {

    private int       cartId;
    private int       userId;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Map<Integer, Cartitem> items;

    // ── Constructors ──────────────────────────────────────────────

    public Cart() {
        this.items = new HashMap<>();
    }

    public Cart(int userId) {
        this.userId = userId;
        this.items  = new HashMap<>();
    }

    // ── Getters / Setters ─────────────────────────────────────────

    public int       getCartId()    { return cartId; }
    public void      setCartId(int cartId)       { this.cartId    = cartId; }

    public int       getUserId()    { return userId; }
    public void      setUserId(int userId)        { this.userId    = userId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void      setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void      setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Map<Integer, Cartitem> getItems() { return items; }
    public void setItems(Map<Integer, Cartitem> items) { this.items = items; }

    // ── Business methods ──────────────────────────────────────────

    /**
     * Add an item to the cart.
     * If the menuId already exists, quantities are merged.
     */
    public void addItem(Cartitem item) {
        if (this.items.containsKey(item.getMenuId())) {
            Cartitem existing = this.items.get(item.getMenuId());
            existing.setQuantity(existing.getQuantity() + item.getQuantity());
        } else {
            this.items.put(item.getMenuId(), item);
        }
    }

    public void removeItem(int menuId) {
        this.items.remove(menuId);
    }

    /** Sum of all item quantities. */
    public int getTotalItems() {
        return items.values().stream().mapToInt(Cartitem::getQuantity).sum();
    }

    /** Sum of (price × quantity) for all items. */
    public double getTotalPrice() {
        return items.values().stream().mapToDouble(Cartitem::getSubtotal).sum();
    }

    public boolean isEmpty() {
        return items == null || items.isEmpty();
    }
}