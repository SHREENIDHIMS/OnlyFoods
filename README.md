# 🍔 OnlyFood's

A full-stack food delivery web application built with Java, Jakarta EE, and modern web technologies. OnlyFood's provides a seamless ordering experience with restaurant browsing, menu exploration, cart management, and order placement.

![OnlyFoods Banner](https://img.shields.io/badge/Java-Full--Stack-orange?style=for-the-badge&logo=java)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10.1-blue?style=for-the-badge)
![MySQL](https://img.shields.io/badge/MySQL-Database-blue?style=for-the-badge&logo=mysql)

## 🚀 Features

### User Authentication
- Secure user registration with BCrypt password hashing
- Login/logout functionality with session management
- Password validation and security best practices

### Restaurant & Menu Browsing
- Browse available restaurants with ratings and cuisine types
- Dynamic menu display with category-based filtering
- Horizontal category carousel for easy navigation
- Real-time menu item availability

### Shopping Cart
- Add/remove items from cart
- Update item quantities
- Persistent cart storage in session
- Real-time price calculations

### Order Management
- Comprehensive checkout flow
- Order summary with itemized pricing
- Delivery fee and GST calculations
- Order history tracking

### UI/UX
- Responsive design for all screen sizes
- Dark/light theme toggle
- Modern, Swiggy-inspired interface
- Consistent design system with custom fonts (Syne, DM Sans)
- Orange accent color (#ff5200) throughout

## 🛠️ Tech Stack

### Backend
- **Java 17+**
- **Jakarta EE (Servlets, JSP)**
- **Apache Tomcat 10.1**
- **MySQL 8.0+**
- **JDBC** for database connectivity
- **BCrypt** for password hashing

### Frontend
- **JSP (JavaServer Pages)**
- **CSS3** (Custom stylesheets)
- **Vanilla JavaScript**
- **Google Fonts** (Syne, DM Sans)

### Architecture
- **MVC Pattern**
- **DAO Pattern** for data access
- **Servlet-based routing**

## 📁 Project Structure

```
OnlyFoods/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── OnlyFoods/
│       │           ├── model/          # Entity classes
│       │           ├── dao/            # DAO interfaces
│       │           ├── daoimp/         # DAO implementations
│       │           ├── Servlet/        # Servlet controllers
│       │           └── util/           # Utility classes
│       └── webapp/
│           ├── WEB-INF/
│           │   └── web.xml            # Deployment descriptor
│           ├── css/
│           │   └── onlyfoods.css      # Main stylesheet
│           ├── images/                # Static images
│           └── *.jsp                  # JSP pages
├── database/
│   └── schema.sql                     # Database schema
└── README.md
```

## 📦 Package Structure

```
com.OnlyFoods
├── model               # POJOs (User, Restaurant, Menu, Cartitem, etc.)
├── dao                 # Data Access Object interfaces
├── daoimp              # DAO implementations with JDBC
├── Servlet             # Servlet controllers
└── util                # Helper classes (DBConnector, PasswordUtil, etc.)
```

## ⚙️ Installation & Setup

### Prerequisites
- Java Development Kit (JDK) 17 or higher
- Apache Tomcat 10.1+
- MySQL 8.0+
- Eclipse IDE / IntelliJ IDEA (optional)
- Maven (optional, for dependency management)

### Database Setup

1. **Create Database**
```sql
CREATE DATABASE onlyfoods;
USE onlyfoods;
```

2. **Run Schema Script**
```sql
-- Execute the schema.sql file located in /database folder
SOURCE /path/to/database/schema.sql;
```

3. **Configure Database Connection**

Update the database credentials in `DBConnector.java`:
```java
private static final String URL = "jdbc:mysql://localhost:3306/onlyfoods";
private static final String USER = "your_username";
private static final String PASSWORD = "your_password";
```

### Application Setup

1. **Clone the Repository**
```bash
git clone https://github.com/SHREENIDHIMS/OnlyEats.git
cd OnlyEats
```

2. **Import Project**
   - Open Eclipse/IntelliJ
   - Import as existing project
   - Configure build path with required JARs

3. **Add Required JARs**
   - MySQL Connector/J (JDBC Driver)
   - BCrypt library
   - Jakarta Servlet API
   - JSTL (JavaServer Pages Standard Tag Library)

4. **Configure Tomcat**
   - Add project to Tomcat server
   - Set context path to `/OnlyFoods`

5. **Deploy & Run**
   - Start Tomcat server
   - Access application at: `http://localhost:8080/OnlyFoods`

## 🎯 Usage

### First Time Users
1. Navigate to the registration page
2. Create an account with email and password
3. Log in with your credentials

### Ordering Food
1. Browse available restaurants
2. Select a restaurant to view menu
3. Add items to cart
4. Proceed to checkout
5. Review order summary and place order

### Theme Toggle
- Use the theme toggle switch in the navigation bar
- Preference is saved per session

## 🗄️ Database Schema

### Key Tables
- `user` - User authentication and profile data
- `restaurant` - Restaurant information
- `menu` - Menu items with pricing and availability
- `cart` - Shopping cart items (session-based)
- `orders` - Order history
- `orderitems` - Individual items in orders

*Refer to `/database/schema.sql` for complete schema*

## 🎨 Design System

### Colors
- **Primary Orange**: `#ff5200`
- **Dark Theme**: Background `#1a1a1a`, Text `#ffffff`
- **Light Theme**: Background `#ffffff`, Text `#000000`

### Typography
- **Display Font**: Syne (headings, brand)
- **Body Font**: DM Sans (body text, UI)

### Components
- Pure CSS theme toggle (checkbox sibling selector)
- Responsive navigation bar
- Card-based layouts
- Horizontal scrolling carousels

## 🚧 Roadmap

- [ ] Payment gateway integration
- [ ] Real-time order tracking
- [ ] Restaurant partner dashboard
- [ ] Review and rating system
- [ ] Advanced search and filters
- [ ] Push notifications
- [ ] Mobile application

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Shreenidhi M S**
- GitHub: [@SHREENIDHIMS](https://github.com/SHREENIDHIMS)
- LinkedIn: [Shreenidhi M S](https://www.linkedin.com/in/shreenidhi-m03/)

## 🙏 Acknowledgments

- Tap Academy for the internship opportunity
- Swiggy for UI/UX inspiration
- The Jakarta EE community

---

⭐ If you find this project helpful, please consider giving it a star!

**Built with ❤️ using Java & Jakarta EE**
