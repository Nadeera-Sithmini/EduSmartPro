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

@WebServlet(name = "DeleteStudentServlet", urlPatterns = {"/DeleteStudentServlet"})
public class DeleteStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Dashboard එකෙන් එවපු ශිෂ්‍යයාගේ ID එක ගන්නවා
        String studentId = request.getParameter("id");
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");

            // 📝 Delete කරන්න කලින්, audit log එකට දාන්න student ගේ නම ලබාගන්නවා
            String studentName = "ID " + studentId;
            String nameQuery = "SELECT fullname FROM students WHERE id = ?";
            PreparedStatement nameStmt = conn.prepareStatement(nameQuery);
            nameStmt.setString(1, studentId);
            ResultSet nameRs = nameStmt.executeQuery();
            if (nameRs.next()) {
                studentName = nameRs.getString("fullname");
            }

            // අදාළ ID එක තියෙන ශිෂ්‍යයාව ඩේටාබේස් එකෙන් අයින් කරන Query එක
            String sql = "DELETE FROM students WHERE id = ?";
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.setString(1, studentId);

            int rowsDeleted = statement.executeUpdate();
            if (rowsDeleted > 0) {
                // 📝 AUDIT LOG - student deletion එක record කරනවා
                AuditLogger.log("DELETE", "Student Registrar", "Student deleted: " + studentName + " (ID: " + studentId + ")");

                // Delete වුණාට පස්සේ alert එකක් දාලා ආයේ Dashboard එකටම යවනවා
                out.println("<script type='text/javascript'>");
                out.println("alert('Student deleted successfully!');");
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