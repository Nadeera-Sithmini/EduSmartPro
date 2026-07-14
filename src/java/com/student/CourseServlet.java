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

@WebServlet(name = "CourseServlet", urlPatterns = {"/CourseServlet"})
public class CourseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        
        if (idParam != null) {
            int id = Integer.parseInt(idParam);
            Connection conn = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
                
                if ("delete".equals(action)) {
                    
                    String sql = "DELETE FROM courses WHERE id = ?";
                    PreparedStatement statement = conn.prepareStatement(sql);
                    statement.setInt(1, id);
                    statement.executeUpdate();
                    response.sendRedirect("manage-courses.jsp");
                    return;
                } else if ("edit".equals(action)) {
                    
                    String sql = "SELECT * FROM courses WHERE id = ?";
                    PreparedStatement statement = conn.prepareStatement(sql);
                    statement.setInt(1, id);
                    ResultSet rs = statement.executeQuery();
                    
                    if (rs.next()) {
                        response.sendRedirect("manage-courses.jsp?editCourseId=" + rs.getInt("id") 
                                + "&cName=" + java.net.URLEncoder.encode(rs.getString("course_name"), "UTF-8")
                                + "&cFee=" + rs.getDouble("course_fee")
                                + "&duration=" + java.net.URLEncoder.encode(rs.getString("duration"), "UTF-8")
                                + "&capacity=" + rs.getInt("capacity")
                                + "&prereq=" + java.net.URLEncoder.encode((rs.getString("prerequisites") != null ? rs.getString("prerequisites") : ""), "UTF-8"));
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try { if(conn != null) conn.close(); } catch(Exception e) {}
            }
        }
        response.sendRedirect("manage-courses.jsp");
    }

   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String courseIdParam = request.getParameter("course_id"); // Edit කරද්දී එන Hidden Field එක
        String courseName = request.getParameter("course_name");
        double courseFee = Double.parseDouble(request.getParameter("course_fee"));
        String duration = request.getParameter("duration");
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        String prerequisites = request.getParameter("prerequisites");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            
            String sql;
            PreparedStatement statement;
            
            
            if (courseIdParam != null && !courseIdParam.trim().isEmpty()) {
                int courseId = Integer.parseInt(courseIdParam);
                sql = "UPDATE courses SET course_name = ?, course_fee = ?, duration = ?, capacity = ?, prerequisites = ? WHERE id = ?";
                statement = conn.prepareStatement(sql);
                statement.setString(1, courseName);
                statement.setDouble(2, courseFee);
                statement.setString(3, duration);
                statement.setInt(4, capacity);
                statement.setString(5, prerequisites);
                statement.setInt(6, courseId);
            } else {
                sql = "INSERT INTO courses (course_name, course_fee, duration, capacity, prerequisites) VALUES (?, ?, ?, ?, ?)";
                statement = conn.prepareStatement(sql);
                statement.setString(1, courseName);
                statement.setDouble(2, courseFee);
                statement.setString(3, duration);
                statement.setInt(4, capacity);
                statement.setString(5, prerequisites);
            }
            
            int rowsAffected = statement.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("manage-courses.jsp");
            }
        } catch (Exception e) {
            out.println("<body style='background:#0b0c10; color:#ff4d4d; font-family:sans-serif; padding: 20px;'>");
            out.println("<h3>Error: " + e.getMessage() + "</h3>");
            out.println("</body>");
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    }
}
