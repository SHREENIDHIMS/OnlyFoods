package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.OnlyFoods.dao.CartDAO;
import com.OnlyFoods.daoimp.CartDAOImpl;
import com.OnlyFoods.model.Cart;
import com.OnlyFoods.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * CartServlet — loads the user's cart from the DB into session,
 * then forwards to Cart.jsp.
 *
 * This servlet was missing from the project but is referenced by
 * CheckoutServlet (redirect on empty cart) and PlaceOrderServlet.
 */
@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent stale cart page from browser cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            // Always load a fresh cart from DB so session stays in sync
            Cart cart = cartDAO.getCartByUserId(user.getUserId());
            session.setAttribute("cart", cart);
            request.setAttribute("cart", cart);
        } catch (SQLException e) {
            System.err.println("[CartServlet] Error loading cart: " + e.getMessage());
            e.printStackTrace();
        }

        request.getRequestDispatcher("Cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        User user   = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        int    menuId = parseInt(request.getParameter("menuId"));

        if (menuId <= 0) {
            response.sendRedirect("CartServlet");
            return;
        }

        try {
            Cart cart = cartDAO.getCartByUserId(user.getUserId());

            if ("add".equals(action)) {
                int qty = parseInt(request.getParameter("quantity"));
                if (qty <= 0) qty = 1;
                cartDAO.addItemToCart(cart.getCartId(), menuId, qty);

            } else if ("update".equals(action)) {
                int qty = parseInt(request.getParameter("quantity"));
                cartDAO.updateCartItemQuantity(cart.getCartId(), menuId, qty);

            } else if ("remove".equals(action)) {
                cartDAO.removeItemFromCart(cart.getCartId(), menuId);

            } else if ("clear".equals(action)) {
                cartDAO.clearCart(cart.getCartId());
            }

            // Reload cart into session after mutation
            Cart updatedCart = cartDAO.getCartByUserId(user.getUserId());
            session.setAttribute("cart", updatedCart);

        } catch (SQLException e) {
            System.err.println("[CartServlet] Error updating cart: " + e.getMessage());
            e.printStackTrace();
        }

        response.sendRedirect("CartServlet");
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }
}
