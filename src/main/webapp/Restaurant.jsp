<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.OnlyFoods.model.Restaurant, com.OnlyFoods.model.Category" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OnlyFood's — Restaurants</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">

    <style>
        /* ════════════════════════════════════
           CATEGORY SECTION
        ════════════════════════════════════ */
        .category-section {
            padding: 1.8rem 2rem 1rem;
            border-bottom: 1px solid var(--border);
            margin-bottom: 1.5rem;
        }
        .category-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.2rem;
        }
        .cat-title { font-size: 1.4rem; font-weight: 800; margin: 0; }
        .cat-nav   { display: flex; gap: 0.5rem; flex-shrink: 0; }

        .nav-btn {
            width: 34px; height: 34px;
            border-radius: 50%;
            border: 1.5px solid var(--border);
            background: var(--card);
            color: var(--text);
            font-size: 0.95rem;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.2s ease;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }
        .nav-btn:hover:not(:disabled) {
            background: var(--orange);
            border-color: var(--orange);
            color: #fff;
            box-shadow: 0 3px 10px rgba(255,82,0,0.35);
        }
        .nav-btn:disabled { opacity: 0.25; cursor: not-allowed; box-shadow: none; }

        .cat-scroll-wrap { overflow: hidden; width: 100%; position: relative; }
        .cat-track {
            display: flex;
            gap: 2rem;
            transition: transform 0.4s cubic-bezier(.4,0,.2,1);
            will-change: transform;
        }
        .cat-item {
            display: flex; flex-direction: column;
            align-items: center; gap: 0.55rem;
            cursor: pointer; flex-shrink: 0;
            width: 90px; user-select: none;
            transition: transform 0.2s ease;
        }
        .cat-item:hover { transform: translateY(-4px); }
        .cat-circle {
            width: 76px; height: 76px;
            border-radius: 50%;
            background: var(--bg2);
            border: 2.5px solid transparent;
            overflow: hidden;
            display: flex; align-items: center; justify-content: center;
            transition: border-color 0.22s, box-shadow 0.22s, transform 0.22s;
        }
        .cat-circle img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease; }
        .cat-item:hover .cat-circle img { transform: scale(1.08); }
        .cat-emoji { font-size: 2rem; }
        .cat-item.active .cat-circle {
            border-color: var(--orange);
            box-shadow: 0 0 0 3px rgba(255,82,0,0.2);
        }
        .cat-item.active span { color: var(--orange); font-weight: 700; }
        .cat-item span { font-size: 0.8rem; font-weight: 500; text-align: center; color: var(--text); white-space: nowrap; transition: color 0.2s; }

        /* Filter badge */
        .filter-badge {
            display: none;
            align-items: center;
            gap: 0.5rem;
            padding: 0 2rem 1rem;
            font-size: 0.9rem;
            color: var(--muted);
        }
        .filter-badge.visible { display: flex; }
        .filter-badge strong  { color: var(--orange); }
        .filter-badge button  {
            background: none; border: none; cursor: pointer;
            color: var(--muted); font-size: 1rem; line-height: 1; padding: 0 2px;
        }
        .filter-badge button:hover { color: var(--orange); }

        /* Card hidden state for filter */
        .card-link.hidden { display: none; }

        /* No-results */
        .no-results {
            display: none; text-align: center;
            padding: 3rem 1rem; color: var(--muted); width: 100%;
        }
        .no-results .no-icon { font-size: 3rem; margin-bottom: 0.5rem; }

        /* Shimmer skeleton */
        @keyframes shimmer {
            0%   { background-position: -600px 0; }
            100% { background-position:  600px 0; }
        }
        #shimmerGrid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 1.5rem;
            padding: 0 2rem 2rem;
        }
        #shimmerGrid.hidden { display: none; }
        .shimmer-card { border-radius: 14px; overflow: hidden; background: var(--card); box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        .shimmer-img  { width: 100%; height: 160px; background: linear-gradient(90deg, var(--shimmer-base) 25%, var(--shimmer-shine) 50%, var(--shimmer-base) 75%); background-size: 600px 100%; animation: shimmer 1.4s infinite linear; }
        .shimmer-body { padding: 1rem; }
        .shimmer-line { height: 12px; border-radius: 6px; margin-bottom: 10px; background: linear-gradient(90deg, var(--shimmer-base) 25%, var(--shimmer-shine) 50%, var(--shimmer-base) 75%); background-size: 600px 100%; animation: shimmer 1.4s infinite linear; }
        .shimmer-line.w80 { width: 80%; }
        .shimmer-line.w55 { width: 55%; }
        .shimmer-line.w35 { width: 35%; margin-bottom: 0; }

        /* Card fade-in animation */
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .card-link.animate-in { animation: cardIn 0.45s cubic-bezier(.22,1,.36,1) forwards; }

        /* Offer badge */
        .offer-badge {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 0.78rem; font-weight: 600;
            color: #1a9e3f; background: #e8f8ee;
            border-radius: 5px; padding: 3px 8px; margin-top: 6px;
        }
        .offer-icon { display: inline-block; font-size: 13px; transition: transform 0.05s linear; will-change: transform; }
    </style>
</head>
<body>

<%
    List<Restaurant> list       = (List<Restaurant>) request.getAttribute("restaurants");
    List<Category>   categories = (List<Category>)   request.getAttribute("categories");
    int count = (list != null) ? list.size() : 0;

    com.OnlyFoods.model.User user =
        (com.OnlyFoods.model.User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>

<input type="checkbox" id="theme-toggle">

<div class="main">

    <!-- NAVBAR -->
    <nav class="navbar">
        <a class="logo" href="<%= request.getContextPath() %>/RestaurantServlet">OnlyFood's</a>

        <div class="search-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"
                 stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"/>
                <line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input type="text" id="searchInput"
                   placeholder="Search restaurants or cuisines…"
                   class="search" oninput="applyFilters()">
        </div>

        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">Home</a>
            <a href="<%= request.getContextPath() %>/CartServlet">🛒 Cart</a>
            <a href="<%= request.getContextPath() %>/profile">👤 Profile</a>
            <!-- FIX: use context path + correct servlet URL -->
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
            <label for="theme-toggle" class="toggle-btn" title="Toggle dark / light">🌙</label>
        </div>
    </nav>

    <!-- HERO -->
    <div class="hero">
        <div class="hero-label">Welcome, <%= escapeHtml(user.getUsername()) %></div>
        <h1>Restaurants near you</h1>
        <% if (count > 0) { %>
            <p><%= count %> restaurant<%= count != 1 ? "s" : "" %> available</p>
        <% } %>
    </div>

    <!-- Active filter badge -->
    <div class="filter-badge" id="filterBadge">
        Showing restaurants for <strong id="filterLabel"></strong>
        <button onclick="clearFilter()" title="Clear filter">✕</button>
    </div>

    <!-- CATEGORY BAR -->
    <div class="category-section">
        <div class="category-header">
            <h2 class="cat-title">What's on your mind?</h2>
            <div class="cat-nav">
                <button class="nav-btn" id="catPrev" title="Previous">&#8592;</button>
                <button class="nav-btn" id="catNext" title="Next">&#8594;</button>
            </div>
        </div>

        <div class="cat-scroll-wrap">
            <div class="cat-track" id="catTrack">

                <div class="cat-item active" data-cuisine="" onclick="selectCategory(this)">
                    <div class="cat-circle"><span class="cat-emoji">🍽️</span></div>
                    <span>All</span>
                </div>

                <% if (categories != null) {
                       for (Category cat : categories) { %>
                <div class="cat-item"
                     data-cuisine="<%= escapeHtml(cat.getName()).toLowerCase() %>"
                     onclick="selectCategory(this)">
                    <div class="cat-circle">
                        <img src="<%= request.getContextPath() %>/<%= escapeHtml(cat.getImageUrl()) %>"
                             alt="<%= escapeHtml(cat.getName()) %>"
                             onerror="this.parentElement.innerHTML='<span class=\'cat-emoji\'>🍴</span>'">
                    </div>
                    <span><%= escapeHtml(cat.getName()) %></span>
                </div>
                <%  }
                   } %>

            </div>
        </div>
    </div>

    <!-- SHIMMER SKELETON -->
    <div id="shimmerGrid">
        <div class="shimmer-card"><div class="shimmer-img"></div><div class="shimmer-body"><div class="shimmer-line w80"></div><div class="shimmer-line w55"></div><div class="shimmer-line w35"></div></div></div>
        <div class="shimmer-card"><div class="shimmer-img"></div><div class="shimmer-body"><div class="shimmer-line w80"></div><div class="shimmer-line w55"></div><div class="shimmer-line w35"></div></div></div>
        <div class="shimmer-card"><div class="shimmer-img"></div><div class="shimmer-body"><div class="shimmer-line w80"></div><div class="shimmer-line w55"></div><div class="shimmer-line w35"></div></div></div>
        <div class="shimmer-card"><div class="shimmer-img"></div><div class="shimmer-body"><div class="shimmer-line w80"></div><div class="shimmer-line w55"></div><div class="shimmer-line w35"></div></div></div>
    </div>

    <!-- RESTAURANT GRID -->
    <div class="container">
        <div class="grid-restaurant" id="restaurantGrid" style="opacity:0;">

            <% if (list != null && !list.isEmpty()) {
                   int idx = 0;
                   for (Restaurant r : list) { %>
            <a class="card-link"
               href="<%= request.getContextPath() %>/MenuServlet?restaurantId=<%= r.getRestaurantId() %>"
               data-name="<%= escapeHtml(r.getName()).toLowerCase() %>"
               data-cuisine="<%= escapeHtml(r.getCuisineType()).toLowerCase() %>"
               style="animation-delay: <%= idx * 80 %>ms;">
                <div class="card">
                    <div class="card-img-wrap">
                        <img src="<%= request.getContextPath() + "/" + escapeHtml(r.getImagePath()) %>"
                             alt="<%= escapeHtml(r.getName()) %>"
                             onerror="this.style.visibility='hidden'">
                    </div>
                    <div class="card-content">
                        <h3><%= escapeHtml(r.getName()) %></h3>
                        <p class="cuisine"><%= escapeHtml(r.getCuisineType()) %></p>
                        <p class="location">📍 <%= escapeHtml(r.getAddress()) %></p>
                        <div class="info">
                            <span class="rating">★ <%= r.getRating() %></span>
                            <span class="eta"><%= r.getDeliveryTime() %> mins</span>
                        </div>
                        <div class="offer-badge">
                            <span class="offer-icon" data-offer-icon>🏷️</span>
                            Up to 40% off
                        </div>
                    </div>
                </div>
            </a>
            <% idx++; } } else { %>
            <div class="empty-state">
                <div class="empty-icon">🍽️</div>
                <h2>No restaurants available</h2>
                <p>We're onboarding new partners. Check back soon.</p>
            </div>
            <% } %>

            <div class="no-results" id="noResults">
                <div class="no-icon">🔍</div>
                <h3>No restaurants found</h3>
                <p>Try a different category or search term</p>
            </div>

        </div>
    </div>

</div>

<script>
/* Hide shimmer, reveal real cards */
window.addEventListener('DOMContentLoaded', function () {
    var shimmer = document.getElementById('shimmerGrid');
    var grid    = document.getElementById('restaurantGrid');

    setTimeout(function () {
        shimmer.classList.add('hidden');
        grid.style.opacity = '1';

        document.querySelectorAll('.card-link').forEach(function (card, i) {
            card.style.opacity = '0';
            card.style.animation = 'none';
            setTimeout(function () {
                card.style.animation = '';
                card.classList.add('animate-in');
            }, i * 80);
        });
    }, 600);
});

/* Offer icon rotates on scroll */
(function () {
    var offerIcons = document.querySelectorAll('[data-offer-icon]');
    var lastScroll = 0;
    window.addEventListener('scroll', function () {
        var scrollY = window.scrollY || window.pageYOffset;
        var delta   = scrollY - lastScroll;
        lastScroll  = scrollY;
        offerIcons.forEach(function (icon, i) {
            var current = parseFloat(icon.dataset.rotation || 0);
            current += delta * (0.4 + i * 0.05);
            icon.dataset.rotation = current;
            icon.style.transform  = 'rotate(' + current + 'deg)';
        });
    }, { passive: true });
})();

var activeCuisine = '';

function selectCategory(el) {
    document.querySelectorAll('.cat-item').forEach(function(i) { i.classList.remove('active'); });
    el.classList.add('active');
    activeCuisine = (el.getAttribute('data-cuisine') || '').trim().toLowerCase();
    var badge = document.getElementById('filterBadge');
    var label = document.getElementById('filterLabel');
    if (activeCuisine) {
        label.textContent = el.querySelector('span').textContent;
        badge.classList.add('visible');
    } else {
        badge.classList.remove('visible');
    }
    applyFilters();
}

function clearFilter() {
    var allPill = document.querySelector('.cat-item[data-cuisine=""]');
    if (allPill) selectCategory(allPill);
}

function applyFilters() {
    var searchQ = (document.getElementById('searchInput').value || '').toLowerCase().trim();
    var cards   = document.querySelectorAll('#restaurantGrid .card-link');
    var visible = 0;
    cards.forEach(function(card) {
        var name    = card.getAttribute('data-name')    || '';
        var cuisine = card.getAttribute('data-cuisine') || '';
        var matchCat    = !activeCuisine || cuisine.includes(activeCuisine);
        var matchSearch = !searchQ || name.includes(searchQ) || cuisine.includes(searchQ);
        if (matchCat && matchSearch) { card.classList.remove('hidden'); visible++; }
        else                         { card.classList.add('hidden'); }
    });
    document.getElementById('noResults').style.display = visible === 0 ? 'block' : 'none';
}

/* Category carousel */
(function () {
    var track   = document.getElementById('catTrack');
    var prevBtn = document.getElementById('catPrev');
    var nextBtn = document.getElementById('catNext');
    if (!track) return;
    var GAP = 32, ITEM_W = 90, STEP = ITEM_W + GAP, offset = 0;
    function maxOffset() { return Math.max(0, track.scrollWidth - track.parentElement.offsetWidth); }
    function update() {
        track.style.transform = 'translateX(-' + offset + 'px)';
        prevBtn.disabled = offset <= 0;
        nextBtn.disabled = offset >= maxOffset();
    }
    prevBtn.addEventListener('click', function () { offset = Math.max(0, offset - STEP * 3); update(); });
    nextBtn.addEventListener('click', function () { offset = Math.min(maxOffset(), offset + STEP * 3); update(); });
    window.addEventListener('resize', update);
    update();
})();

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

<%!
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                    .replace("\"","&quot;").replace("'","&#x27;");
    }
%>
