package com.OnlyFoods.dao;

import com.OnlyFoods.model.Cart;
import java.sql.SQLException;

public interface CartDAO {

    /** Get cart for a user (creates one if it does not exist). */
    Cart getCartByUserId(int userId) throws SQLException;

    /** Add item to cart; merges quantity if item already exists. */
    boolean addItemToCart(int cartId, int menuId, int quantity) throws SQLException;

    /** Set exact quantity for a cart item; removes it when quantity <= 0. */
    boolean updateCartItemQuantity(int cartId, int menuId, int quantity) throws SQLException;

    /** Remove a single item from the cart. */
    boolean removeItemFromCart(int cartId, int menuId) throws SQLException;

    /** Delete every item in the cart (used after order placement). */
    boolean clearCart(int cartId) throws SQLException;

    /** Sum of all item quantities currently in the cart. */
    int getCartItemCount(int cartId) throws SQLException;
}
