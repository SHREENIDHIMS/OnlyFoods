package com.OnlyFoods.Servlet;

import java.io.IOException;

import com.OnlyFoods.dao.UserDAO;
import com.OnlyFoods.daoimp.UserDAOImpl;
import com.OnlyFoods.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    // ── GET: show login page, redirect home if already logged in ──

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("RestaurantServlet");
            return;
        }
        request.getRequestDispatcher("Login.jsp").forward(request, response);
    }

    // ── POST: handle login form ───────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Blank check
        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        UserDAO dao = new UserDAOImpl();

        // Fetch user by email only — password NOT compared in SQL
        User user = dao.getUserByEmailAndPassword(email, password);

        if (user == null) {
            // Generic message — don't reveal whether the email exists
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }

        // BCrypt password verification
        boolean passwordMatches;
        try {
            passwordMatches = BCrypt.checkpw(password, user.getPassword());
        } catch (Exception e) {
            // Malformed hash in DB — treat as wrong password
            passwordMatches = false;
        }

        if (!passwordMatches) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
            return;
        }

        // FIX: update lastLoginDate in DB now that login is confirmed
        dao.updateLastLogin(user.getUserId());

        // Create session
        HttpSession session = request.getSession(true);
        session.setAttribute("user",     user);
        session.setAttribute("userId",   user.getUserId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("role",     user.getRole());
        session.setMaxInactiveInterval(60 * 60); // 1 hour

        response.sendRedirect("RestaurantServlet");
    }
}
