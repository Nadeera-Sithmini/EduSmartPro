package com.student;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 1. Form Data ලබා ගැනීම
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String course = request.getParameter("course");
        String status = request.getParameter("status");
        String password = request.getParameter("password");

        // 2. 📸 PHOTO UPLOAD HANDLING
        Part part = request.getPart("photo");
        String fileName = extractFileName(part);

        // පින්තූරය සේව් වන ෆෝල්ඩර් එක (uploads ෆෝල්ඩරය)
        String savePath = request.getServletContext().getRealPath("") + File.separator + "uploads";
        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        // එකම නම තියෙන ෆොටෝ පැටලෙන්නේ නැති වෙන්න unique නමක් දෙනවා
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
        part.write(savePath + File.separator + uniqueFileName);

        String dbPhotoPath = "uploads/" + uniqueFileName;

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");

            // 3. STUDENT ID AUTO GENERATION
            String studentId = "STU001";
            String idQuery = "SELECT student_id FROM students ORDER BY id DESC LIMIT 1";
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(idQuery);

            if (rs.next()) {
                String lastId = rs.getString("student_id");
                int idNum = Integer.parseInt(lastId.substring(3));
                idNum++;
                studentId = String.format("STU%03d", idNum);
            }

            // 4. INSERT Query (photo_path එකත් එක්ක)
            String sql = "INSERT INTO students (student_id, fullname, email, phone, dob, gender, course, status, password, photo_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.setString(1, studentId);
            statement.setString(2, fullname);
            statement.setString(3, email);
            statement.setString(4, phone);
            statement.setString(5, dob);
            statement.setString(6, gender);
            statement.setString(7, course);
            statement.setString(8, status);
            statement.setString(9, password);
            statement.setString(10, dbPhotoPath);

            int rowsInserted = statement.executeUpdate();
            if (rowsInserted > 0) {
                // 📝 AUDIT LOG - student registration එක record කරනවා
                AuditLogger.log("ADD", "Student Registrar", "New student registered: " + fullname + " (" + studentId + ")");

                // 📊 සාර්ථකව ඇතුළත් වූ පසු කෙලින්ම Dashboard (view-students.jsp) එකට රීඩිරෙක්ට් කරයි
                response.sendRedirect("view-students.jsp");
            }
        } catch (Exception e) {
            out.println("<body style='background:#0b0c10; color:#ff4d4d; font-family:sans-serif; padding: 20px;'>");
            out.println("<h3>Error: " + e.getMessage() + "</h3>");
            out.println("</body>");
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}