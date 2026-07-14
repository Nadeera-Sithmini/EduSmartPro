package com.student;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ExamServlet")
public class ExamServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("student_id");
        String subjectId = request.getParameter("subject_id");
        double marks = Double.parseDouble(request.getParameter("marks"));

        String grade = "";
        double gpa = 0.0;

        // Automatic grade and GPA calculation
        if (marks >= 75) {
            grade = "A";
            gpa = 4.0;
        } else if (marks >= 65) {
            grade = "B";
            gpa = 3.0;
        } else if (marks >= 55) {
            grade = "C";
            gpa = 2.0;
        } else if (marks >= 45) {
            grade = "S";
            gpa = 1.0;
        } else {
            grade = "F";
            gpa = 0.0;
        }
        try {
            // DB Connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            // Insert Query
            String sql = "INSERT INTO exam_marks (student_id, subject_id, marks, grade, gpa) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setString(2, subjectId);
            ps.setDouble(3, marks);
            ps.setString(4, grade);
            ps.setDouble(5, gpa);

            int status = ps.executeUpdate();

            if(status > 0) {
                // Audit log - record the marks entry
                AuditLogger.log("ADD", "Exams & GPA", "Marks added for student ID " + studentId + " - Subject ID " + subjectId + " (" + marks + " marks, Grade " + grade + ")");

                // Redirect back to the page on success
                response.sendRedirect("manage-exams.jsp?status=success");
            } else {
                response.sendRedirect("manage-exams.jsp?status=error");
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-exams.jsp?status=error");
        }
    }
}
