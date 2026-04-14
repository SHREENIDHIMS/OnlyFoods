package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import com.OnlyFoods.dao.AddressDAO;
import com.OnlyFoods.dao.UserDAO;
import com.OnlyFoods.daoimp.AddressDAOImpl;
import com.OnlyFoods.daoimp.UserDAOImpl;
import com.OnlyFoods.model.Address;
import com.OnlyFoods.model.Cart;
import com.OnlyFoods.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final BigDecimal DELIVERY_FEE = new BigDecimal("40.00");
    private static final BigDecimal GST_RATE      = new BigDecimal("0.05");

    private final AddressDAO addressDAO = new AddressDAOImpl();
    private final UserDAO    userDAO    = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/CartServlet");
            return;
        }

        // ── Pricing ───────────────────────────────────────────────
        BigDecimal subtotal   = BigDecimal.valueOf(cart.getTotalPrice())
                                           .setScale(2, RoundingMode.HALF_UP);
        BigDecimal gst        = subtotal.multiply(GST_RATE)
                                        .setScale(2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(DELIVERY_FEE).add(gst)
                                        .setScale(2, RoundingMode.HALF_UP);

        request.setAttribute("subtotal",    subtotal.doubleValue());
        request.setAttribute("deliveryFee", DELIVERY_FEE.doubleValue());
        request.setAttribute("gst",         gst.doubleValue());
        request.setAttribute("grandTotal",  grandTotal.doubleValue());

        // ── Load saved addresses for the address-selector widget ──
        int userId = (Integer) session.getAttribute("userId");
        List<Address> savedAddresses = addressDAO.getAddressesByUserId(userId);
        request.setAttribute("savedAddresses", savedAddresses);

        // ── Pre-fill name & phone from the user profile ───────────
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = userDAO.getUserById(userId);
        }
        request.setAttribute("prefillName",  user != null ? user.getUsername() : "");
        request.setAttribute("prefillPhone", user != null && user.getPhone() != null ? user.getPhone() : "");

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}