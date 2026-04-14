package com.OnlyFoods.dao;

import com.OnlyFoods.model.Address;
import java.util.List;

public interface AddressDAO {

    /** Return all addresses for a user, default first. */
    List<Address> getAddressesByUserId(int userId);

    /** Insert a new address and return the generated addressId (-1 on failure). */
    int addAddress(Address address);

    /** Update label, fullAddress and isDefault for an existing address. */
    boolean updateAddress(Address address);

    /** Delete an address belonging to the given user. */
    boolean deleteAddress(int addressId, int userId);

    /**
     * Mark one address as default.
     * Clears all other defaults for the user atomically (single transaction).
     */
    boolean setDefault(int addressId, int userId);

    /** Clear the default flag on every address for a user. */
    void clearDefault(int userId);
}
