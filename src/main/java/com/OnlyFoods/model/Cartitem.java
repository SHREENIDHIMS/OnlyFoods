package com.OnlyFoods.model;

/**
 * Maps to the `cart_item` table.
 * Also carries joined fields (itemName, price, imagePath, restaurantName)
 * populated by CartDAOImpl at query time.
 */
public class Cartitem {

    private int    cartItemId;
    private int    cartId;
    private int    menuId;
    private String itemName;
    private double price;
    private int    quantity;
    private String restaurantName;
    private String imagePath;

    // ── Constructors ──────────────────────────────────────────────

    public Cartitem() {}

    public Cartitem(int cartId, int menuId, String itemName, double price, int quantity) {
        this.cartId   = cartId;
        this.menuId   = menuId;
        this.itemName = itemName;
        this.price    = price;
        this.quantity = quantity;
    }

    // ── Getters / Setters ─────────────────────────────────────────

    public int    getCartItemId()              { return cartItemId; }
    public void   setCartItemId(int cartItemId){ this.cartItemId = cartItemId; }

    public int    getCartId()                  { return cartId; }
    public void   setCartId(int cartId)        { this.cartId = cartId; }

    public int    getMenuId()                  { return menuId; }
    public void   setMenuId(int menuId)        { this.menuId = menuId; }

    public String getItemName()                { return itemName; }
    public void   setItemName(String itemName) { this.itemName = itemName; }

    public double getPrice()                   { return price; }
    public void   setPrice(double price)       { this.price = price; }

    public int    getQuantity()                { return quantity; }
    public void   setQuantity(int quantity)    { this.quantity = quantity; }

    public String getRestaurantName()                      { return restaurantName; }
    public void   setRestaurantName(String restaurantName) { this.restaurantName = restaurantName; }

    public String getImagePath()               { return imagePath; }
    public void   setImagePath(String imagePath){ this.imagePath = imagePath; }

    // ── Computed ──────────────────────────────────────────────────

    /** price × quantity */
    public double getSubtotal() {
        return price * quantity;
    }

    /**
     * Alias for JSP compatibility — checkout.jsp uses ${item.menuName}.
     * Both getItemName() and getMenuName() return the same value.
     */
    public String getMenuName() {
        return itemName;
    }
}