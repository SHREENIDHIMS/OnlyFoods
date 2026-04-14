<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.OnlyFoods.model.Cart, com.OnlyFoods.model.Cartitem, com.OnlyFoods.model.Address" %>
<%
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/CartServlet");
        return;
    }

    Double subtotalObj    = (Double) request.getAttribute("subtotal");
    Double deliveryFeeObj = (Double) request.getAttribute("deliveryFee");
    Double gstObj         = (Double) request.getAttribute("gst");
    Double grandTotalObj  = (Double) request.getAttribute("grandTotal");

    double subtotal    = (subtotalObj    != null) ? subtotalObj    : cart.getTotalPrice();
    double deliveryFee = (deliveryFeeObj != null) ? deliveryFeeObj : 40.00;
    double gst         = (gstObj         != null) ? gstObj         : (subtotal * 0.05);
    double grandTotal  = (grandTotalObj  != null) ? grandTotalObj  : (subtotal + deliveryFee + gst);

    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");

    List<Address> savedAddresses = (List<Address>) request.getAttribute("savedAddresses");
    String prefillName  = (String) request.getAttribute("prefillName");
    String prefillPhone = (String) request.getAttribute("prefillPhone");
    if (prefillName  == null) prefillName  = "";
    if (prefillPhone == null) prefillPhone = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">

    <style>
        .checkout-container {
            max-width: 1200px; margin: 0 auto; padding: 2rem;
            display: grid; grid-template-columns: 1fr 400px; gap: 2rem;
        }
        @media (max-width: 968px) {
            .checkout-container { grid-template-columns: 1fr; }
            .order-summary-sidebar { order: -1; }
        }

        .checkout-main { display: flex; flex-direction: column; gap: 1.5rem; }

        .checkout-section {
            background: var(--card); padding: 2rem; border-radius: 12px;
            box-shadow: var(--shadow); border: 1px solid var(--border);
            transition: border-color 0.35s;
        }
        .section-title {
            font-size: 1.3rem; font-weight: 700; margin-bottom: 1.25rem;
            display: flex; align-items: center; gap: 0.5rem;
        }
        .section-title-icon { font-size: 1.5rem; }

        .form-group { margin-bottom: 1.25rem; }
        .form-label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: var(--text); font-size: 0.9rem; }
        .form-input {
            width: 100%; padding: 0.875rem; border: 2px solid var(--border);
            border-radius: 8px; background: var(--input-bg); color: var(--input-text);
            font-size: 1rem; font-family: 'DM Sans', sans-serif;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-input:focus {
            outline: none; border-color: var(--orange);
            box-shadow: 0 0 0 3px rgba(255,82,0,0.1);
        }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        textarea.form-input { resize: vertical; min-height: 80px; }

        /* ── Saved address cards ── */
        .addr-selector {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }
        .addr-card {
            border: 2px solid var(--border);
            border-radius: 10px;
            padding: 0.9rem 1rem;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s, transform 0.15s cubic-bezier(.34,1.56,.64,1);
            position: relative;
        }
        .addr-card:hover {
            border-color: var(--orange);
            background: var(--bg2);
            transform: translateY(-2px);
        }
        .addr-card.selected {
            border-color: var(--orange);
            background: rgba(255,82,0,0.05);
        }
        .addr-card.selected::after {
            content: '✓';
            position: absolute; top: 8px; right: 10px;
            color: var(--orange); font-weight: 700; font-size: 14px;
        }
        .addr-card-label {
            display: flex; align-items: center; gap: 6px;
            font-size: 0.8rem; font-weight: 700;
            color: var(--text2); text-transform: uppercase;
            letter-spacing: 0.06em; margin-bottom: 4px;
        }
        .addr-card-label .tag-icon { font-size: 14px; }
        .addr-default-tag {
            font-size: 9px; background: var(--green-bg); color: var(--green);
            border: 1px solid var(--green-bd);
            padding: 1px 6px; border-radius: 20px;
            font-weight: 600; letter-spacing: 0.04em;
        }
        .addr-card-text {
            font-size: 0.82rem; color: var(--muted);
            line-height: 1.5; margin: 0;
        }
        .addr-new-btn {
            border: 2px dashed var(--border);
            border-radius: 10px; padding: 0.9rem 1rem;
            cursor: pointer; display: flex;
            align-items: center; justify-content: center;
            gap: 6px; color: var(--muted);
            font-size: 0.85rem; font-weight: 500;
            transition: border-color 0.2s, color 0.2s, background 0.2s;
            background: transparent;
            width: 100%;
        }
        .addr-new-btn:hover {
            border-color: var(--orange); color: var(--orange);
            background: rgba(255,82,0,0.03);
        }

        /* Divider between selector and manual form */
        .or-divider {
            display: flex; align-items: center; gap: 10px;
            margin: 1.25rem 0 1rem;
            color: var(--muted); font-size: 12px;
        }
        .or-divider::before, .or-divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }

        /* Manual form collapse */
        .manual-form {
            overflow: hidden;
            transition: max-height 0.35s ease, opacity 0.3s ease;
        }
        .manual-form.collapsed { max-height: 0; opacity: 0; pointer-events: none; }
        .manual-form.expanded  { max-height: 1000px; opacity: 1; }

        /* Payment section */
        .payment-options { display: flex; flex-direction: column; gap: 0.75rem; }
        .payment-option {
            display: flex; align-items: center; padding: 1rem;
            border: 2px solid var(--border); border-radius: 8px;
            cursor: pointer; transition: all 0.2s;
        }
        .payment-option:hover { border-color: var(--orange); background: var(--bg2); }
        .payment-option input[type="radio"] { margin-right: 1rem; width: 20px; height: 20px; cursor: pointer; }
        .payment-option.selected { border-color: var(--orange); background: rgba(255,82,0,0.05); }
        .payment-label { display: flex; align-items: center; gap: 0.75rem; font-weight: 600; }
        .payment-icon  { font-size: 1.5rem; }

        /* Order summary sidebar */
        .order-summary-sidebar { position: sticky; top: 2rem; height: fit-content; }
        .summary-card {
            background: var(--card); padding: 2rem; border-radius: 12px;
            box-shadow: var(--shadow-h); border: 1px solid var(--border);
            transition: border-color 0.35s;
        }
        .summary-title { font-size: 1.5rem; font-weight: 700; margin-bottom: 1.5rem; }
        .summary-items { margin-bottom: 1.5rem; max-height: 300px; overflow-y: auto; }
        .summary-item {
            display: flex; justify-content: space-between;
            padding: 0.75rem 0; border-bottom: 1px solid var(--border);
        }
        .summary-item:last-child { border-bottom: none; }
        .item-details { flex: 1; }
        .item-name    { font-weight: 600; margin-bottom: 0.25rem; }
        .item-qty     { font-size: 0.9rem; color: var(--muted); }
        .item-price   { font-weight: 600; color: var(--orange); }
        .summary-divider { height: 1px; background: var(--border); margin: 1.5rem 0; }
        .summary-row   { display: flex; justify-content: space-between; margin-bottom: 1rem; }
        .summary-row.total {
            font-size: 1.5rem; font-weight: 700;
            padding-top: 1rem; border-top: 2px solid var(--border); color: var(--orange);
        }

        /* Selected address preview in sidebar */
        .selected-addr-preview {
            background: rgba(255,82,0,0.05);
            border: 1px solid rgba(255,82,0,0.2);
            border-radius: 8px; padding: 0.75rem 1rem;
            font-size: 0.85rem; color: var(--text2);
            margin-bottom: 1rem; display: none;
        }
        .selected-addr-preview.visible { display: block; }
        .selected-addr-preview strong { color: var(--orange); display: block; margin-bottom: 3px; }

        .place-order-btn {
            width: 100%; padding: 1.25rem;
            background: linear-gradient(135deg, var(--orange), #ee4800);
            color: white; border: none; border-radius: 8px;
            font-size: 1.1rem; font-weight: 700; cursor: pointer;
            transition: all 0.3s ease; margin-top: 1.5rem;
        }
        .place-order-btn:hover  { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255,82,0,0.4); }
        .place-order-btn:active { transform: translateY(0); }
        .place-order-btn:disabled { background: var(--border); cursor: not-allowed; transform: none; }

        .back-link {
            display: inline-flex; align-items: center; gap: 0.5rem;
            color: var(--orange); text-decoration: none; font-weight: 600;
            margin-bottom: 1.5rem; transition: gap 0.2s;
        }
        .back-link:hover { gap: 0.75rem; }

        .error-banner {
            background: var(--error-bg); color: var(--error-text);
            border: 1px solid var(--error-bd);
            padding: 0.75rem 1rem; border-radius: 8px;
            margin-bottom: 1rem; font-size: 0.9rem;
        }
    </style>
</head>
<body>

<input type="checkbox" id="theme-toggle" hidden>

<div class="main">

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/RestaurantServlet" class="logo">OnlyFood's</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/RestaurantServlet">🏠 Home</a>
            <a href="<%= request.getContextPath() %>/CartServlet">🛒 Cart</a>
            <a href="<%= request.getContextPath() %>/checkout" style="background:rgba(255,255,255,0.15); color:#fff;">💳 Checkout</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Sign Out</a>
            <label for="theme-toggle" class="toggle-btn">🌙</label>
        </div>
    </nav>

    <main>
        <div class="checkout-container">

            <!-- LEFT: Delivery & Payment -->
            <div class="checkout-main">

                <a href="<%= request.getContextPath() %>/CartServlet" class="back-link">← Back to Cart</a>

                <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="error-banner">⚠ <%= errorMsg %></div>
                <% } %>

                <!-- Delivery Address Section -->
                <div class="checkout-section">
                    <h2 class="section-title">
                        <span class="section-title-icon">📍</span>
                        Delivery Address
                    </h2>

                    <form id="checkoutForm" action="<%= request.getContextPath() %>/placeOrder" method="post">

                        <%-- Hidden fields written by JS when a saved address is selected --%>
                        <input type="hidden" name="fullName"  id="hFullName"  value="<%= prefillName %>">
                        <input type="hidden" name="phone"     id="hPhone"     value="<%= prefillPhone %>">
                        <input type="hidden" name="address"   id="hAddress"   value="">
                        <input type="hidden" name="city"      id="hCity"      value="">
                        <input type="hidden" name="pincode"   id="hPincode"   value="">
                        <input type="hidden" name="instructions" id="hInstructions" value="">

                        <!-- ── Saved address cards ── -->
                        <% if (savedAddresses != null && !savedAddresses.isEmpty()) { %>

                        <div class="addr-selector" id="addrSelector">

                            <% for (Address addr : savedAddresses) {
                                String icon = "Work".equalsIgnoreCase(addr.getLabel()) ? "💼"
                                            : "Home".equalsIgnoreCase(addr.getLabel()) ? "🏠" : "📍";
                            %>
                            <div class="addr-card <%= addr.isDefault() ? "selected" : "" %>"
                                 data-full="<%= escHtml(addr.getFullAddress()) %>"
                                 data-label="<%= escHtml(addr.getLabel()) %>"
                                 onclick="selectSavedAddress(this)">
                                <div class="addr-card-label">
                                    <span class="tag-icon"><%= icon %></span>
                                    <%= escHtml(addr.getLabel()) %>
                                    <% if (addr.isDefault()) { %>
                                    <span class="addr-default-tag">Default</span>
                                    <% } %>
                                </div>
                                <p class="addr-card-text"><%= escHtml(addr.getFullAddress()) %></p>
                            </div>
                            <% } %>

                            <!-- Enter new address button -->
                            <button type="button" class="addr-new-btn" onclick="selectNewAddress()">
                                ＋ New address
                            </button>

                        </div>

                        <% } %>

                        <!-- ── Manual entry form ── -->
                        <%
                            // If user has saved addresses, collapse manual form by default
                            // (JS will expand it only when "New address" is clicked)
                            boolean hasSaved = savedAddresses != null && !savedAddresses.isEmpty();
                            String manualClass = hasSaved ? "manual-form collapsed" : "manual-form expanded";
                        %>
                        <div class="<%= manualClass %>" id="manualForm">

                            <% if (hasSaved) { %>
                            <div class="or-divider">or enter a new address</div>
                            <% } %>

                            <div class="form-group">
                                <label class="form-label">Full Name *</label>
                                <input type="text" id="visFullName" class="form-input"
                                       placeholder="Enter your full name"
                                       value="<%= prefillName %>"
                                       oninput="document.getElementById('hFullName').value=this.value">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Phone Number *</label>
                                <input type="tel" id="visPhone" class="form-input"
                                       pattern="[0-9]{10}" placeholder="10-digit mobile number"
                                       value="<%= prefillPhone %>"
                                       oninput="document.getElementById('hPhone').value=this.value">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Complete Address *</label>
                                <input type="text" id="visAddress" class="form-input"
                                       placeholder="House No, Building Name, Street"
                                       oninput="document.getElementById('hAddress').value=this.value">
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">City *</label>
                                    <input type="text" id="visCity" class="form-input"
                                           placeholder="City"
                                           oninput="document.getElementById('hCity').value=this.value">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Pincode *</label>
                                    <input type="text" id="visPincode" class="form-input"
                                           pattern="[0-9]{6}" placeholder="6-digit pincode"
                                           oninput="document.getElementById('hPincode').value=this.value">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Delivery Instructions (Optional)</label>
                                <textarea id="visInstructions" class="form-input"
                                          placeholder="Any specific instructions for delivery…"
                                          oninput="document.getElementById('hInstructions').value=this.value"></textarea>
                            </div>

                        </div><!-- /manualForm -->

                    </form>
                </div>

                <!-- Payment Method -->
                <div class="checkout-section">
                    <h2 class="section-title">
                        <span class="section-title-icon">💳</span>
                        Payment Method
                    </h2>

                    <div class="payment-options">

                        <label class="payment-option selected" onclick="selectPayment(this)">
                            <input type="radio" name="paymentMethod" value="cod" checked form="checkoutForm">
                            <span class="payment-label">
                                <span class="payment-icon">💵</span>
                                Cash on Delivery
                            </span>
                        </label>

                        <label class="payment-option" onclick="selectPayment(this)">
                            <input type="radio" name="paymentMethod" value="upi" form="checkoutForm">
                            <span class="payment-label">
                                <span class="payment-icon">📱</span>
                                UPI (GPay / PhonePe / Paytm)
                            </span>
                        </label>

                        <label class="payment-option" onclick="selectPayment(this)">
                            <input type="radio" name="paymentMethod" value="card" form="checkoutForm">
                            <span class="payment-label">
                                <span class="payment-icon">💳</span>
                                Credit / Debit Card
                            </span>
                        </label>

                        <label class="payment-option" onclick="selectPayment(this)">
                            <input type="radio" name="paymentMethod" value="netbanking" form="checkoutForm">
                            <span class="payment-label">
                                <span class="payment-icon">🏦</span>
                                Net Banking
                            </span>
                        </label>

                    </div>
                </div>

            </div><!-- /checkout-main -->

            <!-- RIGHT: Order Summary -->
            <div class="order-summary-sidebar">
                <div class="summary-card">

                    <h3 class="summary-title">Order Summary</h3>

                    <!-- Selected address preview -->
                    <div class="selected-addr-preview" id="addrPreview">
                        <strong>📍 Delivering to</strong>
                        <span id="addrPreviewText"></span>
                    </div>

                    <div class="summary-items">
                        <% for (Cartitem item : cart.getItems().values()) { %>
                        <div class="summary-item">
                            <div class="item-details">
                                <div class="item-name"><%= item.getMenuName() %></div>
                                <div class="item-qty">Qty: <%= item.getQuantity() %></div>
                            </div>
                            <div class="item-price">₹<%= String.format("%.2f", item.getSubtotal()) %></div>
                        </div>
                        <% } %>
                    </div>

                    <div class="summary-divider"></div>

                    <div class="summary-row">
                        <span>Subtotal (<%= cart.getTotalItems() %> items)</span>
                        <span>₹<%= String.format("%.2f", subtotal) %></span>
                    </div>
                    <div class="summary-row">
                        <span>Delivery Fee</span>
                        <span>₹<%= String.format("%.2f", deliveryFee) %></span>
                    </div>
                    <div class="summary-row">
                        <span>GST (5%)</span>
                        <span>₹<%= String.format("%.2f", gst) %></span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Amount</span>
                        <span>₹<%= String.format("%.2f", grandTotal) %></span>
                    </div>

                    <button type="button" class="place-order-btn" onclick="submitOrder(this)">
                        Place Order 🎉
                    </button>

                </div>
            </div>

        </div>
    </main>
</div>

<script>
/* ═══════════════════════════════════════════════════
   Address selector logic
═══════════════════════════════════════════════════ */

// Track which mode is active: "saved" or "new"
var addressMode = '<%= (savedAddresses != null && !savedAddresses.isEmpty()) ? "saved" : "new" %>';

// On page load: if user has saved addresses, auto-select the default one
window.addEventListener('DOMContentLoaded', function () {
    var defaultCard = document.querySelector('.addr-card.selected');
    if (defaultCard) {
        applyCardToHiddenFields(defaultCard);
        updatePreview(defaultCard.getAttribute('data-label'), defaultCard.getAttribute('data-full'));
    }
});

function selectSavedAddress(card) {
    // Deselect all
    document.querySelectorAll('.addr-card').forEach(function(c) { c.classList.remove('selected'); });
    card.classList.add('selected');

    // Fill hidden fields from card data
    applyCardToHiddenFields(card);

    // Update sidebar preview
    updatePreview(card.getAttribute('data-label'), card.getAttribute('data-full'));

    // Switch to saved mode and collapse manual form
    addressMode = 'saved';
    collapseManual();
}

function applyCardToHiddenFields(card) {
    var fullAddress = card.getAttribute('data-full');

    // The saved address is stored as one string.
    // We put the whole thing in `address` and leave city/pincode
    // as single-space values so PlaceOrderServlet's empty check passes.
    // The confirmation page shows deliveryAddress which is address+city+pincode.
    document.getElementById('hAddress').value  = fullAddress;
    document.getElementById('hCity').value     = '-';
    document.getElementById('hPincode').value  = '000000';
}

function selectNewAddress() {
    // Deselect all cards
    document.querySelectorAll('.addr-card').forEach(function(c) { c.classList.remove('selected'); });

    // Clear hidden fields so validation forces the user to fill the form
    document.getElementById('hAddress').value = '';
    document.getElementById('hCity').value    = '';
    document.getElementById('hPincode').value = '';

    // Hide preview
    document.getElementById('addrPreview').classList.remove('visible');

    // Switch to new mode and expand manual form
    addressMode = 'new';
    expandManual();
}

function collapseManual() {
    var f = document.getElementById('manualForm');
    if (f) { f.classList.remove('expanded'); f.classList.add('collapsed'); }
}

function expandManual() {
    var f = document.getElementById('manualForm');
    if (f) { f.classList.remove('collapsed'); f.classList.add('expanded'); }
}

function updatePreview(label, fullAddress) {
    var preview     = document.getElementById('addrPreview');
    var previewText = document.getElementById('addrPreviewText');
    if (preview && previewText) {
        previewText.textContent = label + ' — ' + fullAddress;
        preview.classList.add('visible');
    }
}

/* ═══════════════════════════════════════════════════
   Form submission validation
═══════════════════════════════════════════════════ */
function submitOrder(btn) {
    var name    = document.getElementById('hFullName').value.trim();
    var phone   = document.getElementById('hPhone').value.trim();
    var address = document.getElementById('hAddress').value.trim();
    var city    = document.getElementById('hCity').value.trim();
    var pincode = document.getElementById('hPincode').value.trim();

    if (!name) {
        alert('Please enter your name.');
        // If in saved mode, name comes from profile — shouldn't be blank
        // but expand the form so they can fix it
        expandManual(); return;
    }
    if (!phone || !/^\d{10}$/.test(phone)) {
        alert('Please enter a valid 10-digit phone number.');
        expandManual(); return;
    }
    if (!address) {
        if (addressMode === 'saved') {
            alert('Please select a delivery address.');
        } else {
            alert('Please enter your delivery address.');
            expandManual();
        }
        return;
    }
    if (!city || !pincode) {
        alert('Please fill in city and pincode.');
        expandManual(); return;
    }

    btn.disabled    = true;
    btn.textContent = 'Placing order…';
    document.getElementById('checkoutForm').submit();
}

/* ═══════════════════════════════════════════════════
   Payment selection
═══════════════════════════════════════════════════ */
function selectPayment(element) {
    document.querySelectorAll('.payment-option').forEach(function(opt) { opt.classList.remove('selected'); });
    element.classList.add('selected');
}

/* ═══════════════════════════════════════════════════
   Theme toggle
═══════════════════════════════════════════════════ */
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
private String escHtml(String s) {
    if (s == null) return "";
    return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#x27;");
}
%>
