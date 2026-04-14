package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.time.LocalDate;

import com.OnlyFoods.dao.UserDAO;
import com.OnlyFoods.daoimp.UserDAOImpl;
import com.OnlyFoods.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    // ── GET: show register page ───────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("Register.jsp").forward(request, response);
    }

    // ── POST: handle registration form ───────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username        = trim(request.getParameter("username"));
        String email           = trim(request.getParameter("email"));
        String phone           = trim(request.getParameter("phone"));
        String address         = trim(request.getParameter("address"));
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Required fields
        if (username.isEmpty() || email.isEmpty()
                || password == null || password.isEmpty()) {
            request.setAttribute("error", "Username, email and password are required.");
            repopulate(request, username, email, phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        // Email format
        if (!email.matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            request.setAttribute("error", "Please enter a valid email address.");
            repopulate(request, username, email, phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        // Password length
        if (password.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters.");
            repopulate(request, username, email, phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        // Password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            repopulate(request, username, email, phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAOImpl();

        // Duplicate email check
        if (dao.emailExists(email.toLowerCase())) {
            request.setAttribute("error",
                "An account with this email already exists. Please sign in.");
            repopulate(request, username, "", phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        // Hash password with BCrypt (cost factor 12)
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

        User newUser = new User();
        newUser.setUsername   (username);
        newUser.setPassword   (hashedPassword);
        newUser.setEmail      (email.toLowerCase());
        newUser.setPhone      (phone);
        newUser.setAddress    (address);
        newUser.setRole       ("USER");
        newUser.setCreatedDate(LocalDate.now());

        int result = dao.addUser(newUser);

        if (result == 0) {
            request.setAttribute("error", "Registration failed. Please try again.");
            repopulate(request, username, email, phone, address);
            request.getRequestDispatcher("Register.jsp").forward(request, response);
            return;
        }

        // Success → redirect to login with flag
        response.sendRedirect("Login.jsp?registered=true");
    }

    // ── Helpers ───────────────────────────────────────────────────

    private void repopulate(HttpServletRequest req,
                            String username, String email,
                            String phone, String address) {
        req.setAttribute("username", username);
        req.setAttribute("email",    email);
        req.setAttribute("phone",    phone);
        req.setAttribute("address",  address);
    }

    private String trim(String v) {
        return v != null ? v.trim() : "";
    }
}
