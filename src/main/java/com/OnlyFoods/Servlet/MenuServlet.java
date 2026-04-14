package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.util.List;

import com.OnlyFoods.dao.MenuDAO;
import com.OnlyFoods.dao.RestaurantDAO;
import com.OnlyFoods.daoimp.MenuDAOImpl;
import com.OnlyFoods.daoimp.RestaurantDAOImpl;
import com.OnlyFoods.model.Menu;
import com.OnlyFoods.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/MenuServlet")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // FIX: safe parse — Integer.parseInt without guard crashes on missing param
        String param = request.getParameter("restaurantId");
        int restaurantId;
        try {
            restaurantId = Integer.parseInt(param);
        } catch (NumberFormatException e) {
            response.sendRedirect("RestaurantServlet");
            return;
        }

        MenuDAO       menuDAO       = new MenuDAOImpl();
        RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

        List<Menu>   menuList   = menuDAO.getMenuByRestaurantId(restaurantId);
        // FIX: fetch the restaurant so Menu.jsp can display its name in the header
        Restaurant   restaurant = restaurantDAO.getRestaurantById(restaurantId);

        request.setAttribute("menuList",       menuList);
        request.setAttribute("restaurantId",   restaurantId);
        // FIX: set restaurantName so Menu.jsp pageTitle is correct
        request.setAttribute("restaurantName", restaurant != null ? restaurant.getName() : "");

        request.getRequestDispatcher("Menu.jsp").forward(request, response);
    }
}
