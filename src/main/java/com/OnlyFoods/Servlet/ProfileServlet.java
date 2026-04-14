package com.OnlyFoods.Servlet;

import com.OnlyFoods.dao.*;
import com.OnlyFoods.daoimp.AddressDAOImpl;
import com.OnlyFoods.daoimp.FavouriteDAOImpl;
import com.OnlyFoods.daoimp.OrderDAOImpl;
import com.OnlyFoods.daoimp.UserDAOImpl;
import com.OnlyFoods.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.List;

@WebServlet("/profile/*")
public class ProfileServlet extends HttpServlet {

    // FIX: all references updated from daoimp.* (old) to daoimpl.* (corrected package)
    private final UserDAO      userDAO    = new UserDAOImpl();
    private final OrderDAO     orderDAO   = new OrderDAOImpl();
    private final AddressDAO   addressDAO = new AddressDAOImpl();
    private final FavouriteDAO favDAO     = new FavouriteDAOImpl();

    // ── GET ────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireLogin(req, resp);
        if (user == null) return;

        loadProfileAttributes(req, user);
        req.getRequestDispatcher("/Profile.jsp").forward(req, resp);
    }

    // ── POST ───────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = requireLogin(req, resp);
        if (user == null) return;

        String pathInfo = req.getPathInfo();   // e.g. "/address", "/favourite", null

        if ("/address".equals(pathInfo)) {
            handleAddress(req, resp, user);
        } else if ("/favourite".equals(pathInfo)) {
            handleFavourite(req, resp, user);
        } else {
            handleProfileUpdate(req, resp, user);
        }
    }

    // ── Profile field updates ──────────────────────────────────────

    private void handleProfileUpdate(HttpServletRequest req,
                                     HttpServletResponse resp,
                                     User user)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("updatePhone".equals(action)) {

            String phone = trim(req.getParameter("phone"));
            if (phone.matches("\\d{10}")) {
                // FIX: delegate to DAO instead of raw SQL in servlet
                userDAO.updatePhone(user.getUserId(), phone);
                user.setPhone(phone);
                req.getSession().setAttribute("user", user);
                setMsg(req, "success", "Phone updated.");
            } else {
                setMsg(req, "error", "Enter a valid 10-digit phone number.");
            }

        } else if ("updateAddress".equals(action)) {

            String address = trim(req.getParameter("address"));
            if (!address.isEmpty()) {
                userDAO.updateAddress(user.getUserId(), address);
                user.setAddress(address);
                req.getSession().setAttribute("user", user);
                setMsg(req, "success", "Address updated.");
            } else {
                setMsg(req, "error", "Address cannot be blank.");
            }

        } else if ("changePassword".equals(action)) {

            String current = req.getParameter("currentPassword");
            String newPw   = req.getParameter("newPassword");
            String confirm = req.getParameter("confirmPassword");

            // Always fetch the latest hash from DB — don't trust session copy
            User freshUser      = userDAO.getUserById(user.getUserId());
            String storedHash   = freshUser != null ? freshUser.getPassword() : null;

            if (storedHash == null || !storedHash.startsWith("$2")) {
                setMsg(req, "error", "Password format invalid. Contact support.");
            } else if (current == null || !BCrypt.checkpw(current, storedHash)) {
                setMsg(req, "error", "Current password is incorrect.");
            } else if (newPw == null || newPw.length() < 6) {
                setMsg(req, "error", "New password must be at least 6 characters.");
            } else if (!newPw.equals(confirm)) {
                setMsg(req, "error", "Passwords do not match.");
            } else {
                String hashed = BCrypt.hashpw(newPw, BCrypt.gensalt());
                userDAO.updatePassword(user.getUserId(), hashed);
                user.setPassword(hashed);
                req.getSession().setAttribute("user", user);
                setMsg(req, "success", "Password changed successfully.");
            }
        }

        loadProfileAttributes(req, user);
        req.getRequestDispatcher("/Profile.jsp").forward(req, resp);
    }

    // ── Address management ─────────────────────────────────────────

    private void handleAddress(HttpServletRequest req,
                               HttpServletResponse resp,
                               User user)
            throws ServletException, IOException {

        String action    = req.getParameter("action");
        String label     = trim(req.getParameter("label"));
        String fullAddr  = trim(req.getParameter("fullAddress"));

        if ("add".equals(action)) {
            if (!fullAddr.isEmpty()) {
                Address a = new Address();
                a.setUserId     (user.getUserId());
                a.setLabel      (label.isEmpty() ? "Home" : label);
                a.setFullAddress(fullAddr);
                a.setDefault    (false);
                addressDAO.addAddress(a);
                setMsg(req, "success", "Address added.");
            } else {
                setMsg(req, "error", "Address cannot be blank.");
            }

        } else if ("delete".equals(action)) {
            int addrId = parseInt(req.getParameter("addressId"));
            if (addrId > 0) {
                addressDAO.deleteAddress(addrId, user.getUserId());
                setMsg(req, "success", "Address removed.");
            }

        } else if ("setDefault".equals(action)) {
            int addrId = parseInt(req.getParameter("addressId"));
            if (addrId > 0) {
                addressDAO.setDefault(addrId, user.getUserId());
                setMsg(req, "success", "Default address updated.");
            }
        }

        loadProfileAttributes(req, user);
        req.getRequestDispatcher("/Profile.jsp").forward(req, resp);
    }

    // ── Favourites ─────────────────────────────────────────────────

    private void handleFavourite(HttpServletRequest req,
                                 HttpServletResponse resp,
                                 User user)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String type   = req.getParameter("type");      // "restaurant" or "menu"
        int    id     = parseInt(req.getParameter("id"));

        if (id > 0) {
            if ("restaurant".equalsIgnoreCase(type)) {
                if ("remove".equals(action)) {
                    favDAO.removeFavouriteRestaurant(user.getUserId(), id);
                } else {
                    favDAO.addFavouriteRestaurant(user.getUserId(), id);
                }
            } else if ("menu".equalsIgnoreCase(type)) {
                if ("remove".equals(action)) {
                    favDAO.removeFavouriteMenu(user.getUserId(), id);
                } else {
                    favDAO.addFavouriteMenu(user.getUserId(), id);
                }
            }
        }

        loadProfileAttributes(req, user);
        req.getRequestDispatcher("/Profile.jsp").forward(req, resp);
    }

    // ── Shared helpers ─────────────────────────────────────────────

    private void loadProfileAttributes(HttpServletRequest req, User user) {
        int uid = user.getUserId();

        List<Order>    orders    = orderDAO.getOrdersByUserId(uid);
        List<Address>  addresses = addressDAO.getAddressesByUserId(uid);
        List<Favourite> favRest  = favDAO.getFavouriteRestaurants(uid);
        List<Favourite> favMenu  = favDAO.getFavouriteMenuItems(uid);

        req.setAttribute("orders",         orders);
        req.setAttribute("addresses",      addresses);
        req.setAttribute("favRestaurants", favRest);
        req.setAttribute("favMenus",       favMenu);
        req.setAttribute("orderCount",     orders    != null ? orders.size()    : 0);
        req.setAttribute("addrCount",      addresses != null ? addresses.size() : 0);
    }

    private User requireLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/Login.jsp");
        }
        return user;
    }

    private void setMsg(HttpServletRequest req, String type, String text) {
        req.setAttribute("msgType", type);
        req.setAttribute("msgText", text);
    }

    private String trim(String v) {
        return v != null ? v.trim() : "";
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }
}
