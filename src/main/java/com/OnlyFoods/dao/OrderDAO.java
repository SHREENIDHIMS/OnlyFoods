package com.OnlyFoods.dao;

import com.OnlyFoods.model.Order;
import com.OnlyFoods.model.Orderitem;
import java.util.List;

public interface OrderDAO {

    /** Return all orders for a user, newest first. */
    List<Order> getOrdersByUserId(int userId);

    /** Return a single order with its items populated (null if not found). */
    Order getOrderById(int orderId);

    /** Insert a new order and return the generated orderId (-1 on failure). */
    int placeOrder(Order order);

    /** Batch-insert order items for a given order. */
    void addOrderItems(List<Orderitem> items);

    /** Total number of orders placed by a user. */
    int countOrdersByUserId(int userId);
}
