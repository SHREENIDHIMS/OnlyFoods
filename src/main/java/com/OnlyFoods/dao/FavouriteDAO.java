package com.OnlyFoods.dao;

import com.OnlyFoods.model.Favourite;
import java.util.List;

public interface FavouriteDAO {

    // ── Restaurants ──────────────────────────────────────────────
    List<Favourite> getFavouriteRestaurants(int userId);
    boolean         addFavouriteRestaurant(int userId, int restaurantId);
    boolean         removeFavouriteRestaurant(int userId, int restaurantId);
    boolean         isRestaurantFavourited(int userId, int restaurantId);

    // ── Menu items ───────────────────────────────────────────────
    List<Favourite> getFavouriteMenuItems(int userId);
    boolean         addFavouriteMenu(int userId, int menuId);
    boolean         removeFavouriteMenu(int userId, int menuId);
    boolean         isMenuFavourited(int userId, int menuId);
}
