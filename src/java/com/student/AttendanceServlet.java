package com.student;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AttendanceServlet", urlPatterns = {"/AttendanceServlet"})
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentCode = request.getParameter("student_id");   // e.g. "STU001" (from QR or dropdown)
        String courseIdParam = request.getParameter("course_id");

        if (studentCode == null || courseIdParam == null || studentCode.trim().isEmpty() || courseIdParam.trim().isEmpty()) {
            response.sendRedirect("attendance-scanner.jsp?status=invalid");
            return;
        }

        Connection conn = null;
        try {
            int courseId = Integer.parseInt(courseIdParam.trim());
            String today = LocalDate.now().toString(); // අද දවස (YYYY-MM-DD)

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");

            // 0. student_id text code එකෙන් (STU001) students table එකේ actual numeric id එක සොයාගන්නවා
            String lookupSql = "SELECT id FROM students WHERE student_id = ?";
            PreparedStatement lookupStmt = conn.prepareStatement(lookupSql);
            lookupStmt.setString(1, studentCode.trim());
            ResultSet lookupRs = lookupStmt.executeQuery();

            if (!lookupRs.next()) {
                // Student code එකම database එකේ නෑ
                response.sendRedirect("attendance-scanner.jsp?status=invalid");
                return;
            }
            int studentId = lookupRs.getInt("id");

            // 1. අද දවසේ මේ කෝස් එකට මේ ළමයා දැනටමත් ඇටෙන්ඩන්ස් මාක් කරලාද කියලා චෙක් කරනවා
            String checkSql = "SELECT id FROM attendance WHERE student_id = ? AND course_id = ? AND attendance_date = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, studentId);
            checkStmt.setInt(2, courseId);
            checkStmt.setString(3, today);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                response.sendRedirect("attendance-scanner.jsp?status=duplicate");
            } else {
                // 2. නැත්නම් අලුතින් ඇටෙන්ඩන්ස් රෙකෝඩ් එකක් ඉන්සර්ට් කරනවා
                String insertSql = "INSERT INTO attendance (student_id, course_id, attendance_date, status) VALUES (?, ?, ?, 'Present')";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, studentId);
                insertStmt.setInt(2, courseId);
                insertStmt.setString(3, today);

                int rows = insertStmt.executeUpdate();
                if (rows > 0) {
                    // 📝 AUDIT LOG - attendance mark එක record කරනවා
                    AuditLogger.log("ADD", "Attendance (QR)", "Attendance marked as Present for student code " + studentCode + " (course ID: " + courseId + ")");

                    response.sendRedirect("attendance-scanner.jsp?status=success");
                } else {
                    response.sendRedirect("attendance-scanner.jsp?status=invalid");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("attendance-scanner.jsp?status=invalid");
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}