<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Integer orderId     = (Integer) session.getAttribute("orderId");
    Double  orderTotal  = (Double)  session.getAttribute("orderTotal");
    String  deliveryAddr= (String)  session.getAttribute("deliveryAddress");
    String  deliveryName= (String)  session.getAttribute("deliveryName");
    String  paymentMode = (String)  session.getAttribute("paymentMethod");

    if (orderId == null) {
        response.sendRedirect(request.getContextPath() + "/RestaurantServlet");
        return;
    }

    // Clean up confirmation attributes after reading
    session.removeAttribute("orderId");
    session.removeAttribute("orderTotal");
    session.removeAttribute("deliveryAddress");
    session.removeAttribute("deliveryPhone");
    session.removeAttribute("deliveryName");
    session.removeAttribute("paymentMethod");
    session.removeAttribute("deliveryInstructions");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">
    <style>
        .confirm-wrap {
            max-width: 560px; margin: 0 auto;
            padding: 60px 24px 80px;
            text-align: center;
        }

        /* Animated checkmark circle */
        @keyframes circleScale {
            0%   { transform: scale(0); opacity: 0; }
            60%  { transform: scale(1.15); }
            100% { transform: scale(1);   opacity: 1; }
        }
        @keyframes checkDraw {
            0%   { stroke-dashoffset: 100; }
            100% { stroke-dashoffset: 0; }
        }
        .check-circle {
            width: 96px; height: 96px;
            background: #e8f8ee; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px;
            animation: circleScale 0.5s cubic-bezier(.34,1.56,.64,1) both;
        }
        .check-svg { width: 48px; height: 48px; }
        .check-svg path {
            stroke: #1a7a3a; stroke-width: 4;
            stroke-linecap: round; stroke-linejoin: round;
            fill: none;
            stroke-dasharray: 100;
            stroke-dashoffset: 100;
            animation: checkDraw 0.45s 0.3s ease forwards;
        }

        @keyframes titleIn {
            from { opacity: 0; transform: translateY(12px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .confirm-title {
            font-family: 'Syne', sans-serif;
            font-size: 32px; font-weight: 800;
            color: var(--text); margin-bottom: 8px;
            animation: titleIn 0.4s 0.4s ease both;
        }
        .confirm-sub {
            font-size: 15px; color: var(--muted);
            margin-bottom: 36px;
            animation: titleIn 0.4s 0.5s ease both;
        }

        .order-card {
            background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 24px 28px;
            text-align: left; box-shadow: var(--shadow);
            margin-bottom: 24px;
            animation: titleIn 0.4s 0.6s ease both;
            transition: border-color 0.35s;
        }
        .order-card-title {
            font-family: 'Syne', sans-serif;
            font-size: 14px; font-weight: 700; color: var(--text);
            margin-bottom: 16px; text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        .detail-row {
            display: flex; justify-content: space-between;
            align-items: flex-start; gap: 12px;
            padding: 8px 0; border-bottom: 1px solid var(--border);
            font-size: 14px; transition: border-color 0.35s;
        }
        .detail-row:last-child { border-bottom: none; padding-bottom: 0; }
        .detail-label { color: var(--muted); flex-shrink: 0; }
        .detail-value { color: var(--text); text-align: right; font-weight: 500; }
        .detail-value.highlight { color: var(--orange); font-weight: 700; font-size: 16px; }

        /* Swiggy-style order tracker */
        .tracker-card {
            background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 24px 28px;
            text-align: left; box-shadow: var(--shadow);
            margin-bottom: 32px;
            animation: titleIn 0.4s 0.7s ease both;
            transition: border-color 0.35s;
        }
        .tracker-card-title {
            font-family: 'Syne', sans-serif;
            font-size: 14px; font-weight: 700; color: var(--text);
            margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.08em;
        }
        .tracker { display: flex; flex-direction: column; gap: 0; }
        .t-step  { display: flex; align-items: center; gap: 14px; }
        .t-icon  {
            width: 44px; height: 44px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
            transition: all 0.4s ease;
        }
        .t-icon.done   { background: #e8f8ee; }
        .t-icon.active { background: rgba(255,82,0,0.1); animation: trackerPulse 1.5s infinite; }
        .t-icon.idle   { background: var(--bg2); opacity: 0.5; }
        @keyframes trackerPulse {
            0%,100% { box-shadow: 0 0 0 0 rgba(255,82,0,0.4); }
            50%     { box-shadow: 0 0 0 10px rgba(255,82,0,0); }
        }
        .t-text  { flex: 1; }
        .t-label { font-size: 14px; font-weight: 600; color: var(--text); }
        .t-sub   { font-size: 12px; color: var(--muted); margin-top: 2px; }
        .t-time  { font-size: 12px; color: var(--orange); font-weight: 500; }
        .t-line  { width: 2px; height: 28px; margin-left: 21px; border-radius: 2px; }
        .t-line.done { background: #1a7a3a; }
        .t-line.idle { background: var(--border); }

        .action-row {
            display: flex; gap: 12px; justify-content: center;
            animation: titleIn 0.4s 0.8s ease both;
        }
        .btn-primary-sm {
            padding: 12px 28px;
            background: var(--orange); color: #fff; border: none;
            border-radius: 10px; font-family: 'Syne', sans-serif;
            font-size: 14px; font-weight: 700; cursor: pointer;
            text-decoration: none; display: inline-block;
            transition: background 0.2s, transform 0.2s cubic-bezier(.34,1.56,.64,1);
        }
        .btn-primary-sm:hover { background: var(--ember); transform: translateY(-2px); }
        .btn-outline-sm {
            padding: 12px 28px;
            background: transparent; color: var(--text2);
            border: 1.5px solid var(--border); border-radius: 10px;
            font-family: 'Syne', sans-serif; font-size: 14px; font-weight: 600;
            cursor: pointer; text-decoration: none; display: inline-block;
            transition: border-color 0.2s, transform 0.2s;
        }
        .btn-outline-sm:hover { border-color: var(--orange); color: var(--orange); transform: translateY(-2px); }

        /* ETA countdown */
        .eta-badge {
            display: inline-flex; align-items: center; gap: 8px;
            background: rgba(255,82,0,0.08); color: var(--orange);
            border: 1px solid rgba(255,82,0,0.2);
            border-radius: 50px; padding: 8px 18px;
            font-size: 14px; font-weight: 600;
            margin-bottom: 32px;
            animation: titleIn 0.4s 0.55s ease both;
        }
        .eta-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--orange); animation: trackerPulse 1.2s infinite; }
    </style>
</head>
<body>

<input type="checkbox" id="theme-toggle" hidden>

<div class="main">

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/RestaurantServlet" class="logo">OnlyFood's</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">🏠 Home</a>
            <a href="<%= request.getContextPath() %>/profile">👤 Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Sign Out</a>
            <label for="theme-toggle" class="toggle-btn">🌙</label>
        </div>
    </nav>

    <div class="confirm-wrap">

        <!-- Animated checkmark -->
        <div class="check-circle">
            <svg class="check-svg" viewBox="0 0 48 48">
                <path d="M10 24 L20 34 L38 14"/>
            </svg>
        </div>

        <h1 class="confirm-title">Order Confirmed! 🎉</h1>
        <p class="confirm-sub">
            Order #<strong><%= orderId %></strong> has been placed successfully.<br>
            Get ready — your food is on its way!
        </p>

        <!-- Live ETA badge -->
        <div class="eta-badge">
            <span class="eta-dot"></span>
            Estimated delivery: <span id="etaTimer">30:00</span>
        </div>

        <!-- Order details card -->
        <div class="order-card">
            <div class="order-card-title">Order Details</div>
            <div class="detail-row">
                <span class="detail-label">Order ID</span>
                <span class="detail-value">#<%= orderId %></span>
            </div>
            <% if (deliveryName != null) { %>
            <div class="detail-row">
                <span class="detail-label">Delivering to</span>
                <span class="detail-value"><%= deliveryName %></span>
            </div>
            <% } %>
            <% if (deliveryAddr != null) { %>
            <div class="detail-row">
                <span class="detail-label">Address</span>
                <span class="detail-value"><%= deliveryAddr %></span>
            </div>
            <% } %>
            <% if (paymentMode != null) { %>
            <div class="detail-row">
                <span class="detail-label">Payment</span>
                <span class="detail-value"><%= paymentMode %></span>
            </div>
            <% } %>
            <% if (orderTotal != null) { %>
            <div class="detail-row">
                <span class="detail-label">Total paid</span>
                <span class="detail-value highlight">₹<%= String.format("%.2f", orderTotal) %></span>
            </div>
            <% } %>
        </div>

        <!-- Live order tracker -->
        <div class="tracker-card">
            <div class="tracker-card-title">🛵 Live Tracking</div>
            <div class="tracker" id="tracker">

                <div class="t-step">
                    <div class="t-icon done" id="ts0">✅</div>
                    <div class="t-text">
                        <div class="t-label">Order confirmed</div>
                        <div class="t-sub">We've received your order</div>
                    </div>
                    <div class="t-time">Just now</div>
                </div>
                <div class="t-line done"></div>

                <div class="t-step">
                    <div class="t-icon active" id="ts1">🍳</div>
                    <div class="t-text">
                        <div class="t-label">Preparing your order</div>
                        <div class="t-sub" id="prepSub">Kitchen is cooking…</div>
                    </div>
                    <div class="t-time">~15 min</div>
                </div>
                <div class="t-line idle" id="tl1"></div>

                <div class="t-step">
                    <div class="t-icon idle" id="ts2">🛵</div>
                    <div class="t-text">
                        <div class="t-label">Out for delivery</div>
                        <div class="t-sub">Rider heading your way</div>
                    </div>
                    <div class="t-time" id="tt2">~10 min</div>
                </div>
                <div class="t-line idle" id="tl2"></div>

                <div class="t-step">
                    <div class="t-icon idle" id="ts3">🏠</div>
                    <div class="t-text">
                        <div class="t-label">Delivered</div>
                        <div class="t-sub">Enjoy your meal!</div>
                    </div>
                    <div class="t-time" id="tt3"></div>
                </div>

            </div>
        </div>

        <!-- Action buttons -->
        <div class="action-row">
            <a href="<%= request.getContextPath() %>/RestaurantServlet" class="btn-primary-sm">
                Order More 🍔
            </a>
            <a href="<%= request.getContextPath() %>/profile" class="btn-outline-sm">
                View Orders
            </a>
        </div>

    </div>
</div>

<script>
/* ── ETA Countdown ── */
(function () {
    var totalSeconds = 30 * 60;
    var el = document.getElementById('etaTimer');
    var interval = setInterval(function () {
        totalSeconds--;
        if (totalSeconds <= 0) { clearInterval(interval); el.textContent = 'Arriving now!'; return; }
        var m = Math.floor(totalSeconds / 60);
        var s = totalSeconds % 60;
        el.textContent = m + ':' + (s < 10 ? '0' : '') + s;
    }, 1000);
})();

/* ── Order tracker auto-advance ── */
(function () {
    // Step 1 → active already. Advance to "out for delivery" after 15s (demo).
    function markDone(iconId, lineId) {
        var icon = document.getElementById(iconId);
        var line = document.getElementById(lineId);
        if (icon) { icon.className = 't-icon done'; icon.textContent = '✅'; }
        if (line)   line.className = 't-line done';
    }
    function markActive(iconId, emoji) {
        var icon = document.getElementById(iconId);
        if (icon) { icon.className = 't-icon active'; icon.textContent = emoji; }
    }

    // After 15s → mark "preparing" done, activate "out for delivery"
    setTimeout(function () {
        markDone('ts1', 'tl1');
        markActive('ts2', '🛵');
        document.getElementById('tt2').textContent = 'On the way';
    }, 15000);

    // After 25s → mark "out for delivery" done, activate "delivered"
    setTimeout(function () {
        markDone('ts2', 'tl2');
        markActive('ts3', '🏠');
        document.getElementById('tt3').textContent = 'Arriving!';
    }, 25000);
})();

/* ── Theme toggle ── */
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
