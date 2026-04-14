<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.OnlyFoods.model.*" %>
<%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/Login.jsp");
    return;
}

List<Order>     orders    = (List<Order>)     request.getAttribute("orders");
List<Address>   addresses = (List<Address>)   request.getAttribute("addresses");
// FIX: ProfileServlet sets "favRestaurants" and "favMenus" — was "favRests"/"favMenus"
List<Favourite> favRests  = (List<Favourite>) request.getAttribute("favRestaurants");
List<Favourite> favMenus  = (List<Favourite>) request.getAttribute("favMenus");

int orderCount = orders    != null ? orders.size()    : 0;
int addrCount  = addresses != null ? addresses.size() : 0;
int favCount   = (favRests != null ? favRests.size()  : 0)
               + (favMenus != null ? favMenus.size()  : 0);

String msgType = (String) request.getAttribute("msgType");
String msgText = (String) request.getAttribute("msgText");

String initials = "";
if (user.getUsername() != null && !user.getUsername().isEmpty()) {
    String[] parts = user.getUsername().trim().split("\\s+");
    initials += parts[0].charAt(0);
    if (parts.length > 1) initials += parts[parts.length - 1].charAt(0);
}
initials = initials.toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">

    <style>
        .profile-wrap { max-width: 1100px; margin: 0 auto; padding: 32px 48px 64px; }

        @keyframes heroIn { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
        .profile-hero {
            background: var(--card); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 28px 32px;
            display: flex; align-items: center; gap: 24px;
            margin-bottom: 24px; box-shadow: var(--shadow);
            animation: heroIn 0.45s cubic-bezier(.22,1,.36,1) both;
            transition: border-color 0.35s;
        }
        .avatar-wrap { position: relative; flex-shrink: 0; }
        .avatar {
            width: 80px; height: 80px; border-radius: 50%;
            background: var(--orange); color: #fff;
            font-family: 'Syne', sans-serif; font-size: 28px; font-weight: 800;
            display: flex; align-items: center; justify-content: center;
            border: 3px solid rgba(255,82,0,0.25); overflow: hidden;
        }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }
        .avatar-edit {
            position: absolute; bottom: 0; right: 0;
            width: 24px; height: 24px; border-radius: 50%;
            background: var(--orange); color: #fff;
            border: 2px solid var(--card);
            display: flex; align-items: center; justify-content: center;
            font-size: 11px;
        }
        .hero-info { flex: 1; }
        .hero-info h1 { font-family:'Syne',sans-serif; font-size:22px; font-weight:800; color:var(--text); letter-spacing:-0.5px; margin-bottom:4px; }
        .hero-meta  { font-size:13px; color:var(--muted); margin-bottom:10px; }
        .hero-badges { display:flex; gap:8px; flex-wrap:wrap; }
        .badge {
            font-size:11px; font-weight:500; padding:3px 10px; border-radius:20px;
            background:rgba(255,82,0,0.08); color:var(--orange); border:1px solid rgba(255,82,0,0.2);
        }
        .badge.green { background:var(--green-bg); color:var(--green); border-color:var(--green-bd); }
        .hero-actions { display:flex; gap:8px; flex-shrink:0; }
        .btn-outline {
            padding:8px 18px; border:1px solid var(--border); border-radius:8px;
            background:transparent; color:var(--text2);
            font-family:'DM Sans',sans-serif; font-size:13px; font-weight:500;
            cursor:pointer; transition: background 0.2s, border-color 0.2s, transform 0.15s cubic-bezier(.34,1.56,.64,1);
        }
        .btn-outline:hover { background:var(--bg2); border-color:var(--border-h); transform:translateY(-1px); }

        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:24px; }
        @keyframes statPop { from{opacity:0;transform:scale(0.92);} to{opacity:1;transform:scale(1);} }
        .stat-card {
            background:var(--card); border:1px solid var(--border);
            border-radius:var(--radius); padding:18px 20px; text-align:center;
            box-shadow:var(--shadow); opacity:0;
            animation:statPop 0.4s cubic-bezier(.22,1,.36,1) forwards;
            transition: border-color 0.35s;
        }
        .stat-num   { font-family:'Syne',sans-serif; font-size:26px; font-weight:800; color:var(--text); }
        .stat-num sup { font-size:14px; font-weight:400; color:var(--muted); }
        .stat-label { font-size:12px; color:var(--muted); margin-top:2px; }

        .profile-grid { display:grid; grid-template-columns:1fr 340px; gap:20px; align-items:start; }

        .section-card {
            background:var(--card); border:1px solid var(--border);
            border-radius:var(--radius); padding:22px 24px; box-shadow:var(--shadow);
            margin-bottom:18px; transition:border-color 0.35s;
        }
        .section-card:last-child { margin-bottom:0; }
        .section-head { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
        .section-title { font-family:'Syne',sans-serif; font-size:15px; font-weight:700; color:var(--text); }
        .section-link { font-size:12px; color:var(--orange); text-decoration:none; cursor:pointer; background:none; border:none; font-family:'DM Sans',sans-serif; }
        .section-link:hover { text-decoration:underline; }

        .order-row { display:flex; align-items:center; gap:14px; padding:12px 0; border-bottom:1px solid var(--border); transition:border-color 0.35s; }
        .order-row:last-child { border-bottom:none; padding-bottom:0; }
        .order-icon { width:48px; height:48px; border-radius:10px; background:var(--bg2); display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .order-info { flex:1; }
        .order-name { font-size:13px; font-weight:500; color:var(--text); }
        .order-meta { font-size:12px; color:var(--muted); margin-top:2px; }
        .order-right { text-align:right; }
        .order-price { font-size:13px; font-weight:500; color:var(--text); }
        .status-pill { display:inline-block; font-size:10px; font-weight:500; padding:2px 8px; border-radius:20px; margin-top:4px; }
        .status-delivered,.status-delivered { background:var(--green-bg); color:var(--green); }
        .status-cancelled { background:var(--red-bg); color:var(--red); }
        .status-pending,.status-placed { background:rgba(240,165,0,0.1); color:#a07000; }
        .status-preparing { background:rgba(255,82,0,0.08); color:var(--orange); }

        .addr-row { display:flex; gap:12px; align-items:flex-start; padding:12px 0; border-bottom:1px solid var(--border); }
        .addr-row:last-child { border-bottom:none; padding-bottom:0; }
        .addr-icon { width:36px; height:36px; border-radius:8px; background:rgba(255,82,0,0.08); display:flex; align-items:center; justify-content:center; font-size:16px; flex-shrink:0; }
        .addr-body { flex:1; }
        .addr-label { font-size:12px; font-weight:500; color:var(--text); display:flex; align-items:center; gap:6px; }
        .default-tag { font-size:10px; background:var(--green-bg); color:var(--green); border:1px solid var(--green-bd); padding:1px 7px; border-radius:20px; }
        .addr-text { font-size:12px; color:var(--muted); margin-top:3px; line-height:1.5; }
        .addr-actions { display:flex; gap:8px; margin-top:6px; }
        .addr-btn { font-size:11px; color:var(--muted); background:none; border:none; cursor:pointer; padding:0; font-family:'DM Sans',sans-serif; transition:color 0.2s; }
        .addr-btn:hover { color:var(--orange); }
        .addr-btn.danger:hover { color:var(--red); }

        .fav-row { display:flex; align-items:center; gap:12px; padding:10px 0; border-bottom:1px solid var(--border); }
        .fav-row:last-child { border-bottom:none; padding-bottom:0; }
        .fav-icon { width:40px; height:40px; border-radius:10px; background:var(--bg2); display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .fav-info { flex:1; }
        .fav-name { font-size:13px; font-weight:500; color:var(--text); }
        .fav-sub  { font-size:11px; color:var(--muted); margin-top:2px; }
        .fav-remove { background:none; border:none; cursor:pointer; color:var(--red); font-size:16px; transition:transform 0.2s cubic-bezier(.34,1.56,.64,1); padding:4px; }
        .fav-remove:hover { transform:scale(1.25); }

        .wallet-card { background:var(--orange); border-radius:var(--radius); padding:20px 24px; margin-bottom:18px; color:#fff; }
        .wallet-label  { font-size:11px; opacity:0.8; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:4px; }
        .wallet-amount { font-family:'Syne',sans-serif; font-size:32px; font-weight:800; margin-bottom:4px; }
        .wallet-sub    { font-size:12px; opacity:0.75; }

        .account-row {
            display:flex; justify-content:space-between; align-items:center;
            padding:11px 0; border-bottom:1px solid var(--border);
            font-size:13px; color:var(--text); cursor:pointer; transition:color 0.2s;
        }
        .account-row:last-child { border-bottom:none; padding-bottom:0; }
        .account-row:hover { color:var(--orange); }
        .account-row.danger,.account-row.danger:hover { color:var(--red); }
        .account-chevron { color:var(--muted); font-size:14px; }

        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,0.55); z-index:500; align-items:center; justify-content:center; }
        .modal-overlay.open { display:flex; }
        @keyframes modalIn { from{opacity:0;transform:scale(0.95) translateY(12px);} to{opacity:1;transform:scale(1) translateY(0);} }
        .modal { background:var(--card); border-radius:20px; padding:32px 36px; width:100%; max-width:460px; box-shadow:var(--shadow-h); animation:modalIn 0.35s cubic-bezier(.22,1,.36,1) both; }
        .modal-title { font-family:'Syne',sans-serif; font-size:20px; font-weight:800; color:var(--text); margin-bottom:20px; }
        .modal-close { float:right; background:none; border:none; font-size:20px; color:var(--muted); cursor:pointer; line-height:1; margin-top:-4px; }

        .field { margin-bottom:16px; }
        .field label { display:block; font-size:12px; font-weight:500; color:var(--text2); margin-bottom:6px; }
        .field input,.field select,.field textarea {
            width:100%; padding:11px 14px; border:1.5px solid var(--border); border-radius:10px;
            background:var(--input-bg); color:var(--input-text);
            font-family:'DM Sans',sans-serif; font-size:14px; outline:none;
            transition:border-color 0.2s, box-shadow 0.2s;
        }
        .field input:focus,.field select:focus { border-color:var(--border-focus); box-shadow:0 0 0 3px rgba(255,82,0,0.12); }
        .field input[type="password"] { letter-spacing:2px; padding-right:44px; }
        .input-wrap { position:relative; }
        .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%); background:none; border:none; cursor:pointer; color:var(--muted); font-size:16px; padding:4px; }
        .pw-eye:hover { color:var(--text); }

        .alert { padding:10px 14px; border-radius:8px; font-size:13px; font-weight:500; margin-bottom:18px; display:flex; align-items:center; gap:8px; }
        .alert-success { background:var(--success-bg); color:var(--success-text); border:1px solid rgba(61,186,114,0.2); }
        .alert-error   { background:var(--error-bg); color:var(--error-text); border:1px solid var(--error-bd); }

        .empty-mini { text-align:center; padding:24px 0; font-size:13px; color:var(--muted); }
        .empty-mini-icon { font-size:32px; opacity:0.3; margin-bottom:8px; }

        .tabs { display:flex; gap:4px; margin-bottom:16px; }
        .tab-btn { flex:1; padding:7px 0; border:1px solid var(--border); border-radius:8px; background:transparent; color:var(--text2); font-family:'DM Sans',sans-serif; font-size:12px; font-weight:500; cursor:pointer; transition:all 0.2s; }
        .tab-btn.active { background:var(--orange); color:#fff; border-color:var(--orange); }

        @media(max-width:900px) { .profile-grid{grid-template-columns:1fr;} .stats-row{grid-template-columns:repeat(2,1fr);} .profile-wrap{padding:20px 20px 48px;} }
        @media(max-width:500px) { .stats-row{grid-template-columns:1fr 1fr; gap:10px;} .profile-hero{flex-direction:column; text-align:center;} .hero-badges{justify-content:center;} }
    </style>
</head>
<body>

<input type="checkbox" id="theme-toggle" hidden>

<div class="main">

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/RestaurantServlet" class="logo">OnlyFood's</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">Home</a>
            <a href="<%= request.getContextPath() %>/CartServlet">🛒 Cart</a>
            <a href="<%= request.getContextPath() %>/profile" style="background:rgba(255,255,255,0.15); color:#fff;">👤 Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Sign Out</a>
            <label for="theme-toggle" class="toggle-btn">🌙</label>
        </div>
    </nav>

    <div class="profile-wrap">

        <% if (msgText != null) { %>
        <div class="alert alert-<%= msgType %>">
            <%= "success".equals(msgType) ? "✓" : "⚠" %> <%= msgText %>
        </div>
        <% } %>

        <!-- HERO -->
        <div class="profile-hero">
            <div class="avatar-wrap">
                <div class="avatar"><%= initials %></div>
                <div class="avatar-edit">✎</div>
            </div>
            <div class="hero-info">
                <h1><%= user.getUsername() %></h1>
                <p class="hero-meta">
                    <%= user.getEmail() %>
                    <% if (user.getPhone() != null && !user.getPhone().isEmpty()) { %>
                     · <%= user.getPhone() %>
                    <% } %>
                    <% if (user.getCreatedDate() != null) { %>
                     · Member since <%= user.getCreatedDate().getYear() %>
                    <% } %>
                </p>
                <div class="hero-badges">
                    <span class="badge"><%= orderCount >= 20 ? "Gold Member" : orderCount >= 10 ? "Silver Member" : "Member" %></span>
                    <span class="badge green">Verified</span>
                    <% if ("ADMIN".equals(user.getRole())) { %>
                    <span class="badge" style="background:rgba(83,74,183,0.1);color:#534AB7;border-color:rgba(83,74,183,0.25);">Admin</span>
                    <% } %>
                </div>
            </div>
            <div class="hero-actions">
                <button class="btn-outline" onclick="openModal('phoneModal')">Edit phone</button>
                <button class="btn-outline" onclick="openModal('pwModal')">Change password</button>
            </div>
        </div>

        <!-- STATS -->
        <div class="stats-row">
            <div class="stat-card" style="animation-delay:0.05s">
                <div class="stat-num"><%= orderCount %></div>
                <div class="stat-label">Total orders</div>
            </div>
            <div class="stat-card" style="animation-delay:0.12s">
                <div class="stat-num"><sup>₹</sup><%= String.format("%,d",(int)(orderCount * 40)) %></div>
                <div class="stat-label">Delivery saved</div>
            </div>
            <div class="stat-card" style="animation-delay:0.19s">
                <div class="stat-num"><%= addrCount %></div>
                <div class="stat-label">Saved addresses</div>
            </div>
            <div class="stat-card" style="animation-delay:0.26s">
                <div class="stat-num"><%= favCount %></div>
                <div class="stat-label">Favourites</div>
            </div>
        </div>

        <!-- MAIN GRID -->
        <div class="profile-grid">

            <!-- LEFT COLUMN -->
            <div>

                <!-- Recent Orders -->
                <div class="section-card">
                    <div class="section-head">
                        <span class="section-title">Recent orders</span>
                        <button class="section-link" onclick="openModal('allOrdersModal')">View all</button>
                    </div>
                    <% if (orders == null || orders.isEmpty()) { %>
                    <div class="empty-mini"><div class="empty-mini-icon">🛒</div><div>No orders yet. Go explore!</div></div>
                    <% } else { int shown = 0; for (Order o : orders) { if (shown++ >= 4) break;
                        String statusClass = "status-" + o.getStatus().toLowerCase().replace(" ",""); %>
                    <div class="order-row">
                        <div class="order-icon">🍽️</div>
                        <div class="order-info">
                            <div class="order-name"><%= o.getRestaurantName() != null ? o.getRestaurantName() : "Restaurant" %></div>
                            <div class="order-meta">Order #<%= o.getOrderId() %> · ₹<%= String.format("%.0f", o.getTotalAmount()) %> · <%= o.getPaymentMode() %></div>
                        </div>
                        <div class="order-right">
                            <div class="order-price">
                                <%= o.getOrderDate() != null ? new java.text.SimpleDateFormat("d MMM").format(o.getOrderDate()) : "" %>
                            </div>
                            <span class="status-pill <%= statusClass %>"><%= o.getStatus() %></span>
                        </div>
                    </div>
                    <% } } %>
                </div>

                <!-- Saved Addresses -->
                <div class="section-card">
                    <div class="section-head">
                        <span class="section-title">Saved addresses</span>
                        <button class="section-link" onclick="openModal('addAddrModal')">+ Add new</button>
                    </div>
                    <% if (addresses == null || addresses.isEmpty()) { %>
                    <div class="empty-mini"><div class="empty-mini-icon">📍</div><div>No addresses saved yet.</div></div>
                    <% } else { for (Address addr : addresses) { %>
                    <div class="addr-row" id="addr-<%= addr.getAddressId() %>">
                        <div class="addr-icon"><%= "Work".equalsIgnoreCase(addr.getLabel()) ? "💼" : "Home".equalsIgnoreCase(addr.getLabel()) ? "🏠" : "📍" %></div>
                        <div class="addr-body">
                            <div class="addr-label">
                                <%= addr.getLabel() %>
                                <% if (addr.isDefault()) { %><span class="default-tag">Default</span><% } %>
                            </div>
                            <div class="addr-text"><%= addr.getFullAddress() %></div>
                            <div class="addr-actions">
                                <% if (!addr.isDefault()) { %>
                                <form action="<%= request.getContextPath() %>/profile/address" method="post" style="display:inline">
                                    <input type="hidden" name="action" value="setDefault">
                                    <input type="hidden" name="addressId" value="<%= addr.getAddressId() %>">
                                    <button type="submit" class="addr-btn">Set as default</button>
                                </form>
                                <span style="color:var(--border)">·</span>
                                <% } %>
                                <form action="<%= request.getContextPath() %>/profile/address" method="post" style="display:inline"
                                      onsubmit="return confirm('Remove this address?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="addressId" value="<%= addr.getAddressId() %>">
                                    <button type="submit" class="addr-btn danger">Remove</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } } %>
                </div>

            </div><!-- /left -->

            <!-- RIGHT COLUMN -->
            <div>

                <div class="wallet-card">
                    <div class="wallet-label">OnlyFood's Cash</div>
                    <div class="wallet-amount">₹0</div>
                    <div class="wallet-sub">No cashback yet · Earn on every order</div>
                </div>

                <!-- Favourites -->
                <div class="section-card">
                    <div class="section-head"><span class="section-title">Favourites</span></div>
                    <div class="tabs">
                        <button class="tab-btn active" onclick="switchTab(this,'tab-rest')">Restaurants</button>
                        <button class="tab-btn"        onclick="switchTab(this,'tab-menu')">Menu items</button>
                    </div>

                    <div id="tab-rest">
                        <% if (favRests == null || favRests.isEmpty()) { %>
                        <div class="empty-mini"><div class="empty-mini-icon">🏪</div><div>No favourite restaurants yet.</div></div>
                        <% } else { for (Favourite f : favRests) { %>
                        <div class="fav-row" id="fav-rest-<%= f.getTargetId() %>">
                            <div class="fav-icon">🍴</div>
                            <div class="fav-info">
                                <div class="fav-name"><%= f.getName() %></div>
                                <div class="fav-sub"><%= f.getSubText() != null ? f.getSubText() : "" %></div>
                            </div>
                            <%-- FIX: was posting toggle=remove — ProfileServlet checks action=remove --%>
                            <button class="fav-remove"
                                    onclick="removeFav('restaurant', <%= f.getTargetId() %>, 'fav-rest-<%= f.getTargetId() %>')">♥</button>
                        </div>
                        <% } } %>
                    </div>

                    <div id="tab-menu" style="display:none">
                        <% if (favMenus == null || favMenus.isEmpty()) { %>
                        <div class="empty-mini"><div class="empty-mini-icon">🍜</div><div>No favourite items yet.</div></div>
                        <% } else { for (Favourite f : favMenus) { %>
                        <div class="fav-row" id="fav-menu-<%= f.getTargetId() %>">
                            <div class="fav-icon">🍽️</div>
                            <div class="fav-info">
                                <div class="fav-name"><%= f.getName() %></div>
                                <div class="fav-sub">from <%= f.getSubText() != null ? f.getSubText() : "" %></div>
                            </div>
                            <button class="fav-remove"
                                    onclick="removeFav('menu', <%= f.getTargetId() %>, 'fav-menu-<%= f.getTargetId() %>')">♥</button>
                        </div>
                        <% } } %>
                    </div>
                </div>

                <!-- Account settings -->
                <div class="section-card" style="margin-bottom:0">
                    <div class="section-head" style="margin-bottom:4px">
                        <span class="section-title">Account</span>
                    </div>
                    <div class="account-row" onclick="openModal('phoneModal')">
                        <span>📞 &nbsp;Update phone number</span><span class="account-chevron">›</span>
                    </div>
                    <div class="account-row" onclick="openModal('pwModal')">
                        <span>🔒 &nbsp;Change password</span><span class="account-chevron">›</span>
                    </div>
                    <a href="<%= request.getContextPath() %>/LogoutServlet" style="text-decoration:none">
                        <div class="account-row danger">
                            <span>Sign out</span><span class="account-chevron">›</span>
                        </div>
                    </a>
                </div>

            </div><!-- /right -->

        </div>
    </div>

    <!-- ═══ MODALS ═══ -->

    <!-- Phone modal -->
    <div class="modal-overlay" id="phoneModal">
        <div class="modal">
            <div class="modal-title">Update phone <button class="modal-close" onclick="closeModal('phoneModal')">×</button></div>
            <form action="<%= request.getContextPath() %>/profile" method="post">
                <input type="hidden" name="action" value="updatePhone">
                <div class="field">
                    <label>Phone number</label>
                    <input type="tel" name="phone" placeholder="10-digit mobile number"
                           value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                           pattern="[0-9]{10}" required>
                </div>
                <button type="submit" class="btn-primary" style="margin-top:0">Save</button>
            </form>
        </div>
    </div>

    <!-- Password modal -->
    <div class="modal-overlay" id="pwModal">
        <div class="modal">
            <div class="modal-title">Change password <button class="modal-close" onclick="closeModal('pwModal')">×</button></div>
            <form action="<%= request.getContextPath() %>/profile" method="post">
                <input type="hidden" name="action" value="changePassword">
                <div class="field">
                    <label>Current password</label>
                    <div class="input-wrap">
                        <input type="password" name="currentPassword" id="cur-pw" required placeholder="Enter current password">
                        <button type="button" class="pw-eye" onclick="togglePw('cur-pw',this)">👁</button>
                    </div>
                </div>
                <div class="field">
                    <label>New password</label>
                    <div class="input-wrap">
                        <input type="password" name="newPassword" id="new-pw" required placeholder="Min 6 characters">
                        <button type="button" class="pw-eye" onclick="togglePw('new-pw',this)">👁</button>
                    </div>
                </div>
                <div class="field">
                    <label>Confirm new password</label>
                    <input type="password" name="confirmPassword" required placeholder="Repeat new password">
                </div>
                <button type="submit" class="btn-primary" style="margin-top:0">Update password</button>
            </form>
        </div>
    </div>

    <!-- Add address modal -->
    <div class="modal-overlay" id="addAddrModal">
        <div class="modal">
            <div class="modal-title">Add address <button class="modal-close" onclick="closeModal('addAddrModal')">×</button></div>
            <form action="<%= request.getContextPath() %>/profile/address" method="post">
                <input type="hidden" name="action" value="add">
                <div class="field">
                    <label>Label</label>
                    <select name="label">
                        <option value="Home">Home</option>
                        <option value="Work">Work</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="field">
                    <label>Full address</label>
                    <input type="text" name="fullAddress" required placeholder="House, Street, City, Pincode">
                </div>
                <button type="submit" class="btn-primary" style="margin-top:0">Save address</button>
            </form>
        </div>
    </div>

    <!-- All orders modal -->
    <div class="modal-overlay" id="allOrdersModal">
        <div class="modal" style="max-width:580px; max-height:80vh; overflow-y:auto;">
            <div class="modal-title">All orders <button class="modal-close" onclick="closeModal('allOrdersModal')">×</button></div>
            <% if (orders == null || orders.isEmpty()) { %>
            <div class="empty-mini">No orders yet.</div>
            <% } else { for (Order o : orders) { String sc = "status-" + o.getStatus().toLowerCase().replace(" ",""); %>
            <div class="order-row">
                <div class="order-icon">🍽️</div>
                <div class="order-info">
                    <div class="order-name"><%= o.getRestaurantName() != null ? o.getRestaurantName() : "Restaurant" %></div>
                    <div class="order-meta">Order #<%= o.getOrderId() %> · ₹<%= String.format("%.0f",o.getTotalAmount()) %> · <%= o.getPaymentMode() %>
                        <% if (o.getOrderDate() != null) { %> · <%= new java.text.SimpleDateFormat("d MMM yyyy").format(o.getOrderDate()) %><% } %>
                    </div>
                </div>
                <div class="order-right"><span class="status-pill <%= sc %>"><%= o.getStatus() %></span></div>
            </div>
            <% } } %>
        </div>
    </div>

</div>

<script>
(function () {
    var t = document.getElementById("theme-toggle");
    var l = document.querySelector("label[for='theme-toggle']");
    function apply(dark) { t.checked = dark; if (l) l.textContent = dark ? "☀️" : "🌙"; }
    apply(localStorage.getItem("theme") === "dark");
    t.addEventListener("change", function () { localStorage.setItem("theme", t.checked ? "dark" : "light"); apply(t.checked); });
})();

function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(function(o) {
    o.addEventListener('click', function(e) { if (e.target === o) o.classList.remove('open'); });
});

function togglePw(inputId, btn) {
    var inp = document.getElementById(inputId);
    if (inp.type === 'password') { inp.type = 'text';     btn.textContent = '🙈'; }
    else                         { inp.type = 'password'; btn.textContent = '👁'; }
}

function switchTab(btn, tabId) {
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    ['tab-rest','tab-menu'].forEach(function(id) {
        document.getElementById(id).style.display = (id === tabId) ? 'block' : 'none';
    });
}

/* FIX: was posting "toggle=remove" — ProfileServlet checks for "action=remove" */
function removeFav(type, id, rowId) {
    var row = document.getElementById(rowId);
    if (row) { row.style.opacity = '0.4'; row.style.pointerEvents = 'none'; }
    fetch('<%= request.getContextPath() %>/profile/favourite', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
        body: 'type=' + type + '&action=remove&id=' + id   // FIX: action=remove
    }).then(function(r) {
        if (r.ok && row) {
            row.style.transition = 'all 0.3s ease';
            row.style.maxHeight  = '0';
            row.style.overflow   = 'hidden';
            row.style.padding    = '0';
            setTimeout(function() { row.remove(); }, 320);
        }
    }).catch(function() {
        if (row) { row.style.opacity = '1'; row.style.pointerEvents = 'auto'; }
    });
}
</script>

</body>
</html>
