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

@WebServlet(name = "SubjectServlet", urlPatterns = {"/SubjectServlet"})
public class SubjectServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 1. DELETE සහ EDIT සඳහා GET රික්වෙස්ට් හැන්ඩ්ල් කිරීම
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
                    // Delete කිරීම
                    String sql = "DELETE FROM subjects WHERE id = ?";
                    PreparedStatement statement = conn.prepareStatement(sql);
                    statement.setInt(1, id);
                    statement.executeUpdate();
                    response.sendRedirect("manage-courses.jsp#subjects");
                    return;
                } else if ("edit".equals(action)) {
                    // Edit කිරීමට අදාළ ඩේටා ටික විතරක් අරන් ආයෙත් පිටුවටම යවනවා (Query String එකෙන්)
                    String sql = "SELECT * FROM subjects WHERE id = ?";
                    PreparedStatement statement = conn.prepareStatement(sql);
                    statement.setInt(1, id);
                    ResultSet rs = statement.executeQuery();
                    
                    if (rs.next()) {
                        response.sendRedirect("manage-courses.jsp?editSubId=" + rs.getInt("id") 
                                + "&subName=" + java.net.URLEncoder.encode(rs.getString("subject_name"), "UTF-8")
                                + "&courseId=" + rs.getInt("course_id")
                                + "&credits=" + rs.getInt("credits")
                                + "&semester=" + java.net.URLEncoder.encode(rs.getString("semester"), "UTF-8")
                                + "#subjects");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try { if(conn != null) conn.close(); } catch(Exception e) {}
            }
        }
        response.sendRedirect("manage-courses.jsp#subjects");
    }

    // 2. INSERT සහ UPDATE (SAVE) සඳහා POST රික්වෙස්ට් හැන්ඩ්ල් කිරීම
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Form Data ලබා ගැනීම
        String subIdParam = request.getParameter("subject_id"); // Edit කරද්දී විතරක් එන Hidden Field එක
        String subjectName = request.getParameter("subject_name");
        int courseId = Integer.parseInt(request.getParameter("assigned_course"));
        int credits = Integer.parseInt(request.getParameter("credits"));
        String semester = request.getParameter("semester");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            
            String sql;
            PreparedStatement statement;
            
            // subject_id එකක් ආවොත් UPDATE කරනවා, නැත්නම් INSERT කරනවා
            if (subIdParam != null && !subIdParam.trim().isEmpty()) {
                int subjectId = Integer.parseInt(subIdParam);
                sql = "UPDATE subjects SET subject_name = ?, course_id = ?, credits = ?, semester = ? WHERE id = ?";
                statement = conn.prepareStatement(sql);
                statement.setString(1, subjectName);
                statement.setInt(2, courseId);
                statement.setInt(3, credits);
                statement.setString(4, semester);
                statement.setInt(5, subjectId);
            } else {
                sql = "INSERT INTO subjects (subject_name, course_id, credits, semester) VALUES (?, ?, ?, ?)";
                statement = conn.prepareStatement(sql);
                statement.setString(1, subjectName);
                statement.setInt(2, courseId);
                statement.setInt(3, credits);
                statement.setString(4, semester);
            }
            
            int rowsAffected = statement.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("manage-courses.jsp#subjects");
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