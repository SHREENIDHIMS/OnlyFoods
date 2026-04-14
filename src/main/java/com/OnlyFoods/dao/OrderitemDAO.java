package com.OnlyFoods.dao;

import com.OnlyFoods.model.Orderitem;
import java.util.List;

/**
 * OrderitemDAO — CRUD operations on the orderitem table.
 *
 * Most writes are handled via OrderDAO.addOrderItems() (batch insert).
 * This DAO provides targeted queries when individual item access is needed.
 */
public interface OrderitemDAO {

    /**
     * Return all items for a given order, with menu item name populated.
     */
    List<Orderitem> getItemsByOrderId(int orderId);

    /**
     * Insert a single order item and return the generated orderItemId (-1 on failure).
     * Prefer OrderDAO.addOrderItems() for bulk inserts.
     */
    int addOrderItem(Orderitem item);

    /**
     * Delete all items belonging to an order.
     * Intended for order cancellation / correction flows.
     */
    boolean deleteItemsByOrderId(int orderId);
}
