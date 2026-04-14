package com.OnlyFoods.dao;

import com.OnlyFoods.model.Restaurant;
import java.util.List;

public interface RestaurantDAO {

    /** Return all active restaurants. */
    List<Restaurant> getAllRestaurants();

    /** Return a single restaurant by its primary key (null if not found). */
    Restaurant getRestaurantById(int restaurantId);
}
