<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — OnlyFood's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Onlyfoods.css">
    <style>
        .main { display: flex; flex-direction: column; }
    </style>
</head>
<body>

<%
    String error   = (String) request.getAttribute("error");
    String regFlag = request.getParameter("registered");
%>

<input type="checkbox" id="theme-toggle">

<div class="main">

    <nav class="navbar">
        <a class="logo" href="<%= request.getContextPath() %>/RestaurantServlet">OnlyFood's</a>
        <label for="theme-toggle" class="toggle-btn" title="Toggle dark / light">🌙</label>
    </nav>

    <div class="page-body">
        <div class="auth-card">

            <div class="auth-eyebrow">Welcome back</div>
            <h1 class="auth-title">Sign in to<br>OnlyFood's</h1>
            <p class="auth-sub">Order from your favourite restaurants</p>

            <% if ("true".equals(regFlag)) { %>
                <div class="alert alert-success">&#10003; Account created! Please sign in.</div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-error">&#9888; <%= error %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/LoginServlet" method="post" autocomplete="on">

                <div class="form-group">
                    <label for="email">Email address</label>
                    <input type="email" id="email" name="email"
                           placeholder="you@example.com" required autocomplete="email"
                           value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrap">
                        <input type="password" id="password" name="password"
                               placeholder="Enter your password" required autocomplete="current-password">
                        <button type="button" class="pw-toggle"
                                onclick="togglePw('password', this)" title="Show / hide">👁</button>
                    </div>
                </div>

                <button type="submit" class="btn-primary">Sign In</button>

            </form>

            <div class="divider">or</div>

            <div class="auth-redirect">
                Don't have an account?
                <a href="<%= request.getContextPath() %>/Register.jsp">Create one</a>
            </div>

        </div>
    </div>

</div>

<script>
    function togglePw(fieldId, btn) {
        var field = document.getElementById(fieldId);
        if (field.type === 'password') { field.type = 'text';     btn.textContent = '🙈'; }
        else                           { field.type = 'password'; btn.textContent = '👁'; }
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
