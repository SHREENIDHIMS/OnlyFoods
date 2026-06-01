<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.OnlyFoods.model.Cart, com.OnlyFoods.model.Cartitem" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">

    <style>
        .cart-container { max-width: 900px; margin: 0 auto; padding: 2rem; }

        @keyframes itemSlideIn {
            from { opacity: 0; transform: translateX(-18px); }
            to   { opacity: 1; transform: translateX(0); }
        }
        .cart-item {
            display: flex; gap: 1.5rem; padding: 1.5rem;
            background: var(--card); border-radius: 12px;
            margin-bottom: 1rem; box-shadow: var(--shadow);
            opacity: 0; animation: itemSlideIn 0.4s cubic-bezier(.22,1,.36,1) forwards;
            border: 1px solid var(--border);
            transition: border-color 0.35s;
        }
        .cart-item-img { width: 100px; height: 100px; border-radius: 8px; overflow: hidden; flex-shrink: 0; }
        .cart-item-img img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease; }
        .cart-item:hover .cart-item-img img { transform: scale(1.05); }
        .cart-item-details { flex: 1; }
        .cart-item-name     { font-size: 1.2rem; font-weight: 600; margin-bottom: 0.25rem; }
        .cart-item-restaurant { color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem; }
        .cart-item-price    { font-size: 1.1rem; font-weight: 600; color: var(--orange); }

        .cart-item-actions  { display: flex; flex-direction: column; gap: 0.5rem; align-items: flex-end; }

        .quantity-controls {
            display: flex; align-items: center; gap: 0.5rem;
            background: var(--bg2); border-radius: 8px; padding: 0.25rem;
        }
        .qty-btn {
            width: 32px; height: 32px; border: none;
            background: var(--card); color: var(--orange);
            border-radius: 6px; cursor: pointer;
            font-size: 1.1rem; font-weight: bold;
            transition: background 0.2s, transform 0.15s cubic-bezier(.34,1.56,.64,1);
        }
        .qty-btn:hover  { background: var(--orange); color: white; }
        .qty-btn:active { transform: scale(0.78); }
        .qty-display    { min-width: 40px; text-align: center; font-weight: 600; }

        @keyframes itemRemove {
            0%   { opacity: 1; transform: translateX(0) scaleY(1);   max-height: 200px; margin-bottom: 1rem; }
            40%  { opacity: 0; transform: translateX(40px) scaleY(0.9); }
            100% { opacity: 0; transform: translateX(40px) scaleY(0); max-height: 0; margin-bottom: 0; padding: 0; }
        }
        .cart-item.removing { animation: itemRemove 0.35s cubic-bezier(.4,0,.2,1) forwards; overflow: hidden; pointer-events: none; }

        .remove-btn {
            padding: 0.5rem 1rem; background: transparent;
            border: 1px solid var(--border); border-radius: 6px;
            color: var(--red); cursor: pointer;
            transition: all 0.25s ease; font-size: 0.9rem;
        }
        .remove-btn:hover { background: var(--red); color: white; border-color: var(--red); transform: scale(1.04); }

        @keyframes summaryIn {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .cart-summary {
            background: var(--card); padding: 2rem; border-radius: 12px;
            box-shadow: var(--shadow-h); margin-top: 2rem;
            border: 1px solid var(--border);
            animation: summaryIn 0.5s 0.3s cubic-bezier(.22,1,.36,1) both;
            transition: border-color 0.35s;
        }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 1rem; font-size: 1rem; }
        .summary-row.total {
            font-size: 1.5rem; font-weight: 700;
            padding-top: 1rem; border-top: 2px solid var(--border);
            color: var(--orange);
        }

        @keyframes checkoutPulse {
            0%, 100% { box-shadow: 0 4px 15px rgba(255,82,0,0.3); }
            50%       { box-shadow: 0 4px 28px rgba(255,82,0,0.6); }
        }
        .checkout-btn {
            width: 100%; padding: 1rem;
            background: linear-gradient(135deg, var(--orange), #ee4800);
            color: white; border: none; border-radius: 8px;
            font-size: 1.1rem; font-weight: 600; cursor: pointer;
            transition: transform 0.2s cubic-bezier(.34,1.56,.64,1), box-shadow 0.2s ease;
            margin-top: 1rem; text-decoration: none; display: block; text-align: center;
        }
        .checkout-btn:hover { transform: translateY(-3px) scale(1.01); animation: checkoutPulse 1.8s infinite; }
        .checkout-btn:active { transform: scale(0.97); animation: none; }

        .clear-cart-btn {
            width: 100%; padding: 0.75rem; background: transparent;
            border: 1px solid var(--border); border-radius: 6px;
            color: var(--muted); cursor: pointer; margin-top: 0.5rem; transition: all 0.2s;
        }
        .clear-cart-btn:hover { background: var(--red); color: white; border-color: var(--red); }

        .empty-cart { text-align: center; padding: 4rem 2rem; }
        .empty-cart-icon { font-size: 5rem; margin-bottom: 1rem; opacity: 0.3; }
        .empty-cart h2  { font-size: 1.8rem; margin-bottom: 0.5rem; }
        .empty-cart p   { color: var(--muted); margin-bottom: 2rem; }
        .browse-btn {
            display: inline-block; padding: 1rem 2rem;
            background: var(--orange); color: white; text-decoration: none;
            border-radius: 8px; font-weight: 600; transition: transform 0.2s;
        }
        .browse-btn:hover { transform: translateY(-2px); }
    </style>
</head>
<body>

<input type="checkbox" id="theme-toggle" hidden>

<div class="main">

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/RestaurantServlet" class="logo">OnlyFood's</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">Home</a>
            <a href="<%= request.getContextPath() %>/CartServlet" style="background:rgba(255,255,255,0.15); color:#fff;">🛒 Cart</a>
            <a href="<%= request.getContextPath() %>/profile">👤 Profile</a>
            <!-- FIX: context path + correct servlet URL -->
            <a href="<%= request.getContextPath() %>/LogoutServlet">Sign Out</a>
            <label for="theme-toggle" class="toggle-btn">🌙</label>
        </div>
    </nav>

    <main class="cart-container">
        <h1 style="margin-bottom: 2rem;">🛒 Your Cart</h1>

        <%
        Cart cart = (Cart) request.getAttribute("cart");
        if (cart == null) cart = (Cart) session.getAttribute("cart");

        if (cart != null && !cart.isEmpty()) {
            int cartIdx = 0;
            for (Cartitem item : cart.getItems().values()) {
        %>
            <div class="cart-item" id="cart-item-<%= item.getMenuId() %>"
                 style="animation-delay: <%= cartIdx * 0.08 %>s;">

                <div class="cart-item-img">
                    <% if (item.getImagePath() != null && !item.getImagePath().isEmpty()) { %>
                        <img src="<%= request.getContextPath() + "/" + item.getImagePath() %>"
                             alt="<%= item.getItemName() %>">
                    <% } else { %>
                        <img src="<%= request.getContextPath() %>/images/default-food.jpg"
                             alt="<%= item.getItemName() %>">
                    <% } %>
                </div>

                <div class="cart-item-details">
                    <div class="cart-item-name"><%= item.getItemName() %></div>
                    <div class="cart-item-restaurant">
                        <%= item.getRestaurantName() != null ? item.getRestaurantName() : "Restaurant" %>
                    </div>
                    <div class="cart-item-price">₹<%= String.format("%.2f", item.getPrice()) %> each</div>
                </div>

                <div class="cart-item-actions">
                    <form action="<%= request.getContextPath() %>/CartServlet" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="menuId" value="<%= item.getMenuId() %>">
                        <div class="quantity-controls">
                            <button type="submit" name="quantity" value="<%= item.getQuantity() - 1 %>" class="qty-btn">−</button>
                            <span class="qty-display"><%= item.getQuantity() %></span>
                            <button type="submit" name="quantity" value="<%= item.getQuantity() + 1 %>" class="qty-btn">+</button>
                        </div>
                    </form>

                    <div style="font-weight: 600; font-size: 1.1rem; color: var(--orange);">
                        ₹<%= String.format("%.2f", item.getSubtotal()) %>
                    </div>

                    <form action="<%= request.getContextPath() %>/CartServlet" method="post"
                          style="display:inline;"
                          onsubmit="return animateRemove(event, this, <%= item.getMenuId() %>)">
                        <input type="hidden" name="action" value="remove">
                        <input type="hidden" name="menuId" value="<%= item.getMenuId() %>">
                        <button type="submit" class="remove-btn">🗑️ Remove</button>
                    </form>
                </div>
            </div>
        <% cartIdx++; } %>

            <!-- Cart Summary -->
            <div class="cart-summary">
                <h2 style="margin-bottom: 1.5rem;">Order Summary</h2>

                <div class="summary-row">
                    <span>Subtotal (<%= cart.getTotalItems() %> items)</span>
                    <span>₹<%= String.format("%.2f", cart.getTotalPrice()) %></span>
                </div>
                <div class="summary-row">
                    <span>Delivery Fee</span>
                    <span>₹40.00</span>
                </div>
                <div class="summary-row">
                    <span>GST (5%)</span>
                    <span>₹<%= String.format("%.2f", cart.getTotalPrice() * 0.05) %></span>
                </div>
                <div class="summary-row total">
                    <span>Total</span>
                    <span>₹<%= String.format("%.2f", cart.getTotalPrice() + 40 + (cart.getTotalPrice() * 0.05)) %></span>
                </div>

                <%-- FIX: was a button calling triggerOrderPlaced() which showed a fake
                     "order placed" animation before checkout even happened.
                     Now it's a plain link to the checkout servlet. --%>
                <a href="<%= request.getContextPath() %>/checkout" class="checkout-btn">
                    Proceed to Checkout →
                </a>

                <form action="<%= request.getContextPath() %>/CartServlet" method="post">
                    <input type="hidden" name="action" value="clear">
                    <button type="submit" class="clear-cart-btn"
                            onclick="return confirm('Clear entire cart?')">
                        Clear Cart
                    </button>
                </form>
            </div>

        <% } else { %>

            <div class="empty-cart">
                <div class="empty-cart-icon">🛒</div>
                <h2>Your cart is empty</h2>
                <p>Add some delicious items to get started!</p>
                <a href="<%= request.getContextPath() %>/RestaurantServlet" class="browse-btn">
                    Browse Restaurants
                </a>
            </div>

        <% } %>

    </main>
</div>

<script>
function animateRemove(event, form, menuId) {
    event.preventDefault();
    var item = document.getElementById('cart-item-' + menuId);
    if (item) {
        item.classList.add('removing');
        setTimeout(function () { form.submit(); }, 380);
    } else {
        form.submit();
    }
    return false;
}

(function () {
    var toggle = document.getElementById("theme-toggle");
    var label  = document.querySelector("label[for='theme-toggle']");
    function applyTheme(isDark) { toggle.checked = isDark; if (label) label.textContent = isDark ? "☀️" : "🌙"; }
    applyTheme(localStorage.getItem("theme") === "dark");
    toggle.addEventListener("change", function () {
        localStorage.setItem("theme", toggle.checked ? "dark" : "light");
        applyTheme(toggle.checked);
    });
})();
</script>

</body>
</html>
