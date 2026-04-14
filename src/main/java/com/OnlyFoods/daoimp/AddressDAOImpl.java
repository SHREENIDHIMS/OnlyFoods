package com.OnlyFoods.daoimp;

import com.OnlyFoods.dao.AddressDAO;
import com.OnlyFoods.model.Address;
import com.OnlyFoods.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AddressDAOImpl implements AddressDAO {

    // ── Queries ───────────────────────────────────────────────────

    private static final String GET_BY_USER =
        "SELECT * FROM addresses WHERE userId = ? ORDER BY isDefault DESC, addressId ASC";

    private static final String INSERT =
        "INSERT INTO addresses (userId, label, fullAddress, isDefault) VALUES (?, ?, ?, ?)";

    private static final String UPDATE =
        "UPDATE addresses SET label=?, fullAddress=?, isDefault=? WHERE addressId=? AND userId=?";

    private static final String DELETE =
        "DELETE FROM addresses WHERE addressId=? AND userId=?";

    private static final String CLEAR_DEFAULT =
        "UPDATE addresses SET isDefault=0 WHERE userId=?";

    private static final String SET_DEFAULT =
        "UPDATE addresses SET isDefault=1 WHERE addressId=? AND userId=?";

    // ── Interface methods ─────────────────────────────────────────

    @Override
    public List<Address> getAddressesByUserId(int userId) {
        List<Address> list = new ArrayList<>();
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(GET_BY_USER)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapAddress(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] getAddressesByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int addAddress(Address address) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt    (1, address.getUserId());
            ps.setString (2, address.getLabel());
            ps.setString (3, address.getFullAddress());
            ps.setBoolean(4, address.isDefault());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] addAddress error: " + e.getMessage());
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean updateAddress(Address address) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE)) {
            ps.setString (1, address.getLabel());
            ps.setString (2, address.getFullAddress());
            ps.setBoolean(3, address.isDefault());
            ps.setInt    (4, address.getAddressId());
            ps.setInt    (5, address.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] updateAddress error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean deleteAddress(int addressId, int userId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(DELETE)) {
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] deleteAddress error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Atomically clears all defaults for the user then marks the chosen address.
     * Uses a single Connection with manual transaction so both statements succeed or fail together.
     */
    @Override
    public boolean setDefault(int addressId, int userId) {
        try (Connection con = DBConnection.getDBConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(CLEAR_DEFAULT);
                 PreparedStatement ps2 = con.prepareStatement(SET_DEFAULT)) {
                ps1.setInt(1, userId);
                ps1.executeUpdate();
                ps2.setInt(1, addressId);
                ps2.setInt(2, userId);
                ps2.executeUpdate();
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                System.err.println("[AddressDAOImpl] setDefault rollback: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] setDefault connection error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Clears the default flag on every address belonging to a user.
     * Used standalone when a default address is deleted.
     */
    @Override
    public void clearDefault(int userId) {
        try (Connection con = DBConnection.getDBConnection();
             PreparedStatement ps = con.prepareStatement(CLEAR_DEFAULT)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[AddressDAOImpl] clearDefault error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Mapper ────────────────────────────────────────────────────

    private Address mapAddress(ResultSet rs) throws SQLException {
        Address a = new Address();
        a.setAddressId  (rs.getInt    ("addressId"));
        a.setUserId     (rs.getInt    ("userId"));
        a.setLabel      (rs.getString ("label"));
        a.setFullAddress(rs.getString ("fullAddress"));
        a.setDefault    (rs.getBoolean("isDefault"));
        return a;
    }
}
