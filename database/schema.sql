-- ============================================
-- OnlyFoods Database Schema
-- MySQL 8.0+
-- Run: SOURCE /path/to/schema.sql
-- ============================================
-- ─────────────────────────────────────────────
-- Table: user
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user (
    userid       INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100)        NOT NULL,
    email        VARCHAR(150)        NOT NULL UNIQUE,
    password     VARCHAR(255)        NOT NULL,   -- BCrypt hash
    phone        VARCHAR(15)         NOT NULL,
    address      TEXT                NOT NULL,
    createdat    TIMESTAMP           DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- Table: restaurant
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS restaurant (
    restaurantid  INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150)        NOT NULL,
    cuisinetype   VARCHAR(100)        NOT NULL,
    deliverytime  INT                 NOT NULL,   -- minutes
    address       VARCHAR(255)        NOT NULL,
    rating        FLOAT               DEFAULT 0.0,
    isactive      BOOLEAN             DEFAULT TRUE,
    imagepath     VARCHAR(255)
);

-- ─────────────────────────────────────────────
-- Table: menu
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS menu (
    menuid        INT AUTO_INCREMENT PRIMARY KEY,
    restaurantid  INT                 NOT NULL,
    itemname      VARCHAR(150)        NOT NULL,
    description   TEXT,
    price         DECIMAL(10, 2)      NOT NULL,
    category      VARCHAR(100),
    isavailable   BOOLEAN             DEFAULT TRUE,
    imagepath     VARCHAR(255),
    FOREIGN KEY (restaurantid) REFERENCES restaurant(restaurantid)
        ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- Table: orders
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    orderid        INT AUTO_INCREMENT PRIMARY KEY,
    userid         INT                 NOT NULL,
    restaurantid   INT                 NOT NULL,
    totalamount    DECIMAL(10, 2)      NOT NULL,
    status         VARCHAR(50)         DEFAULT 'Pending',
    paymentmode    VARCHAR(50)         NOT NULL,
    deliveryaddress TEXT,
    orderdate      TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userid)       REFERENCES user(userid),
    FOREIGN KEY (restaurantid) REFERENCES restaurant(restaurantid)
);

-- ─────────────────────────────────────────────
-- Table: orderitems
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orderitems (
    orderitemid   INT AUTO_INCREMENT PRIMARY KEY,
    orderid       INT                 NOT NULL,
    menuid        INT                 NOT NULL,
    itemname      VARCHAR(150)        NOT NULL,
    quantity      INT                 NOT NULL,
    price         DECIMAL(10, 2)      NOT NULL,
    subtotal      DECIMAL(10, 2)      NOT NULL,
    FOREIGN KEY (orderid) REFERENCES orders(orderid) ON DELETE CASCADE,
    FOREIGN KEY (menuid)  REFERENCES menu(menuid)
);

-- ─────────────────────────────────────────────
-- Sample Data (optional — for testing)
-- ─────────────────────────────────────────────

-- Sample Restaurants
INSERT INTO restaurant (name, cuisinetype, deliverytime, address, rating, isactive, imagepath) VALUES
('Burger King',    'Fast Food',    30, 'MG Road, Bangalore',       4.5, TRUE, 'images/restaurants/burger-king.jpg'),
('Pizza Hut',      'Italian',      45, 'Koramangala, Bangalore',   4.2, TRUE, 'images/restaurants/pizza-hut.jpg'),
('Biryani Blues',  'North Indian', 35, 'Indiranagar, Bangalore',   4.7, TRUE, 'images/restaurants/biryani-blues.jpg'),
('Meghana Foods',  'South Indian', 25, 'Church Street, Bangalore', 4.8, TRUE, 'images/restaurants/meghana.jpg');

-- Sample Menu Items — Burger King (restaurantid = 1)
INSERT INTO menu (restaurantid, itemname, description, price, category, isavailable, imagepath) VALUES
(1, 'Whopper',           'Classic flame-grilled beef burger',        199.00, 'Burgers',  TRUE, 'images/menu/whopper.jpg'),
(1, 'Chicken Royale',    'Crispy chicken fillet burger',             179.00, 'Burgers',  TRUE, 'images/menu/chicken-royale.jpg'),
(1, 'Chicken Fries',     'Crispy chicken strips',                     99.00, 'Sides',    TRUE, 'images/menu/chicken-fries.jpg'),
(1, 'Onion Rings',       'Golden crispy onion rings',                 79.00, 'Sides',    TRUE, 'images/menu/onion-rings.jpg'),
(1, 'Pepsi Large',       'Cold refreshing Pepsi',                     59.00, 'Drinks',   TRUE, 'images/menu/pepsi.jpg');

-- Sample Menu Items — Pizza Hut (restaurantid = 2)
INSERT INTO menu (restaurantid, itemname, description, price, category, isavailable, imagepath) VALUES
(2, 'Margherita Pizza',  'Classic tomato and mozzarella',            299.00, 'Pizzas',   TRUE, 'images/menu/margherita.jpg'),
(2, 'Pepperoni Pizza',   'Loaded with spicy pepperoni',              399.00, 'Pizzas',   TRUE, 'images/menu/pepperoni.jpg'),
(2, 'Garlic Bread',      'Toasted garlic bread with herb butter',     99.00, 'Sides',    TRUE, 'images/menu/garlic-bread.jpg');

-- Sample Menu Items — Biryani Blues (restaurantid = 3)
INSERT INTO menu (restaurantid, itemname, description, price, category, isavailable, imagepath) VALUES
(3, 'Chicken Biryani',   'Aromatic basmati rice with tender chicken', 249.00, 'Biryani',  TRUE, 'images/menu/chicken-biryani.jpg'),
(3, 'Mutton Biryani',    'Rich mutton pieces in layered biryani',     349.00, 'Biryani',  TRUE, 'images/menu/mutton-biryani.jpg'),
(3, 'Veg Biryani',       'Fresh vegetables with saffron rice',        199.00, 'Biryani',  TRUE, 'images/menu/veg-biryani.jpg'),
(3, 'Raita',             'Cooling yoghurt with cucumber',              49.00, 'Sides',    TRUE, 'images/menu/raita.jpg');
