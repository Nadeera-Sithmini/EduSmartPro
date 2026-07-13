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

@WebServlet(name = "PaymentServlet", urlPatterns = {"/PaymentServlet"})
public class PaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("student_id");
        String amount = request.getParameter("amount");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            String sql = "INSERT INTO payments (student_id, amount) VALUES (?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setString(2, amount);

            int status = ps.executeUpdate();

            if(status > 0) {
                // 📝 AUDIT LOG - payment එක record කරනවා
                AuditLogger.log("ADD", "Finance & Fees", "Payment of LKR " + amount + " recorded for student ID " + studentId);

                response.sendRedirect("manage-fees.jsp?status=success");
            } else {
                response.sendRedirect("manage-fees.jsp?status=error");
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-fees.jsp?status=error");
        }
    }
}