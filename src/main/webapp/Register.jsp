<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">
    <style>
        .main { display: flex; flex-direction: column; }
    </style>
</head>
<body>

<%
    String rUsername = request.getAttribute("username") != null ? (String) request.getAttribute("username") : "";
    String rEmail    = request.getAttribute("email")    != null ? (String) request.getAttribute("email")    : "";
    String rPhone    = request.getAttribute("phone")    != null ? (String) request.getAttribute("phone")    : "";
    String rAddress  = request.getAttribute("address")  != null ? (String) request.getAttribute("address")  : "";
    String error     = (String) request.getAttribute("error");
%>

<input type="checkbox" id="theme-toggle">

<div class="main">

    <nav class="navbar">
        <a class="logo" href="<%= request.getContextPath() %>/RestaurantServlet">OnlyFood's</a>
        <label for="theme-toggle" class="toggle-btn" title="Toggle dark / light">🌙</label>
    </nav>

    <div class="page-body">
        <div class="auth-card auth-card-wide">

            <div class="auth-eyebrow">Join us</div>
            <h1 class="auth-title">Create your<br>account</h1>
            <p class="auth-sub">Start ordering from the best restaurants</p>

            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-error">&#9888; <%= error %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/RegisterServlet"
                  method="post" autocomplete="off" onsubmit="return validateForm()">

                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="e.g. ravi_kumar" required maxlength="100"
                           value="<%= rUsername %>">
                </div>

                <div class="form-group">
                    <label for="email">Email address</label>
                    <input type="email" id="email" name="email"
                           placeholder="you@example.com" required autocomplete="email"
                           value="<%= rEmail %>">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="phone">Phone</label>
                        <input type="tel" id="phone" name="phone"
                               placeholder="9876543210" maxlength="15"
                               pattern="[0-9]{10,15}" value="<%= rPhone %>">
                        <span class="field-hint">10–15 digits</span>
                    </div>
                    <div class="form-group">
                        <label for="address">Address</label>
                        <input type="text" id="address" name="address"
                               placeholder="City, State" maxlength="255" value="<%= rAddress %>">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrap">
                        <input type="password" id="password" name="password"
                               placeholder="Min. 8 characters" required minlength="8"
                               oninput="checkStrength(this.value)">
                        <button type="button" class="pw-toggle"
                                onclick="togglePw('password', this)" title="Show / hide">👁</button>
                    </div>
                    <div class="pw-strength-wrap">
                        <div class="pw-strength-bar">
                            <div class="pw-strength-fill" id="strengthFill"></div>
                        </div>
                        <span class="pw-strength-label" id="strengthLabel">Min. 8 characters</span>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm password</label>
                    <div class="input-wrap">
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               placeholder="Repeat your password" required
                               oninput="checkMatch()">
                        <button type="button" class="pw-toggle"
                                onclick="togglePw('confirmPassword', this)" title="Show / hide">👁</button>
                    </div>
                    <span class="field-hint" id="matchHint"></span>
                </div>

                <button type="submit" class="btn-primary">Create Account</button>

            </form>

            <div class="divider">or</div>

            <div class="auth-redirect">
                Already have an account?
                <a href="<%= request.getContextPath() %>/Login.jsp">Sign in</a>
            </div>

        </div>
    </div>

</div>

<script>
    function togglePw(fieldId, btn) {
        var field = document.getElementById(fieldId);
        field.type = field.type === 'password' ? 'text' : 'password';
        btn.textContent = field.type === 'password' ? '👁' : '🙈';
    }

    function checkStrength(val) {
        var fill  = document.getElementById('strengthFill');
        var label = document.getElementById('strengthLabel');
        var score = 0;
        if (val.length >= 8)          score++;
        if (/[A-Z]/.test(val))        score++;
        if (/[0-9]/.test(val))        score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        var levels = [
            { pct: '0%',   color: 'transparent',     text: 'Min. 8 characters' },
            { pct: '30%',  color: 'var(--pw-weak)',   text: 'Weak' },
            { pct: '55%',  color: 'var(--pw-medium)', text: 'Medium' },
            { pct: '80%',  color: 'var(--pw-medium)', text: 'Good' },
            { pct: '100%', color: 'var(--pw-strong)', text: 'Strong ✓' }
        ];

        var lv = val.length === 0 ? levels[0] : levels[score];
        fill.style.width      = lv.pct;
        fill.style.background = lv.color;
        label.textContent     = lv.text;
        label.style.color     = lv.color === 'transparent' ? 'var(--muted)' : lv.color;
        checkMatch();
    }

    function checkMatch() {
        var pw    = document.getElementById('password').value;
        var cpw   = document.getElementById('confirmPassword').value;
        var hint  = document.getElementById('matchHint');
        var field = document.getElementById('confirmPassword');
        if (cpw.length === 0) { hint.textContent = ''; field.classList.remove('input-error'); return; }
        if (pw === cpw) {
            hint.textContent = '✓ Passwords match';
            hint.style.color = 'var(--pw-strong)';
            field.classList.remove('input-error');
        } else {
            hint.textContent = '✗ Passwords do not match';
            hint.style.color = 'var(--pw-weak)';
            field.classList.add('input-error');
        }
    }

    function validateForm() {
        var pw  = document.getElementById('password').value;
        var cpw = document.getElementById('confirmPassword').value;
        if (pw.length < 8)  { alert('Password must be at least 8 characters.'); return false; }
        if (pw !== cpw)     { alert('Passwords do not match.'); return false; }
        return true;
    }

    (function () {
        var toggle = document.getElementById("theme-toggle");
        var label  = document.querySelector("label[for='theme-toggle']");
        function applyTheme(isDark) {
            toggle.checked = isDark;
            if (label) label.textContent = isDark ? "☀️" : "🌙";
        }
        applyTheme(localStorage.getItem("theme") === "dark");
        toggle.addEventListener("change", function () {
            localStorage.setItem("theme", toggle.checked ? "dark" : "light");
            applyTheme(toggle.checked);
        });
    })();
</script>

</body>
</html>
