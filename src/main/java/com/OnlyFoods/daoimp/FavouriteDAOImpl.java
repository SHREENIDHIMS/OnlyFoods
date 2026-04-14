package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.FavouriteDAO;
import com.OnlyFoods.model.Favourite;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavouriteDAOImpl implements FavouriteDAO {

    // ── Queries — Restaurants ─────────────────────────────────────

    private static final String GET_FAV_RESTAURANTS =
        "SELECT fr.favRestId, fr.userId, fr.restaurantId, " +
        "       r.name, r.cuisineType " +
        "FROM favouriterestaurant fr " +
        "JOIN restaurant r ON fr.restaurantId = r.restaurantId " +
        "WHERE fr.userId = ?";

    private static final String ADD_FAV_RESTAURANT =
        "INSERT IGNORE INTO favouriterestaurant (userId, restaurantId) VALUES (?, ?)";

    private static final String REMOVE_FAV_RESTAURANT =
        "DELETE FROM favouriterestaurant WHERE userId=? AND restaurantId=?";

    private static final String IS_RESTAURANT_FAVED =
        "SELECT 1 FROM favouriterestaurant WHERE userId=? AND restaurantId=?";

    // ── Queries — Menu items ──────────────────────────────────────

    // FIX: schema column is `itemName`, not `name`
    private static final String GET_FAV_MENUS =
        "SELECT fm.favMenuId, fm.userId, fm.menuId, " +
        "       m.itemName, r.name AS restaurantName " +
        "FROM favouritemenu fm " +
        "JOIN menu m       ON fm.menuId       = m.menuId " +
        "JOIN restaurant r ON m.restaurantId  = r.restaurantId " +
        "WHERE fm.userId = ?";

    private static final String ADD_FAV_MENU =
        "INSERT IGNORE INTO favouritemenu (userId, menuId) VALUES (?, ?)";

    private static final String REMOVE_FAV_MENU =
        "DELETE FROM favouritemenu WHERE userId=? AND menuId=?";

    private static final String IS_MENU_FAVED =
        "SELECT 1 FROM favouritemenu WHERE userId=? AND menuId=?";

    // ── Restaurant favourites ─────────────────────────────────────

    @Override
    public List<Favourite> getFavouriteRestaurants(int userId) {
        List<Favourite> list = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_FAV_RESTAURANTS)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Favourite f = new Favourite();
                f.setId      (rs.getInt   ("favRestId"));
                f.setUserId  (userId);
                f.setTargetId(rs.getInt   ("restaurantId"));
                f.setName    (rs.getString("name"));
                f.setSubText (rs.getString("cuisineType"));
                f.setType    (Favourite.Type.RESTAURANT);
                list.add(f);
            }
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] getFavouriteRestaurants error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addFavouriteRestaurant(int userId, int restaurantId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(ADD_FAV_RESTAURANT)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] addFavouriteRestaurant error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean removeFavouriteRestaurant(int userId, int restaurantId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(REMOVE_FAV_RESTAURANT)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] removeFavouriteRestaurant error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean isRestaurantFavourited(int userId, int restaurantId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(IS_RESTAURANT_FAVED)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] isRestaurantFavourited error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ── Menu favourites ───────────────────────────────────────────

    @Override
    public List<Favourite> getFavouriteMenuItems(int userId) {
        List<Favourite> list = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_FAV_MENUS)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Favourite f = new Favourite();
                f.setId      (rs.getInt   ("favMenuId"));
                f.setUserId  (userId);
                f.setTargetId(rs.getInt   ("menuId"));
                f.setName    (rs.getString("itemName"));          // FIX: was "name"
                f.setSubText (rs.getString("restaurantName"));
                f.setType    (Favourite.Type.MENU);
                list.add(f);
            }
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] getFavouriteMenuItems error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addFavouriteMenu(int userId, int menuId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(ADD_FAV_MENU)) {
            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] addFavouriteMenu error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean removeFavouriteMenu(int userId, int menuId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(REMOVE_FAV_MENU)) {
            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] removeFavouriteMenu error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean isMenuFavourited(int userId, int menuId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(IS_MENU_FAVED)) {
            ps.setInt(1, userId);
            ps.setInt(2, menuId);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            System.err.println("[FavouriteDAOImpl] isMenuFavourited error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
