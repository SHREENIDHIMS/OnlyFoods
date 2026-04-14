package com.OnlyFoods.Servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import com.OnlyFoods.dao.CartDAO;
import com.OnlyFoods.dao.MenuDAO;
import com.OnlyFoods.dao.OrderDAO;
import com.OnlyFoods.daoimp.CartDAOImpl;
import com.OnlyFoods.daoimp.MenuDAOImpl;
import com.OnlyFoods.daoimp.OrderDAOImpl;
import com.OnlyFoods.model.Cart;
import com.OnlyFoods.model.Cartitem;
import com.OnlyFoods.model.Menu;
import com.OnlyFoods.model.Order;
import com.OnlyFoods.model.Orderitem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/placeOrder")
public class PlaceOrderServlet extends HttpServlet {

    private static final BigDecimal DELIVERY_FEE = new BigDecimal("40.00");
    private static final BigDecimal GST_RATE      = new BigDecimal("0.05");

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final CartDAO  cartDAO  = new CartDAOImpl();
    private final MenuDAO  menuDAO  = new MenuDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ── 1. Validate session ───────────────────────────────────
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int  userId = (Integer) session.getAttribute("userId");
        Cart cart   = (Cart)    session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/CartServlet");
            return;
        }

        // ── 2. Extract form data ──────────────────────────────────
        String fullName      = trim(request.getParameter("fullName"));
        String phone         = trim(request.getParameter("phone"));
        String address       = trim(request.getParameter("address"));
        String city          = trim(request.getParameter("city"));
        String pincode       = trim(request.getParameter("pincode"));
        String instructions  = trim(request.getParameter("instructions"));
        String paymentMethod = trim(request.getParameter("paymentMethod"));

        // ── 3. Validate required fields ───────────────────────────
        if (fullName.isEmpty() || phone.isEmpty() || address.isEmpty() || paymentMethod.isEmpty()) {
            session.setAttribute("errorMsg", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        // ── 4. Build the display address string ───────────────────
        // When a saved address is selected, city="-" and pincode="000000" (placeholders).
        // In that case we just show the address as-is without appending them.
        String displayAddress;
        boolean isSavedAddress = "-".equals(city) || city.isEmpty();
        if (isSavedAddress) {
            displayAddress = address;
            // Normalise so DB / confirmation page look clean
            city    = "";
            pincode = "";
        } else {
            displayAddress = address + ", " + city + " - " + pincode;
        }

        // ── 5. Calculate totals ───────────────────────────────────
        BigDecimal subtotal   = BigDecimal.valueOf(cart.getTotalPrice())
                                           .setScale(2, RoundingMode.HALF_UP);
        BigDecimal gst        = subtotal.multiply(GST_RATE)
                                        .setScale(2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(DELIVERY_FEE).add(gst)
                                        .setScale(2, RoundingMode.HALF_UP);

        // ── 6. Resolve restaurantId from the first cart item ──────
        Cartitem firstItem = cart.getItems().values().iterator().next();
        Menu menu = menuDAO.getMenuById(firstItem.getMenuId());

        if (menu == null) {
            session.setAttribute("errorMsg", "Menu item not found. Please try again.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        int restaurantId = menu.getRestaurantId();

        // ── 7. Persist the order ──────────────────────────────────
        Order order = new Order();
        order.setUserId      (userId);
        order.setRestaurantId(restaurantId);
        order.setTotalAmount (grandTotal.doubleValue());
        order.setStatus      ("Pending");
        order.setPaymentMode (resolvePaymentMode(paymentMethod));

        int orderId = orderDAO.placeOrder(order);

        if (orderId == -1) {
            session.setAttribute("errorMsg", "Failed to place order. Please try again.");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        // ── 8. Persist order items ────────────────────────────────
        List<Orderitem> orderItems = new ArrayList<>();
        for (Cartitem item : cart.getItems().values()) {
            Orderitem oi = new Orderitem();
            oi.setOrderId   (orderId);
            oi.setMenuId    (item.getMenuId());
            oi.setQuantity  (item.getQuantity());
            oi.setTotalPrice(item.getSubtotal());
            orderItems.add(oi);
        }
        orderDAO.addOrderItems(orderItems);

        // ── 9. Clear cart (DB + session) ──────────────────────────
        try {
            cartDAO.clearCart(cart.getCartId());
        } catch (Exception e) {
            System.err.println("[PlaceOrderServlet] clearCart error: " + e.getMessage());
        }
        session.removeAttribute("cart");

        // ── 10. Store confirmation data ───────────────────────────
        session.setAttribute("orderId",              orderId);
        session.setAttribute("orderTotal",           grandTotal.doubleValue());
        session.setAttribute("deliveryAddress",      displayAddress);
        session.setAttribute("deliveryPhone",        phone);
        session.setAttribute("deliveryName",         fullName);
        session.setAttribute("paymentMethod",        resolvePaymentMode(paymentMethod));
        session.setAttribute("deliveryInstructions", instructions);

        response.sendRedirect(request.getContextPath() + "/orderConfirmation.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/checkout");
    }

    // ── Helpers ───────────────────────────────────────────────────

    private String resolvePaymentMode(String code) {
        if (code == null) return "Cash on Delivery";
        switch (code.toLowerCase()) {
            case "upi":        return "UPI";
            case "card":       return "Credit/Debit Card";
            case "netbanking": return "Net Banking";
            case "cod":
            default:           return "Cash on Delivery";
        }
    }

    private String trim(String v) {
        return v != null ? v.trim() : "";
    }
}