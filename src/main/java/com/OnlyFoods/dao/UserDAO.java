package com.OnlyFoods.dao;

import com.OnlyFoods.model.User;

/**
 * UserDAO — contract for all user database operations.
 *
 * Password security:
 *   addUser()                    → caller passes a BCrypt hash in user.getPassword()
 *   getUserByEmailAndPassword()  → fetches by EMAIL only; BCrypt.checkpw() is
 *                                  called in LoginServlet after this returns
 */
public interface UserDAO {

    /** Register a new user. Password must already be BCrypt-hashed by caller. */
    int addUser(User user);

    /**
     * Fetch a user by email for the login flow.
     * The {@code password} param is NOT used in SQL — BCrypt check is the caller's job.
     */
    User getUserByEmailAndPassword(String email, String password);

    /** Fetch a user by primary key. */
    User getUserById(int userId);

    /** Check whether an email is already registered. */
    boolean emailExists(String email);

    /** Update lastLoginDate to NOW(). Called by LoginServlet on successful auth. */
    void updateLastLogin(int userId);

    /** Update the phone number for a user. Called by ProfileServlet. */
    void updatePhone(int userId, String phone);

    /** Update the address field for a user. Called by ProfileServlet. */
    void updateAddress(int userId, String address);

    /** Update the BCrypt password hash for a user. Called by ProfileServlet. */
    void updatePassword(int userId, String bcryptHash);
}
