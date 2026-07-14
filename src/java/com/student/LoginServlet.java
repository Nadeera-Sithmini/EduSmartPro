package com.student;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            
            String sql = "SELECT * FROM students WHERE email = ? AND password = ?";
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.setString(1, email);
            statement.setString(2, password);
            
            ResultSet rs = statement.executeQuery();
            
            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("studentName", rs.getString("fullname"));
                
            
                response.sendRedirect("view-students.jsp");
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Email ho Password eka waradii! Karunakarala aeth uthsaha karanna.');");
                out.println("window.location.href = 'login.html';");
                out.println("</script>");
            }
            
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    }
}
