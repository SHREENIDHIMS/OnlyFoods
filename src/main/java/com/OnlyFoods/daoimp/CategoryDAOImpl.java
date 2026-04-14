package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.CategoryDAO;
import com.OnlyFoods.model.Category;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAOImpl implements CategoryDAO {

    private static final String GET_ALL =
        "SELECT id, name, image_url FROM categories ORDER BY display_order ASC";

    @Override
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category();
                cat.setId      (rs.getInt   ("id"));
                cat.setName    (rs.getString("name"));
                cat.setImageUrl(rs.getString("image_url"));
                categories.add(cat);
            }
        } catch (SQLException e) {
            System.err.println("[CategoryDAOImpl] getAllCategories error: " + e.getMessage());
            e.printStackTrace();
        }
        return categories;
    }
}
