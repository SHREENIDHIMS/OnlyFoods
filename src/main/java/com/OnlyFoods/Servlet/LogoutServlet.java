package com.OnlyFoods.Servlet;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        // Invalidate session — clears user, userId, username, role, cart
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        res.sendRedirect("Login.jsp");
    }
}
