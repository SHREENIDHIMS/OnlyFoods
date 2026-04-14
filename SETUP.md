# 🔧 OnlyFoods - Setup Guide

This guide provides detailed step-by-step instructions for setting up the OnlyFoods application on your local machine.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [MySQL Setup](#mysql-setup)
3. [Project Setup](#project-setup)
4. [Tomcat Configuration](#tomcat-configuration)
5. [Running the Application](#running-the-application)
6. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Required Software
- **Java Development Kit (JDK)**: 17 or higher
  - Download from [Oracle](https://www.oracle.com/java/technologies/downloads/) or use OpenJDK
- **Apache Tomcat**: 10.1 or higher
  - Download from [Apache Tomcat](https://tomcat.apache.org/download-10.cgi)
- **MySQL Server**: 8.0 or higher
  - Download from [MySQL](https://dev.mysql.com/downloads/mysql/)
- **IDE** (Recommended): Eclipse IDE for Enterprise Java and Web Developers
  - Download from [Eclipse](https://www.eclipse.org/downloads/)

### Optional Software
- **MySQL Workbench**: For database management
- **Maven**: For dependency management

---

## MySQL Setup

### Step 1: Install MySQL Server

1. Download and install MySQL Server 8.0+
2. During installation, set the root password
3. Note down the port (default: 3306)

### Step 2: Create Database

Open MySQL command line or MySQL Workbench and execute:

```sql
CREATE DATABASE onlyfoods;
```

### Step 3: Create Database Schema

Navigate to the `/database` folder in the project and run the schema file:

```sql
USE onlyfoods;
SOURCE /path/to/OnlyFoods/database/schema.sql;
```

Or copy-paste the SQL statements from `schema.sql` into MySQL Workbench.

### Step 4: Verify Tables

```sql
SHOW TABLES;
```

You should see tables like: `user`, `restaurant`, `menu`, `cart`, `orders`, `orderitems`

### Step 5: (Optional) Insert Sample Data

```sql
-- Sample restaurant
INSERT INTO restaurant (name, cuisinetype, deliverytime, address, rating, isactive, imagepath)
VALUES ('Burger King', 'Fast Food', 30, '123 Main Street, Bangalore', 4.5, true, 'images/restaurants/burger-king.jpg');

-- Sample menu items
INSERT INTO menu (restaurantid, itemname, description, price, isavailable, imagepath)
VALUES 
(1, 'Whopper', 'Classic flame-grilled burger', 199.00, true, 'images/menu/whopper.jpg'),
(1, 'Chicken Fries', 'Crispy chicken strips', 99.00, true, 'images/menu/chicken-fries.jpg');
```

---

## Project Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/SHREENIDHIMS/OnlyEats.git
cd OnlyEats
```

### Step 2: Configure Database Connection

Open `src/main/java/com/OnlyFoods/util/DBConnector.java` and update:

```java
private static final String URL = "jdbc:mysql://localhost:3306/onlyfoods";
private static final String USER = "root";  // Your MySQL username
private static final String PASSWORD = "your_password";  // Your MySQL password
```

### Step 3: Add Required Libraries

Download and add the following JAR files to your project's build path:

1. **MySQL Connector/J** (JDBC Driver)
   - Download: [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/)
   - Version: 8.0.33 or higher

2. **BCrypt** (Password Hashing)
   - Download: [jBCrypt](https://www.mindrot.org/projects/jBCrypt/)
   - Or use Maven dependency

3. **Jakarta Servlet API**
   - Usually provided by Tomcat, but ensure version compatibility

### Step 4: Import Project into Eclipse

1. Open Eclipse IDE
2. **File → Import → Existing Projects into Workspace**
3. Browse to the cloned repository folder
4. Select the project and click **Finish**

### Step 5: Configure Build Path

1. Right-click on project → **Build Path → Configure Build Path**
2. Click **Add External JARs**
3. Add all the downloaded JAR files
4. Click **Apply and Close**

---

## Tomcat Configuration

### Step 1: Download and Install Tomcat

1. Download Apache Tomcat 10.1+ (ZIP/TAR.GZ)
2. Extract to a directory (e.g., `C:\Program Files\Apache Tomcat 10.1`)

### Step 2: Add Tomcat Server in Eclipse

1. **Window → Preferences → Server → Runtime Environments**
2. Click **Add**
3. Select **Apache Tomcat v10.1**
4. Browse to your Tomcat installation directory
5. Click **Finish**

### Step 3: Add Project to Tomcat

1. In Eclipse, go to **Servers** view (bottom panel)
2. Right-click → **New → Server**
3. Select **Apache Tomcat v10.1**
4. Click **Next**
5. Add **OnlyFoods** project to the configured projects
6. Click **Finish**

### Step 4: Configure Context Path

1. Double-click on the Tomcat server in Servers view
2. In **Modules** section, ensure context path is `/OnlyFoods`
3. Save changes

---

## Running the Application

### Step 1: Start MySQL Server

Ensure MySQL server is running on port 3306.

### Step 2: Start Tomcat Server

1. In Eclipse, right-click on Tomcat server
2. Select **Start**
3. Wait for server to start (check Console)

### Step 3: Access the Application

Open your browser and navigate to:
```
http://localhost:8080/OnlyFoods
```

### Step 4: Create Your First Account

1. Click on **Sign Up** or **Register**
2. Fill in your details:
   - Name
   - Email
   - Password (min 8 characters)
   - Phone number
   - Address
3. Click **Register**

### Step 5: Log In

1. Use your registered email and password
2. Click **Login**
3. Start browsing restaurants!

---

## Troubleshooting

### Common Issues

#### 1. **Database Connection Failed**

**Error**: `Communications link failure` or `Access denied for user`

**Solution**:
- Verify MySQL is running
- Check database credentials in `DBConnector.java`
- Ensure database `onlyfoods` exists
- Check firewall settings for port 3306

#### 2. **ClassNotFoundException: com.mysql.cj.jdbc.Driver**

**Solution**:
- Ensure MySQL Connector JAR is added to build path
- Clean and rebuild project
- Restart Tomcat server

#### 3. **404 Error - Page Not Found**

**Solution**:
- Check context path is set to `/OnlyFoods`
- Verify project is deployed on Tomcat
- Check servlet mappings in `web.xml`
- Clear browser cache

#### 4. **BCrypt ClassNotFoundException**

**Solution**:
- Add BCrypt JAR to build path
- Or add Maven dependency:
```xml
<dependency>
    <groupId>org.mindrot</groupId>
    <artifactId>jbcrypt</artifactId>
    <version>0.4</version>
</dependency>
```

#### 5. **Session Timeout Issues**

**Solution**:
- Check session timeout in `web.xml`:
```xml
<session-config>
    <session-timeout>30</session-timeout>
</session-config>
```

#### 6. **Port Already in Use**

**Error**: `Port 8080 already in use`

**Solution**:
- Stop other applications using port 8080
- Or change Tomcat port:
  1. Double-click Tomcat server in Eclipse
  2. Change HTTP/1.1 port (e.g., to 8081)
  3. Save and restart

#### 7. **Images Not Loading**

**Solution**:
- Check image paths in database match actual file locations
- Ensure images are in `webapp/images/` directory
- Clear browser cache
- Check console for 404 errors

---

## Development Tips

### Hot Reload

For faster development, enable automatic reloading:
1. Double-click Tomcat server
2. Set **Publishing → Automatically publish when resources change**
3. Save changes

### Database Changes

When you modify database schema:
1. Update `schema.sql` file
2. Run the changes in MySQL
3. Update corresponding DAO classes if needed

### Adding New Features

1. Create model class in `com.OnlyFoods.model`
2. Create DAO interface in `com.OnlyFoods.dao`
3. Implement DAO in `com.OnlyFoods.daoimp`
4. Create Servlet in `com.OnlyFoods.Servlet`
5. Add servlet mapping in `web.xml`
6. Create JSP page in `webapp/`

---

## Next Steps

Once your application is running:
1. Explore the codebase
2. Add sample restaurants and menu items
3. Test the complete user flow
4. Start building new features

---

## Need Help?

- Check the [main README](README.md) for architecture details
- Review the [API Documentation](API.md)
- Open an issue on GitHub
- Contact: [Your Email]

---

**Happy Coding! 🚀**
