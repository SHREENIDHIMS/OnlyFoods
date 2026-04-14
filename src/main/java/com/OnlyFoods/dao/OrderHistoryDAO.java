package com.OnlyFoods.dao;

import com.OnlyFoods.model.Order;
import java.util.List;

/**
 * OrderHistoryDAO — read-only view of a user's past orders.
 *
 * Separating history from OrderDAO keeps the order-placement path
 * independent of the reporting/display path.
 */
public interface OrderHistoryDAO {

    /**
     * Return all completed/cancelled orders for a user, newest first.
     * Each Order has its item list populated.
     */
    List<Order> getOrderHistoryByUserId(int userId);

    /**
     * Return a single order with full item detail.
     * Used for the "order detail" screen.
     *
     * @return Order, or null if not found / does not belong to userId
     */
    Order getOrderDetailByOrderId(int orderId, int userId);

    /**
     * Return the N most recent orders for a user (e.g. dashboard widget).
     *
     * @param limit max number of orders to return
     */
    List<Order> getRecentOrders(int userId, int limit);
}
