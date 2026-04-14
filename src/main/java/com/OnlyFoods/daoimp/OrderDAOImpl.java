package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.OrderDAO;
import com.OnlyFoods.model.Order;
import com.OnlyFoods.model.Orderitem;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAOImpl implements OrderDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String GET_ORDERS_BY_USER =
        "SELECT o.orderId, o.userId, o.restaurantId, o.orderDate, " +
        "       o.totalAmount, o.status, o.paymentMode, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.userId = ? " +
        "ORDER BY o.orderDate DESC";

    private static final String GET_ORDER_BY_ID =
        "SELECT o.orderId, o.userId, o.restaurantId, o.orderDate, " +
        "       o.totalAmount, o.status, o.paymentMode, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.orderId = ?";

    private static final String PLACE_ORDER =
        "INSERT INTO orders (userId, restaurantId, orderDate, totalAmount, status, paymentMode) " +
        "VALUES (?, ?, NOW(), ?, ?, ?)";

    // FIX: schema column is `itemName`, not `name`
    private static final String GET_ITEMS_BY_ORDER =
        "SELECT oi.orderItemId, oi.orderId, oi.menuId, oi.quantity, oi.totalPrice, " +
        "       m.itemName " +
        "FROM orderitem oi " +
        "LEFT JOIN menu m ON oi.menuId = m.menuId " +
        "WHERE oi.orderId = ?";

    private static final String INSERT_ORDER_ITEM =
        "INSERT INTO orderitem (orderId, menuId, quantity, totalPrice) VALUES (?, ?, ?, ?)";

    private static final String COUNT_ORDERS_BY_USER =
        "SELECT COUNT(*) FROM orders WHERE userId = ?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ORDERS_BY_USER)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapOrder(rs));
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] getOrdersByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }

    @Override
    public Order getOrderById(int orderId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ORDER_BY_ID)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = mapOrder(rs);
                order.setItems(getItemsByOrderId(orderId));
                return order;
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] getOrderById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public int placeOrder(Order order) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(PLACE_ORDER, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt   (1, order.getUserId());
            ps.setInt   (2, order.getRestaurantId());
            ps.setDouble(3, order.getTotalAmount());
            ps.setString(4, order.getStatus());
            ps.setString(5, order.getPaymentMode());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] placeOrder error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public void addOrderItems(List<Orderitem> items) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_ORDER_ITEM)) {
            for (Orderitem item : items) {
                ps.setInt   (1, item.getOrderId());
                ps.setInt   (2, item.getMenuId());
                ps.setInt   (3, item.getQuantity());
                ps.setDouble(4, item.getTotalPrice());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] addOrderItems error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public int countOrdersByUserId(int userId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(COUNT_ORDERS_BY_USER)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] countOrdersByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // ── Private helpers ───────────────────────────────────────────

    private List<Orderitem> getItemsByOrderId(int orderId) {
        List<Orderitem> items = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ITEMS_BY_ORDER)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Orderitem item = new Orderitem();
                item.setOrderItemId(rs.getInt   ("orderItemId"));
                item.setOrderId    (rs.getInt   ("orderId"));
                item.setMenuId     (rs.getInt   ("menuId"));
                item.setQuantity   (rs.getInt   ("quantity"));
                item.setTotalPrice (rs.getDouble("totalPrice"));
                item.setMenuName   (rs.getString("itemName"));   // FIX: was "menuName" alias on wrong column
                items.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[OrderDAOImpl] getItemsByOrderId error: " + e.getMessage());
            e.printStackTrace();
        }
        return items;
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId       (rs.getInt      ("orderId"));
        o.setUserId        (rs.getInt      ("userId"));
        o.setRestaurantId  (rs.getInt      ("restaurantId"));
        o.setOrderDate     (rs.getTimestamp("orderDate"));
        o.setTotalAmount   (rs.getDouble   ("totalAmount"));
        o.setStatus        (rs.getString   ("status"));
        o.setPaymentMode   (rs.getString   ("paymentMode"));
        o.setRestaurantName(rs.getString   ("restaurantName"));
        return o;
    }
}
