package com.student;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "UpdateStudentServlet", urlPatterns = {"/UpdateStudentServlet"})
public class UpdateStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String course = request.getParameter("course");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            
            // ඩේටාබේස් එකේ තියෙන විස්තර අලුත් ඒවායින් UPDATE කරන Query එක
            String sql = "UPDATE students SET fullname=?, email=?, phone=?, dob=?, course=? WHERE id=?";
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.setString(1, fullname);
            statement.setString(2, email);
            statement.setString(3, phone);
            statement.setString(4, dob);
            statement.setString(5, course);
            statement.setString(6, id);
            
            int rowsUpdated = statement.executeUpdate();
            if (rowsUpdated > 0) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Student details updated successfully!');");
                out.println("window.location.href = 'view-students.jsp';");
                out.println("</script>");
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    }
}