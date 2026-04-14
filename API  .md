# 📡 OnlyFoods - API Documentation

This document outlines all the servlet endpoints and their functionality in the OnlyFoods application.

## Table of Contents
- [Authentication Endpoints](#authentication-endpoints)
- [Restaurant Endpoints](#restaurant-endpoints)
- [Menu Endpoints](#menu-endpoints)
- [Cart Endpoints](#cart-endpoints)
- [Order Endpoints](#order-endpoints)
- [User Profile Endpoints](#user-profile-endpoints)

---

## Authentication Endpoints

### User Registration

**Endpoint**: `/register`  
**Method**: `POST`  
**Servlet**: `RegisterServlet`

**Request Parameters**:
```
name: String (required)
email: String (required, unique)
password: String (required, min 8 characters)
phone: String (required)
address: String (required)
```

**Success Response**:
- Redirects to: `/login.jsp`
- Message: "Registration successful! Please login."

**Error Response**:
- Returns to: `/register.jsp`
- Error message in session attribute: `registrationError`

**Example**:
```html
<form action="register" method="post">
    <input type="text" name="name" required>
    <input type="email" name="email" required>
    <input type="password" name="password" required>
    <input type="text" name="phone" required>
    <textarea name="address" required></textarea>
    <button type="submit">Register</button>
</form>
```

---

### User Login

**Endpoint**: `/login`  
**Method**: `POST`  
**Servlet**: `LoginServlet`

**Request Parameters**:
```
email: String (required)
password: String (required)
```

**Success Response**:
- Creates session attribute: `user` (User object)
- Redirects to: `/restaurant`

**Error Response**:
- Returns to: `/login.jsp`
- Error message in session: `loginError`

**Session Attributes Set**:
- `user`: User object containing userId, name, email, etc.

---

### User Logout

**Endpoint**: `/logout`  
**Method**: `GET`  
**Servlet**: `LogoutServlet`

**Functionality**:
- Invalidates current session
- Clears cart
- Redirects to: `/login.jsp`

---

## Restaurant Endpoints

### Get All Restaurants

**Endpoint**: `/restaurant`  
**Method**: `GET`  
**Servlet**: `RestaurantServlet`

**Success Response**:
- Forwards to: `Restaurant.jsp`
- Request attribute: `restaurantList` (List<Restaurant>)

**Restaurant Object Structure**:
```java
{
    restaurantid: Integer
    name: String
    cuisinetype: String
    deliverytime: Integer (minutes)
    address: String
    rating: Float
    isactive: Boolean
    imagepath: String
}
```

**Example JSP Usage**:
```jsp
<c:forEach var="restaurant" items="${restaurantList}">
    <div class="restaurant-card">
        <img src="${restaurant.imagepath}" alt="${restaurant.name}">
        <h3>${restaurant.name}</h3>
        <p>${restaurant.cuisinetype}</p>
        <p>Delivery: ${restaurant.deliverytime} mins</p>
        <p>Rating: ${restaurant.rating}⭐</p>
        <a href="menu?restaurantid=${restaurant.restaurantid}">View Menu</a>
    </div>
</c:forEach>
```

---

## Menu Endpoints

### Get Restaurant Menu

**Endpoint**: `/menu`  
**Method**: `GET`  
**Servlet**: `MenuServlet`

**Request Parameters**:
```
restaurantid: Integer (required)
```

**Success Response**:
- Forwards to: `Menu.jsp`
- Request attributes:
  - `menuList`: List<Menu>
  - `restaurantid`: Integer
  - `categories`: List<String> (unique menu categories)

**Menu Object Structure**:
```java
{
    menuid: Integer
    restaurantid: Integer
    itemname: String
    description: String
    price: Float
    isavailable: Boolean
    imagepath: String
    category: String
}
```

**Example**:
```jsp
<!-- Display categories -->
<c:forEach var="category" items="${categories}">
    <button onclick="filterByCategory('${category}')">${category}</button>
</c:forEach>

<!-- Display menu items -->
<c:forEach var="item" items="${menuList}">
    <div class="menu-item" data-category="${item.category}">
        <img src="${item.imagepath}" alt="${item.itemname}">
        <h4>${item.itemname}</h4>
        <p>${item.description}</p>
        <p>₹${item.price}</p>
        <button onclick="addToCart(${item.menuid})">Add to Cart</button>
    </div>
</c:forEach>
```

---

## Cart Endpoints

### Add to Cart

**Endpoint**: `/cart`  
**Method**: `POST`  
**Servlet**: `CartServlet` (doPost)

**Request Parameters**:
```
action: "add"
itemId: Integer (menuid)
quantity: Integer (default: 1)
```

**Success Response**:
- Updates session cart
- Returns JSON: `{"status": "success", "message": "Item added to cart"}`

**Session Cart Structure**:
```java
Map<Integer, Cartitem> cart = {
    menuid: {
        itemid: Integer (menuid)
        restaurantid: Integer
        name: String
        quantity: Integer
        price: Float
    }
}
```

---

### View Cart

**Endpoint**: `/cart`  
**Method**: `GET`  
**Servlet**: `CartServlet` (doGet)

**Success Response**:
- Forwards to: `Cart.jsp`
- Request attributes:
  - `cartItems`: Collection<Cartitem>
  - `subtotal`: Float
  - `deliveryFee`: Float
  - `gst`: Float
  - `total`: Float

---

### Update Cart Item

**Endpoint**: `/cart`  
**Method**: `POST`  
**Servlet**: `CartServlet`

**Request Parameters**:
```
action: "update"
itemId: Integer
quantity: Integer
```

**Success Response**:
- Updates cart in session
- Redirects to: `/cart`

---

### Remove from Cart

**Endpoint**: `/cart`  
**Method**: `POST`  
**Servlet**: `CartServlet`

**Request Parameters**:
```
action: "remove"
itemId: Integer
```

**Success Response**:
- Removes item from session cart
- Redirects to: `/cart`

---

## Order Endpoints

### Checkout

**Endpoint**: `/checkout`  
**Method**: `GET`  
**Servlet**: `CheckoutServlet`

**Prerequisites**:
- User must be logged in
- Cart must not be empty

**Success Response**:
- Forwards to: `Checkout.jsp`
- Request attributes:
  - `cartItems`: Collection<Cartitem>
  - `subtotal`: Float
  - `deliveryFee`: Float
  - `gst`: Float
  - `total`: Float
  - `user`: User object (for delivery address)

---

### Place Order

**Endpoint**: `/placeorder`  
**Method**: `POST`  
**Servlet**: `PlaceOrderServlet`

**Request Parameters**:
```
paymentMode: String ("Cash on Delivery", "Card", "UPI")
deliveryAddress: String (optional, defaults to user's address)
```

**Success Response**:
- Creates order in database
- Creates order items
- Clears cart
- Forwards to: `OrderConfirmation.jsp`
- Request attribute: `order` (Order object)

**Order Object Structure**:
```java
{
    orderid: Integer
    userid: Integer
    restaurantid: Integer
    totalamount: Float
    status: String ("Pending", "Confirmed", "Delivered", "Cancelled")
    paymentmode: String
    orderdate: Timestamp
}
```

---

### View Order History

**Endpoint**: `/orders`  
**Method**: `GET`  
**Servlet**: `OrderHistoryServlet`

**Prerequisites**:
- User must be logged in

**Success Response**:
- Forwards to: `OrderHistory.jsp`
- Request attribute: `orderList` (List<Order>)

---

### View Order Details

**Endpoint**: `/orderdetails`  
**Method**: `GET`  
**Servlet**: `OrderDetailsServlet`

**Request Parameters**:
```
orderid: Integer (required)
```

**Success Response**:
- Forwards to: `OrderDetails.jsp`
- Request attributes:
  - `order`: Order object
  - `orderItems`: List<OrderItem>

**OrderItem Object Structure**:
```java
{
    orderitemid: Integer
    orderid: Integer
    menuid: Integer
    quantity: Integer
    subtotal: Float
    itemname: String
    price: Float
}
```

---

## User Profile Endpoints

### View Profile

**Endpoint**: `/profile`  
**Method**: `GET`  
**Servlet**: `ProfileServlet`

**Prerequisites**:
- User must be logged in

**Success Response**:
- Forwards to: `Profile.jsp`
- Request attribute: `user` (User object from session)

---

### Update Profile

**Endpoint**: `/profile`  
**Method**: `POST`  
**Servlet**: `ProfileServlet`

**Request Parameters**:
```
name: String
phone: String
address: String
```

**Success Response**:
- Updates user in database
- Updates session user object
- Redirects to: `/profile`
- Success message in session

---

## Error Handling

All servlets implement consistent error handling:

### Common Error Responses

1. **Not Authenticated**:
   - Redirects to: `/login.jsp`
   - Message: "Please login to continue"

2. **Invalid Parameters**:
   - Returns to previous page
   - Error message in request/session

3. **Database Errors**:
   - Redirects to error page
   - Generic error message (details logged)

### Error Page

**Endpoint**: `/error.jsp`

**Attributes**:
```
errorMessage: String
errorCode: String (optional)
```

---

## Session Management

### Session Attributes

```java
// User session
session.setAttribute("user", userObject);

// Cart session
session.setAttribute("cart", cartMap);

// Flash messages
session.setAttribute("successMessage", "Operation successful");
session.setAttribute("errorMessage", "Operation failed");
```

### Session Timeout

Default: 30 minutes (configurable in `web.xml`)

```xml
<session-config>
    <session-timeout>30</session-timeout>
</session-config>
```

---

## Request/Response Flow

### Typical User Journey

```
1. GET /restaurant
   → Display all restaurants

2. GET /menu?restaurantid=1
   → Display menu for restaurant 1

3. POST /cart (action=add, itemId=5, quantity=2)
   → Add item to cart

4. GET /cart
   → View cart contents

5. GET /checkout
   → Review order

6. POST /placeorder (paymentMode=Cash on Delivery)
   → Create order

7. GET /orderdetails?orderid=123
   → View order confirmation
```

---

## JavaScript Integration Examples

### Add to Cart (AJAX)

```javascript
function addToCart(menuId) {
    fetch('/OnlyFoods/cart', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `action=add&itemId=${menuId}&quantity=1`
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert('Item added to cart!');
            updateCartCount();
        }
    })
    .catch(error => console.error('Error:', error));
}
```

### Update Cart Quantity

```javascript
function updateQuantity(itemId, newQuantity) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/OnlyFoods/cart';
    
    form.innerHTML = `
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="itemId" value="${itemId}">
        <input type="hidden" name="quantity" value="${newQuantity}">
    `;
    
    document.body.appendChild(form);
    form.submit();
}
```

---

## Security Considerations

1. **Password Hashing**: All passwords are hashed using BCrypt
2. **Session Validation**: Check user session before protected operations
3. **Input Validation**: Validate and sanitize all user inputs
4. **SQL Injection Prevention**: Use PreparedStatements
5. **XSS Prevention**: Escape output in JSP pages

---

## Future API Enhancements

- RESTful JSON APIs for mobile app
- Search and filter endpoints
- Rating and review endpoints
- Real-time order tracking
- Admin dashboard APIs

---

**Last Updated**: April 2026  
**Version**: 1.0
