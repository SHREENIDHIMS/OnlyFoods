package com.OnlyFoods.model;

/**
 * Represents a favourited restaurant or menu item.
 * Used as a lightweight DTO for display on the profile page.
 */
public class Favourite {

    public enum Type { RESTAURANT, MENU }

    private int    id;           // favRestId or favMenuId
    private int    userId;
    private int    targetId;     // restaurantId or menuId
    private String name;         // restaurant name or menu item name
    private String subText;      // cuisine + rating  OR  restaurant name
    private Type   type;

    public Favourite() {}

    // ── Getters ──────────────────────────────────────────────────
    public int    getId()       { return id; }
    public int    getUserId()   { return userId; }
    public int    getTargetId() { return targetId; }
    public String getName()     { return name; }
    public String getSubText()  { return subText; }
    public Type   getType()     { return type; }

    // ── Setters ──────────────────────────────────────────────────
    public void setId(int id)           { this.id       = id; }
    public void setUserId(int userId)   { this.userId   = userId; }
    public void setTargetId(int tid)    { this.targetId = tid; }
    public void setName(String name)    { this.name     = name; }
    public void setSubText(String sub)  { this.subText  = sub; }
    public void setType(Type type)      { this.type     = type; }
}
