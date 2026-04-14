package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.RestaurantDAO;
import com.OnlyFoods.model.Restaurant;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestaurantDAOImpl implements RestaurantDAO {

    private static final String GET_ALL =
        "SELECT * FROM restaurant WHERE isActive = 1";

    private static final String GET_BY_ID =
        "SELECT * FROM restaurant WHERE restaurantId = ?";

    @Override
    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRestaurant(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RestaurantDAOImpl] getAllRestaurants error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Restaurant getRestaurantById(int restaurantId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_ID)) {
            ps.setInt(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRestaurant(rs);
            }
        } catch (SQLException e) {
            System.err.println("[RestaurantDAOImpl] getRestaurantById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ── Mapper ────────────────────────────────────────────────────

    private Restaurant mapRestaurant(ResultSet rs) throws SQLException {
        Restaurant r = new Restaurant();
        r.setRestaurantId(rs.getInt    ("restaurantId"));
        r.setName        (rs.getString ("name"));
        r.setCuisineType (rs.getString ("cuisineType"));
        r.setDeliveryTime(rs.getInt    ("deliveryTime"));
        r.setAddress     (rs.getString ("address"));
        r.setAdminUserId (rs.getInt    ("adminUserId"));
        r.setRating      (rs.getDouble ("rating"));
        r.setActive      (rs.getBoolean("isActive"));
        r.setImagePath   (rs.getString ("imagePath"));
        return r;
    }
}
