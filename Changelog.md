# Changelog

All notable changes to the OnlyFoods project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Payment gateway integration (Razorpay/Stripe)
- Real-time order tracking
- Rating and review system
- Push notifications
- Advanced search and filters
- Restaurant partner dashboard
- Email notifications
- Mobile application

---

## [1.0.0] - 2026-04-15

### Added - Core Features

#### Authentication System
- User registration with form validation
- BCrypt password hashing for security
- Login/logout functionality
- Session management
- Password strength validation (minimum 8 characters)

#### Restaurant Features
- Restaurant listing page with cards
- Restaurant information display:
  - Name and cuisine type
  - Delivery time estimates
  - Address
  - Rating system
  - Restaurant images
  - Active/inactive status

#### Menu System
- Dynamic menu page per restaurant
- Menu items with:
  - Item name and description
  - Pricing
  - High-quality images
  - Availability status
  - Category tags
- Horizontal category carousel
- Category-based filtering
- Responsive menu grid layout

#### Shopping Cart
- Add items to cart
- Update item quantities
- Remove items from cart
- Session-based cart storage
- Cart persistence across pages
- Real-time price calculations:
  - Subtotal
  - Delivery fee
  - GST (5%)
  - Grand total

#### Checkout & Orders
- Comprehensive checkout page
- Order summary display
- Delivery address management
- Payment mode selection:
  - Cash on Delivery
  - Card (placeholder)
  - UPI (placeholder)
- Order placement
- Order confirmation page

#### User Interface
- Responsive design (mobile, tablet, desktop)
- Dark/light theme toggle
- Pure CSS theme switching (checkbox sibling selector)
- Consistent design system:
  - Primary color: #ff5200 (orange)
  - Custom fonts: Syne (display), DM Sans (body)
  - Shared stylesheet (onlyfoods.css)
- Swiggy-inspired UI/UX
- Smooth animations and transitions
- Accessibility considerations

### Technical Implementation

#### Backend Architecture
- **Java 17** with Jakarta EE
- **Apache Tomcat 10.1** server
- **MVC pattern** implementation
- **DAO pattern** for data access
- **Servlet-based routing**
- **JDBC** for database operations
- **PreparedStatements** for SQL injection prevention

#### Database Design
- **MySQL 8.0** database
- Normalized schema design
- Tables:
  - `user` - User authentication and profiles
  - `restaurant` - Restaurant information
  - `menu` - Menu items
  - `cart` - Shopping cart items
  - `orders` - Order records
  - `orderitems` - Individual order items
- Foreign key relationships
- Proper indexing

#### Package Structure
```
com.OnlyFoods
├── model          # Entity classes (User, Restaurant, Menu, Cartitem, Order)
├── dao            # DAO interfaces
├── daoimp         # DAO implementations
├── Servlet        # Servlet controllers
└── util           # Utility classes (DBConnector, PasswordUtil)
```

#### Frontend Technologies
- **JSP** (JavaServer Pages)
- **JSTL** (JSP Standard Tag Library)
- **CSS3** with custom properties
- **Vanilla JavaScript**
- **Google Fonts** integration

### Security
- BCrypt password hashing (salt rounds: 12)
- Session-based authentication
- SQL injection prevention via PreparedStatements
- Input validation on server-side
- XSS prevention in JSP output

### Performance
- Efficient database queries
- Connection pooling ready
- Optimized image loading
- Minimal JavaScript dependencies
- CSS-only theme switching (no JavaScript)

---

## [0.5.0] - 2026-04-01 (Beta)

### Added
- Initial project setup
- Basic registration and login
- Restaurant listing
- Menu display
- Basic cart functionality

### Changed
- Project renamed from "OnlyEats" to "OnlyFoods"
- Switched from Spring Boot to Jakarta EE
- Redesigned UI theme

---

## [0.1.0] - 2026-03-15 (Alpha)

### Added
- Project initialization
- Database schema design
- Basic servlet structure
- Initial JSP pages

---

## Version History

| Version | Release Date | Status | Description |
|---------|--------------|--------|-------------|
| 1.0.0 | 2026-04-15 | ✅ Current | Full-featured release |
| 0.5.0 | 2026-04-01 | 📦 Beta | Feature-complete beta |
| 0.1.0 | 2026-03-15 | 🔧 Alpha | Initial development |

---

## Upgrade Guide

### From 0.5.0 to 1.0.0

1. **Database Changes**
   - Run migration script: `migrations/v1.0.0.sql`
   - New tables: `orders`, `orderitems`
   - New columns in `user` table

2. **Code Changes**
   - Update `DBConnector` with new connection settings
   - Replace old `CartServlet` with new implementation
   - Add new servlets: `CheckoutServlet`, `PlaceOrderServlet`

3. **Configuration**
   - Update `web.xml` with new servlet mappings
   - Add new session configuration

---

## Contributors

- **Shreenidhi M S** - Initial work and primary development

---

## Notes

- See [SETUP.md](SETUP.md) for installation instructions
- See [API.md](API.md) for servlet endpoint documentation
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

---

**Legend:**
- ✅ Current Release
- 📦 Beta Release
- 🔧 Alpha Release
- 🚀 Planned Feature
- 🐛 Bug Fix
- ⚡ Performance Improvement
- 🔒 Security Update
