package com.OnlyFoods.Servlet;

import com.OnlyFoods.dao.CategoryDAO;
import com.OnlyFoods.daoimp.CategoryDAOImpl;
import com.OnlyFoods.model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/home")
public class CategoryServlet extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        categoryDAO = new CategoryDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
