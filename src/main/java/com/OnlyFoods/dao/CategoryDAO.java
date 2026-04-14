package com.OnlyFoods.dao;

import com.OnlyFoods.model.Category;
import java.util.List;

public interface CategoryDAO {

    /** Return all categories ordered by display_order ASC. */
    List<Category> getAllCategories();
}
