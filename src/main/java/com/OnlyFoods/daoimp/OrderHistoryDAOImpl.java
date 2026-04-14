package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.OrderHistoryDAO;
import com.OnlyFoods.model.Order;
import com.OnlyFoods.model.Orderitem;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OrderHistoryDAOImpl — read-only queries for a user's order history.
 *
 * Deliberately separate from OrderDAOImpl so the order-placement path
 * stays independent of the display/reporting path.
 */
public class OrderHistoryDAOImpl implements OrderHistoryDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String GET_HISTORY =
        "SELECT o.orderId, o.userId, o.restaurantId, o.orderDate, " +
        "       o.totalAmount, o.status, o.paymentMode, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.userId = ? " +
        "ORDER BY o.orderDate DESC";

    private static final String GET_ORDER_DETAIL =
        "SELECT o.orderId, o.userId, o.restaurantId, o.orderDate, " +
        "       o.totalAmount, o.status, o.paymentMode, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.orderId = ? AND o.userId = ?";

    private static final String GET_RECENT =
        "SELECT o.orderId, o.userId, o.restaurantId, o.orderDate, " +
        "       o.totalAmount, o.status, o.paymentMode, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.userId = ? " +
        "ORDER BY o.orderDate DESC " +
        "LIMIT ?";

    private static final String GET_ITEMS =
        "SELECT oi.orderItemId, oi.orderId, oi.menuId, oi.quantity, oi.totalPrice, " +
        "       m.itemName " +
        "FROM orderitem oi " +
        "LEFT JOIN menu m ON oi.menuId = m.menuId " +
        "WHERE oi.orderId = ?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public List<Order> getOrderHistoryByUserId(int userId) {
        List<Order> orders = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_HISTORY)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order order = mapOrder(rs);
                order.setItems(getItemsForOrder(order.getOrderId()));
                orders.add(order);
            }
        } catch (SQLException e) {
            System.err.println("[OrderHistoryDAOImpl] getOrderHistoryByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }

    @Override
    public Order getOrderDetailByOrderId(int orderId, int userId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ORDER_DETAIL)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = mapOrder(rs);
                order.setItems(getItemsForOrder(orderId));
                return order;
            }
        } catch (SQLException e) {
            System.err.println("[OrderHistoryDAOImpl] getOrderDetailByOrderId error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Order> getRecentOrders(int userId, int limit) {
        List<Order> orders = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_RECENT)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(mapOrder(rs));
            }
        } catch (SQLException e) {
            System.err.println("[OrderHistoryDAOImpl] getRecentOrders error: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }

    // ── Private helpers ───────────────────────────────────────────

    private List<Orderitem> getItemsForOrder(int orderId) {
        List<Orderitem> items = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ITEMS)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Orderitem item = new Orderitem();
                item.setOrderItemId(rs.getInt   ("orderItemId"));
                item.setOrderId    (rs.getInt   ("orderId"));
                item.setMenuId     (rs.getInt   ("menuId"));
                item.setQuantity   (rs.getInt   ("quantity"));
                item.setTotalPrice (rs.getDouble("totalPrice"));
                item.setMenuName   (rs.getString("itemName"));
                items.add(item);
            }
        } catch (SQLException e) {
            System.err.println("[OrderHistoryDAOImpl] getItemsForOrder error: " + e.getMessage());
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
