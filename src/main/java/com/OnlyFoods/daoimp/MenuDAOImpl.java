package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.MenuDAO;
import com.OnlyFoods.model.Menu;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuDAOImpl implements MenuDAO {

    private static final String GET_BY_RESTAURANT =
        "SELECT * FROM menu WHERE restaurantId = ?";

    private static final String GET_BY_ID =
        "SELECT * FROM menu WHERE menuId = ?";

    @Override
    public List<Menu> getMenuByRestaurantId(int restaurantId) {
        List<Menu> list = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_RESTAURANT)) {
            ps.setInt(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapMenu(rs));
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAOImpl] getMenuByRestaurantId error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Menu getMenuById(int menuId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_ID)) {
            ps.setInt(1, menuId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapMenu(rs);
            }
        } catch (SQLException e) {
            System.err.println("[MenuDAOImpl] getMenuById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ── Mapper ────────────────────────────────────────────────────

    private Menu mapMenu(ResultSet rs) throws SQLException {
        Menu m = new Menu();
        m.setMenuId      (rs.getInt    ("menuId"));
        m.setRestaurantId(rs.getInt    ("restaurantId"));
        m.setItemName    (rs.getString ("itemName"));
        m.setDescription (rs.getString ("description"));
        m.setPrice       (rs.getDouble ("price"));
        m.setAvailable   (rs.getBoolean("isAvailable"));
        m.setImagePath   (rs.getString ("imagePath"));
        return m;
    }
}
