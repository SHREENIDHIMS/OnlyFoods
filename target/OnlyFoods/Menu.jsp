<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.OnlyFoods.model.Menu" %>

<%!
/* escapeHtml declared at top so it's available everywhere in the page */
private String escapeHtml(String input) {
    if (input == null) return "";
    return input.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#x27;");
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">

    <style>
        /* ══ ADD-TO-CART WIDGET ══ */
        .atc-wrap { margin-top: 1rem; display: flex; justify-content: flex-end; }

        .atc-pill {
            position: relative; height: 40px; width: 88px;
            border-radius: 50px;
            transition: width 0.35s cubic-bezier(.34,1.56,.64,1);
            overflow: hidden;
        }
        .atc-pill.expanded { width: 118px; }

        .atc-add-btn {
            position: absolute; inset: 0;
            display: flex; align-items: center; justify-content: center; gap: 4px;
            background: linear-gradient(135deg, var(--orange), #ee4800);
            color: #fff; border: none; border-radius: 50px;
            font-size: 0.88rem; font-weight: 700; cursor: pointer;
            opacity: 1; transform: scale(1);
            transition: opacity .22s ease, transform .22s ease;
            z-index: 2; white-space: nowrap;
        }
        .atc-add-btn.hide { opacity: 0; transform: scale(0.6); pointer-events: none; }
        .atc-add-btn:disabled { background: linear-gradient(135deg, #ccc, #aaa); cursor: not-allowed; }
        .atc-add-btn:hover:not(.hide):not(:disabled) {
            filter: brightness(1.08);
            box-shadow: 0 4px 14px rgba(255,82,0,.4);
        }

        .atc-stepper {
            position: absolute; inset: 0;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 5px;
            background: linear-gradient(135deg, var(--orange), #ee4800);
            border-radius: 50px;
            opacity: 0; transform: scale(0.75);
            transition: opacity .25s ease .08s, transform .25s cubic-bezier(.34,1.56,.64,1) .08s;
            z-index: 1;
        }
        .atc-stepper.show { opacity: 1; transform: scale(1); }

        .step-btn {
            width: 28px; height: 28px;
            border: none; background: rgba(255,255,255,.28); color: #fff;
            border-radius: 50%; font-size: 1.15rem; font-weight: 700;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; line-height: 1;
            transition: background .15s, transform .12s cubic-bezier(.34,1.56,.64,1);
        }
        .step-btn:hover  { background: rgba(255,255,255,.45); }
        .step-btn:active { transform: scale(.75); }

        .step-count {
            color: #fff; font-weight: 700; font-size: .95rem;
            min-width: 20px; text-align: center;
            transition: transform .15s cubic-bezier(.34,1.56,.64,1);
        }
        .step-count.pop { transform: scale(1.5); }

        @keyframes rippleOut {
            0%   { transform: scale(1); opacity: .55; }
            100% { transform: scale(3); opacity: 0; }
        }
        .cart-ripple {
            position: absolute; inset: 0; border-radius: 50px;
            background: rgba(255,255,255,.35);
            animation: rippleOut .45s ease-out forwards;
            pointer-events: none; z-index: 3;
        }

        .atc-spinner {
            width: 14px; height: 14px;
            border: 2px solid rgba(255,255,255,.4);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin .6s linear infinite;
            display: none;
            position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
            z-index: 4;
        }
        .atc-pill.loading .atc-spinner { display: block; }
        @keyframes spin { to { transform: translateY(-50%) rotate(360deg); } }

        /* Card entrance animation */
        @keyframes menuCardIn {
            from { opacity: 0; transform: translateY(20px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        .menu-card { opacity: 0; animation: menuCardIn 0.45s cubic-bezier(.22,1,.36,1) forwards; }

        /* Toast */
        @keyframes toastIn  { from { opacity: 0; transform: translateX(-50%) translateY(20px) scale(0.95); } to { opacity: 1; transform: translateX(-50%) translateY(0) scale(1); } }
        @keyframes toastOut { from { opacity: 1; transform: translateX(-50%) translateY(0) scale(1); } to { opacity: 0; transform: translateX(-50%) translateY(20px) scale(0.95); } }
        #toast {
            position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%);
            background: #1a1a1a; color: #fff;
            padding: 10px 20px; border-radius: 50px;
            font-size: 0.88rem; font-weight: 500;
            z-index: 9999; pointer-events: none; display: none;
            white-space: nowrap; box-shadow: 0 4px 20px rgba(0,0,0,0.25);
        }
        #toast.show { display: block; animation: toastIn 0.3s cubic-bezier(.34,1.56,.64,1) forwards; }
        #toast.hide { animation: toastOut 0.25s ease forwards; }

        /* Cart icon bounce */
        @keyframes cartBounce {
            0%   { transform: scale(1); }
            30%  { transform: scale(1.4) rotate(-10deg); }
            60%  { transform: scale(0.9) rotate(5deg); }
            100% { transform: scale(1) rotate(0deg); }
        }
        .cart-bounce { display: inline-block; animation: cartBounce 0.5s cubic-bezier(.34,1.56,.64,1); }
    </style>
</head>
<body>

<%
List<Menu> list          = (List<Menu>) request.getAttribute("menuList");
// FIX: MenuServlet now sets "restaurantName" attribute
String restaurantName    = (String) request.getAttribute("restaurantName");
int    itemCount         = (list != null) ? list.size() : 0;
String pageTitle         = (restaurantName != null && !restaurantName.trim().isEmpty())
                           ? restaurantName : "Our Menu";
com.OnlyFoods.model.User user =
    (com.OnlyFoods.model.User) session.getAttribute("user");
%>

<div id="toast">🛒 Added to cart!</div>

<input type="checkbox" id="theme-toggle">

<div class="main">

    <!-- NAVBAR -->
    <nav class="navbar">
        <a class="logo" href="<%= request.getContextPath() %>/RestaurantServlet">OnlyFood's</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">← Restaurants</a>
            <a href="<%= request.getContextPath() %>/CartServlet" id="cartNavLink">🛒 Cart</a>
            <a href="<%= request.getContextPath() %>/profile">👤 Profile</a>
            <!-- FIX: context path + correct servlet mapping -->
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
            <label for="theme-toggle" class="toggle-btn" title="Toggle dark / light">🌙</label>
        </div>
    </nav>

    <!-- HEADER -->
    <header class="page-header">
        <div class="page-label">Menu</div>
        <h1 class="page-title"><%= escapeHtml(pageTitle) %></h1>
        <% if (itemCount > 0) { %>
            <p class="page-meta"><%= itemCount %> item<%= itemCount != 1 ? "s" : "" %></p>
        <% } %>
    </header>

    <!-- GRID -->
    <main class="container">

        <% if (list != null && !list.isEmpty()) { %>
        <div class="grid-menu">

            <% int menuIdx = 0; for (Menu m : list) { %>
            <div class="menu-card" style="animation-delay: <%= menuIdx * 70 %>ms;">

                <div class="menu-card-img">
                    <img
                        src="<%= (m.getImagePath() != null && !m.getImagePath().trim().isEmpty())
                            ? request.getContextPath() + "/" + m.getImagePath()
                            : request.getContextPath() + "/images/default-food.jpg" %>"
                        alt="<%= escapeHtml(m.getItemName()) %>"
                        onerror="this.src='<%= request.getContextPath() %>/images/default-food.jpg'">
                </div>

                <div class="menu-card-body">
                    <h3><%= escapeHtml(m.getItemName()) %></h3>

                    <% if (m.getDescription() != null && !m.getDescription().trim().isEmpty()) { %>
                        <p class="menu-desc"><%= escapeHtml(m.getDescription()) %></p>
                    <% } %>

                    <div class="menu-info">
                        <span class="price">&#8377; <%= String.format("%.2f", m.getPrice()) %></span>
                        <span class="badge-avail <%= m.isAvailable() ? "available" : "not-available" %>">
                            <%= m.isAvailable() ? "Available" : "Out of Stock" %>
                        </span>
                    </div>

                    <!-- ADD-TO-CART WIDGET -->
                    <div class="atc-wrap">
                        <div class="atc-pill" id="pill-<%= m.getMenuId() %>">
                            <div class="atc-spinner"></div>
                            <button
                                class="atc-add-btn"
                                id="addbtn-<%= m.getMenuId() %>"
                                type="button"
                                <%= !m.isAvailable() ? "disabled" : "" %>
                                onclick="atcAdd(<%= m.getMenuId() %>, '<%= escapeHtml(m.getItemName()) %>')"
                            >
                                <span>＋</span> Add
                            </button>
                            <div class="atc-stepper" id="stepper-<%= m.getMenuId() %>">
                                <button class="step-btn" type="button" onclick="atcStep(<%= m.getMenuId() %>, -1)">−</button>
                                <span class="step-count" id="count-<%= m.getMenuId() %>">1</span>
                                <button class="step-btn" type="button" onclick="atcStep(<%= m.getMenuId() %>, +1)">+</button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
            <% menuIdx++; } %>

        </div>
        <% } else { %>
        <div class="empty-state">
            <div class="empty-icon">🍽️</div>
            <h3>No items yet</h3>
            <p>This restaurant hasn't added any menu items yet.</p>
        </div>
        <% } %>

    </main>
</div>

<script>
var qty  = {};
var BASE = '<%= request.getContextPath() %>/CartServlet';

function pill(id)    { return document.getElementById('pill-'    + id); }
function addBtn(id)  { return document.getElementById('addbtn-'  + id); }
function stepper(id) { return document.getElementById('stepper-' + id); }
function countEl(id) { return document.getElementById('count-'   + id); }

function setLoading(id, on) { pill(id).classList.toggle('loading', on); }

function popCount(id) {
    var el = countEl(id);
    el.textContent = qty[id];
    el.classList.remove('pop');
    void el.offsetWidth;
    el.classList.add('pop');
    setTimeout(function(){ el.classList.remove('pop'); }, 200);
}

function showStepper(id) {
    var r = document.createElement('div');
    r.className = 'cart-ripple';
    pill(id).appendChild(r);
    setTimeout(function(){ r.remove(); }, 500);
    pill(id).classList.add('expanded');
    addBtn(id).classList.add('hide');
    stepper(id).classList.add('show');
}

function hideStepper(id) {
    stepper(id).classList.remove('show');
    setTimeout(function(){
        pill(id).classList.remove('expanded');
        addBtn(id).classList.remove('hide');
    }, 230);
}

var toastTimer;
function showToast(name) {
    var t = document.getElementById('toast');
    t.textContent = '🛒 ' + name + ' added!';
    clearTimeout(toastTimer);
    t.className = 'show';
    toastTimer = setTimeout(function () {
        t.className = 'hide';
        setTimeout(function(){ t.className = ''; }, 300);
    }, 2000);
}

function bounceCartIcon() {
    var cartLink = document.getElementById('cartNavLink');
    if (!cartLink) return;
    cartLink.classList.remove('cart-bounce');
    void cartLink.offsetWidth;
    cartLink.classList.add('cart-bounce');
    setTimeout(function(){ cartLink.classList.remove('cart-bounce'); }, 600);
}

function cartFetch(params, callback) {
    var body = Object.keys(params).map(function(k){
        return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]);
    }).join('&');
    fetch(BASE, {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
        body: body
    })
    .then(function(res) { if (callback) callback(res.ok); })
    .catch(function(err) { console.error('Cart AJAX error:', err); if (callback) callback(false); });
}

function atcAdd(id, name) {
    qty[id] = 1;
    countEl(id).textContent = '1';
    showStepper(id);
    bounceCartIcon();
    showToast(name || 'Item');
    setLoading(id, true);
    cartFetch({ action: 'add', menuId: id, quantity: 1 }, function() { setLoading(id, false); });
}

function atcStep(id, delta) {
    if (qty[id] === undefined) qty[id] = 1;
    var next = qty[id] + delta;
    if (next > 10) return;
    if (next <= 0) {
        setLoading(id, true);
        cartFetch({ action: 'remove', menuId: id, quantity: 0 }, function() {
            setLoading(id, false);
            qty[id] = 0;
            hideStepper(id);
        });
        return;
    }
    qty[id] = next;
    popCount(id);
    setLoading(id, true);
    cartFetch({ action: 'update', menuId: id, quantity: qty[id] }, function() { setLoading(id, false); });
}

/* Theme toggle */
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
