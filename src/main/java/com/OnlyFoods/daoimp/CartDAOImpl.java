package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.CartDAO;
import com.OnlyFoods.model.Cart;
import com.OnlyFoods.model.Cartitem;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * CartDAOImpl — JDBC implementation of CartDAO.
 *
 * Every method opens its own connection via DBConnection.getDBConnection()
 * for consistency with the rest of the DAO layer.
 */
public class CartDAOImpl implements CartDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String SELECT_CART_BY_USER =
        "SELECT * FROM cart WHERE userId = ?";

    private static final String INSERT_CART =
        "INSERT INTO cart (userId, created_at, updated_at) VALUES (?, NOW(), NOW())";

    private static final String SELECT_CART_ITEMS =
        "SELECT ci.cart_item_id, ci.cart_id, ci.menuId, ci.quantity, " +
        "       m.itemName, m.price, m.imagePath, " +
        "       r.name AS restaurant_name " +
        "FROM cart_item ci " +
        "JOIN menu m       ON ci.menuId       = m.menuId " +
        "JOIN restaurant r ON m.restaurantId  = r.restaurantId " +
        "WHERE ci.cart_id = ?";

    private static final String SELECT_ITEM_QTY =
        "SELECT quantity FROM cart_item WHERE cart_id = ? AND menuId = ?";

    private static final String INSERT_ITEM =
        "INSERT INTO cart_item (cart_id, menuId, quantity) VALUES (?, ?, ?)";

    private static final String UPDATE_ITEM_QTY =
        "UPDATE cart_item SET quantity = ? WHERE cart_id = ? AND menuId = ?";

    private static final String DELETE_ITEM =
        "DELETE FROM cart_item WHERE cart_id = ? AND menuId = ?";

    private static final String DELETE_ALL_ITEMS =
        "DELETE FROM cart_item WHERE cart_id = ?";

    private static final String COUNT_ITEMS =
        "SELECT COALESCE(SUM(quantity), 0) AS total FROM cart_item WHERE cart_id = ?";

    private static final String TOUCH_CART =
        "UPDATE cart SET updated_at = NOW() WHERE cart_id = ?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public Cart getCartByUserId(int userId) throws SQLException {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_CART_BY_USER)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Cart cart = mapCart(rs);
                cart.setItems(getCartItemsInternal(cart.getCartId()));
                return cart;
            }
        }
        // No cart yet — create one
        return createCart(userId);
    }

    @Override
    public boolean addItemToCart(int cartId, int menuId, int quantity) throws SQLException {
        if (quantity <= 0) {
            return false;
        }
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement checkPs = con.prepareStatement(SELECT_ITEM_QTY)) {
            checkPs.setInt(1, cartId);
            checkPs.setInt(2, menuId);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                // Item exists — merge quantities
                int newQty = rs.getInt("quantity") + quantity;
                return updateCartItemQuantity(cartId, menuId, newQty);
            }
        }
        // Item does not exist — insert
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_ITEM)) {
            ps.setInt(1, cartId);
            ps.setInt(2, menuId);
            ps.setInt(3, quantity);
            boolean inserted = ps.executeUpdate() > 0;
            if (inserted) {
                touchCart(cartId);
            }
            return inserted;
        }
    }

    @Override
    public boolean updateCartItemQuantity(int cartId, int menuId, int quantity) throws SQLException {
        if (quantity <= 0) {
            return removeItemFromCart(cartId, menuId);
        }
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_ITEM_QTY)) {
            ps.setInt(1, quantity);
            ps.setInt(2, cartId);
            ps.setInt(3, menuId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                touchCart(cartId);
            }
            return updated;
        }
    }

    @Override
    public boolean removeItemFromCart(int cartId, int menuId) throws SQLException {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(DELETE_ITEM)) {
            ps.setInt(1, cartId);
            ps.setInt(2, menuId);
            boolean deleted = ps.executeUpdate() > 0;
            if (deleted) {
                touchCart(cartId);
            }
            return deleted;
        }
    }

    @Override
    public boolean clearCart(int cartId) throws SQLException {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(DELETE_ALL_ITEMS)) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
            touchCart(cartId);
            return true;
        }
    }

    @Override
    public int getCartItemCount(int cartId) throws SQLException {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(COUNT_ITEMS)) {
            ps.setInt(1, cartId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        }
        return 0;
    }

    // ── Private helpers ───────────────────────────────────────────

    private Cart createCart(int userId) throws SQLException {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_CART, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                Cart cart = new Cart(userId);
                cart.setCartId(keys.getInt(1));
                cart.setItems(new HashMap<>());
                return cart;
            }
        }
        throw new SQLException("Failed to create cart for userId=" + userId);
    }

    /** Internal helper — fetches items using a fresh connection. */
    private Map<Integer, Cartitem> getCartItemsInternal(int cartId) throws SQLException {
        Map<Integer, Cartitem> items = new HashMap<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_CART_ITEMS)) {
            ps.setInt(1, cartId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Cartitem item = new Cartitem();
                item.setCartItemId    (rs.getInt   ("cart_item_id"));
                item.setCartId        (rs.getInt   ("cart_id"));
                item.setMenuId        (rs.getInt   ("menuId"));
                item.setItemName      (rs.getString("itemName"));
                item.setPrice         (rs.getDouble("price"));
                item.setQuantity      (rs.getInt   ("quantity"));
                item.setRestaurantName(rs.getString("restaurant_name"));
                item.setImagePath     (rs.getString("imagePath"));
                items.put(item.getMenuId(), item);
            }
        }
        return items;
    }

    /** Touch the cart's updated_at timestamp after any mutation. */
    private void touchCart(int cartId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(TOUCH_CART)) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[CartDAOImpl] touchCart error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private Cart mapCart(ResultSet rs) throws SQLException {
        Cart cart = new Cart(rs.getInt("userId"));
        cart.setCartId   (rs.getInt      ("cart_id"));
        cart.setCreatedAt(rs.getTimestamp("created_at"));
        cart.setUpdatedAt(rs.getTimestamp("updated_at"));
        return cart;
    }
}
