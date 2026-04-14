# 🤝 Contributing to OnlyFoods

Thank you for considering contributing to OnlyFoods! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, background, or identity.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Accept responsibility for mistakes
- Prioritize the community's best interests

### Unacceptable Behavior

- Harassment or discrimination of any kind
- Offensive comments or personal attacks
- Trolling or inflammatory remarks
- Publishing others' private information
- Any conduct inappropriate in a professional setting

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
1. Set up the development environment (see [SETUP.md](SETUP.md))
2. Read the [README.md](README.md) and [API.md](API.md)
3. Forked the repository
4. Created a local clone of your fork

### Fork and Clone

```bash
# Fork the repository on GitHub

# Clone your fork
git clone https://github.com/YOUR_USERNAME/OnlyEats.git
cd OnlyEats

# Add upstream remote
git remote add upstream https://github.com/SHREENIDHIMS/OnlyEats.git

# Verify remotes
git remote -v
```

### Keep Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Merge changes from upstream main
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

---

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features (e.g., `feature/payment-gateway`)
- `bugfix/` - Bug fixes (e.g., `bugfix/cart-quantity-issue`)
- `refactor/` - Code refactoring (e.g., `refactor/dao-layer`)
- `docs/` - Documentation updates (e.g., `docs/api-documentation`)
- `style/` - UI/CSS changes (e.g., `style/dark-theme-fix`)

### 2. Make Your Changes

- Write clean, well-documented code
- Follow the coding standards (see below)
- Test your changes thoroughly
- Update documentation if needed

### 3. Test Your Changes

```bash
# Start your local server
# Test manually in browser

# Check for:
- Functionality works as expected
- No console errors
- Responsive design on mobile
- Both light and dark themes
- Database operations complete successfully
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add payment gateway integration"
```

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Create a Pull Request

1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. Fill out the PR template
4. Submit the pull request

---

## Coding Standards

### Java Code Standards

#### Naming Conventions

```java
// Classes: PascalCase
public class RestaurantServlet extends HttpServlet { }

// Interfaces: PascalCase with descriptive name
public interface UserDAO { }

// Methods: camelCase, descriptive verbs
public User getUserById(int userId) { }

// Variables: camelCase
private String userName;
private int restaurantId;

// Constants: UPPER_SNAKE_CASE
private static final String DB_URL = "jdbc:mysql://localhost:3306/onlyfoods";
```

#### Code Structure

```java
// Proper exception handling
try {
    // Database operation
    user = userDAO.getUserById(userId);
} catch (SQLException e) {
    e.printStackTrace();
    request.setAttribute("errorMessage", "Database error occurred");
    request.getRequestDispatcher("error.jsp").forward(request, response);
}

// Use try-with-resources for JDBC
try (Connection conn = DBConnector.getConnection();
     PreparedStatement pstmt = conn.prepareStatement(query)) {
    // Use the connection
} catch (SQLException e) {
    e.printStackTrace();
}
```

#### Documentation

```java
/**
 * Retrieves a user by their ID from the database.
 * 
 * @param userId The unique identifier of the user
 * @return User object if found, null otherwise
 * @throws SQLException if database error occurs
 */
public User getUserById(int userId) throws SQLException {
    // Implementation
}
```

### JSP/HTML Standards

```jsp
<%-- Use JSTL for logic --%>
<c:forEach var="restaurant" items="${restaurantList}">
    <div class="restaurant-card">
        <h3>${restaurant.name}</h3>
    </div>
</c:forEach>

<%-- Avoid scriptlets, use EL --%>
<!-- BAD -->
<%= request.getAttribute("username") %>

<!-- GOOD -->
${username}
```

### CSS Standards

```css
/* Use the project's CSS custom properties */
:root {
    --primary-orange: #ff5200;
    --bg-color: #ffffff;
    --text-color: #000000;
}

/* Use meaningful class names */
.restaurant-card {
    /* Styles */
}

/* Use the theme toggle pattern */
.theme-toggle:checked ~ .container {
    --bg-color: #1a1a1a;
    --text-color: #ffffff;
}

/* Mobile-first approach */
.menu-item {
    width: 100%;
}

@media (min-width: 768px) {
    .menu-item {
        width: 50%;
    }
}
```

### SQL Standards

```sql
-- Use meaningful table and column names
CREATE TABLE order_items (
    orderitemid INT PRIMARY KEY AUTO_INCREMENT,
    orderid INT NOT NULL,
    menuid INT NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Always use prepared statements in Java
String query = "SELECT * FROM user WHERE email = ?";
PreparedStatement pstmt = conn.prepareStatement(query);
pstmt.setString(1, email);
```

---

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(cart): add quantity update functionality"

# Bug fix
git commit -m "fix(login): resolve BCrypt password verification issue"

# Documentation
git commit -m "docs(readme): add installation instructions"

# Refactoring
git commit -m "refactor(dao): extract common JDBC code to base class"

# Style
git commit -m "style(menu): improve card hover effects"
```

---

## Pull Request Process

### Before Submitting

- [ ] Code follows the project's coding standards
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages follow conventions
- [ ] No merge conflicts with main branch
- [ ] Code is properly commented

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation update

## Testing
Describe how you tested your changes

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No console errors
- [ ] Works on mobile
- [ ] Dark theme works
```

### Review Process

1. Maintainer reviews your PR
2. Feedback is provided via comments
3. Make requested changes
4. Push updates to your branch
5. PR is approved and merged

---

## Bug Reports

### Before Submitting

- Check if the bug has already been reported
- Try to reproduce the bug
- Gather relevant information

### Bug Report Template

```markdown
**Describe the bug**
A clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment**
- Browser: [e.g., Chrome 120]
- OS: [e.g., Windows 11]
- Java version: [e.g., 17]
- Tomcat version: [e.g., 10.1]

**Additional context**
Any other relevant information
```

---

## Feature Requests

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of what you want to happen

**Describe alternatives you've considered**
Other solutions you've thought about

**Additional context**
Screenshots, mockups, or examples
```

---

## Areas for Contribution

### High Priority

- [ ] Payment gateway integration
- [ ] Order tracking system
- [ ] Rating and review system
- [ ] Search and filter functionality
- [ ] Admin dashboard

### Good First Issues

- [ ] UI improvements
- [ ] Code documentation
- [ ] Test coverage
- [ ] Accessibility improvements
- [ ] Performance optimizations

### Documentation

- [ ] API documentation
- [ ] Code comments
- [ ] User guides
- [ ] Deployment guides

---

## Questions?

- Open a GitHub issue with the `question` label
- Join our discussions on GitHub
- Contact: [Your Email]

---

## Recognition

Contributors will be acknowledged in:
- README.md contributors section
- Release notes
- Project website (when available)

---

Thank you for contributing to OnlyFoods! 🎉

**Let's build something amazing together!** 🚀
