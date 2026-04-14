package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.UserDAO;
import com.OnlyFoods.model.User;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;

/**
 * UserDAOImpl — JDBC implementation of UserDAO.
 *
 * Password security:
 *   addUser()                    → caller passes a BCrypt hash in user.getPassword()
 *   getUserByEmailAndPassword()  → fetches by EMAIL only; BCrypt.checkpw() is
 *                                  called in LoginServlet after this returns
 */
public class UserDAOImpl implements UserDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String INSERT_USER =
        "INSERT INTO user (username, password, email, phone, address, role, createdDate) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String GET_BY_EMAIL =
        "SELECT * FROM user WHERE email = ?";

    private static final String GET_BY_ID =
        "SELECT * FROM user WHERE userId = ?";

    private static final String EMAIL_EXISTS =
        "SELECT 1 FROM user WHERE email = ?";

    private static final String UPDATE_LAST_LOGIN =
        "UPDATE user SET lastLoginDate = NOW() WHERE userId = ?";

    private static final String UPDATE_PHONE =
        "UPDATE user SET phone = ? WHERE userId = ?";

    private static final String UPDATE_ADDRESS =
        "UPDATE user SET address = ? WHERE userId = ?";

    private static final String UPDATE_PASSWORD =
        "UPDATE user SET password = ? WHERE userId = ?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public int addUser(User user) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_USER)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());                               // BCrypt hash
            ps.setString(3, user.getEmail().toLowerCase());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole() != null ? user.getRole() : "USER");
            ps.setDate  (7, user.getCreatedDate() != null
                            ? Date.valueOf(user.getCreatedDate()) : null);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[UserDAOImpl] addUser error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Fetches user by email only.
     * {@code password} param is intentionally NOT used in SQL.
     */
    @Override
    public User getUserByEmailAndPassword(String email, String password) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_EMAIL)) {
            ps.setString(1, email.toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[UserDAOImpl] getUserByEmailAndPassword error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public User getUserById(int userId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_ID)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[UserDAOImpl] getUserById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean emailExists(String email) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(EMAIL_EXISTS)) {
            ps.setString(1, email.toLowerCase());
            return ps.executeQuery().next();
        } catch (SQLException e) {
            System.err.println("[UserDAOImpl] emailExists error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public void updateLastLogin(int userId) {
        executeUpdate(UPDATE_LAST_LOGIN, "updateLastLogin", ps -> ps.setInt(1, userId));
    }

    @Override
    public void updatePhone(int userId, String phone) {
        executeUpdate(UPDATE_PHONE, "updatePhone", ps -> {
            ps.setString(1, phone);
            ps.setInt   (2, userId);
        });
    }

    @Override
    public void updateAddress(int userId, String address) {
        executeUpdate(UPDATE_ADDRESS, "updateAddress", ps -> {
            ps.setString(1, address);
            ps.setInt   (2, userId);
        });
    }

    @Override
    public void updatePassword(int userId, String bcryptHash) {
        executeUpdate(UPDATE_PASSWORD, "updatePassword", ps -> {
            ps.setString(1, bcryptHash);
            ps.setInt   (2, userId);
        });
    }

    // ── Private helpers ───────────────────────────────────────────

    @FunctionalInterface
    private interface StatementSetter {
        void set(PreparedStatement ps) throws SQLException;
    }

    private void executeUpdate(String sql, String methodName, StatementSetter setter) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            setter.set(ps);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[UserDAOImpl] " + methodName + " error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId  (rs.getInt   ("userId"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));   // hash — needed for BCrypt check
        user.setEmail   (rs.getString("email"));
        user.setPhone   (rs.getString("phone"));
        user.setAddress (rs.getString("address"));
        user.setRole    (rs.getString("role"));

        Date createdDate = rs.getDate("createdDate");
        if (createdDate != null) user.setCreatedDate(createdDate.toLocalDate());

        Date lastLogin = rs.getDate("lastLoginDate");
        if (lastLogin != null) user.setLastLoginDate(lastLogin.toLocalDate());

        return user;
    }
}
