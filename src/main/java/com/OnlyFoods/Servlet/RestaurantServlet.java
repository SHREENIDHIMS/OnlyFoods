package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.util.List;

import com.OnlyFoods.dao.CategoryDAO;
import com.OnlyFoods.dao.RestaurantDAO;
import com.OnlyFoods.daoimp.CategoryDAOImpl;
import com.OnlyFoods.daoimp.RestaurantDAOImpl;
import com.OnlyFoods.model.Category;
import com.OnlyFoods.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/RestaurantServlet")
public class RestaurantServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent browser caching of the restaurant list page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
        List<Restaurant> restaurants = restaurantDAO.getAllRestaurants();
        request.setAttribute("restaurants", restaurants);

        CategoryDAO categoryDAO = new CategoryDAOImpl();
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("Restaurant.jsp").forward(request, response);
    }
}
