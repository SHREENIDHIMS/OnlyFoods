package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.OrderitemDAO;
import com.OnlyFoods.model.Orderitem;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderitemDAOImpl implements OrderitemDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String GET_BY_ORDER =
        "SELECT oi.orderItemId, oi.orderId, oi.menuId, oi.quantity, oi.totalPrice, " +
        "       m.itemName " +
        "FROM orderitem oi " +
        "LEFT JOIN menu m ON oi.menuId = m.menuId " +
        "WHERE oi.orderId = ?";

    private static final String INSERT =
        "INSERT INTO orderitem (orderId, menuId, quantity, totalPrice) VALUES (?, ?, ?, ?)";

    private static final String DELETE_BY_ORDER =
        "DELETE FROM orderitem WHERE orderId = ?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public List<Orderitem> getItemsByOrderId(int orderId) {
        List<Orderitem> items = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_ORDER)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                items.add(mapItem(rs));
            }
        } catch (SQLException e) {
            System.err.println("[OrderitemDAOImpl] getItemsByOrderId error: " + e.getMessage());
            e.printStackTrace();
        }
        return items;
    }

    @Override
    public int addOrderItem(Orderitem item) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt   (1, item.getOrderId());
            ps.setInt   (2, item.getMenuId());
            ps.setInt   (3, item.getQuantity());
            ps.setDouble(4, item.getTotalPrice());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[OrderitemDAOImpl] addOrderItem error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean deleteItemsByOrderId(int orderId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(DELETE_BY_ORDER)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[OrderitemDAOImpl] deleteItemsByOrderId error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ── Mapper ────────────────────────────────────────────────────

    private Orderitem mapItem(ResultSet rs) throws SQLException {
        Orderitem item = new Orderitem();
        item.setOrderItemId(rs.getInt   ("orderItemId"));
        item.setOrderId    (rs.getInt   ("orderId"));
        item.setMenuId     (rs.getInt   ("menuId"));
        item.setQuantity   (rs.getInt   ("quantity"));
        item.setTotalPrice (rs.getDouble("totalPrice"));
        item.setMenuName   (rs.getString("itemName"));
        return item;
    }
}
