package com.OnlyFoods.dao;

import com.OnlyFoods.model.Menu;
import java.util.List;

public interface MenuDAO {

    /** Return all menu items for a restaurant. */
    List<Menu> getMenuByRestaurantId(int restaurantId);

    /** Return a single menu item by its primary key (null if not found). */
    Menu getMenuById(int menuId);
}
