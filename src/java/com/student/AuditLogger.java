package com.student;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

/**
 * Simple helper to record system actions into the audit_logs table.
 * Call AuditLogger.log(...) from any servlet after a successful
 * add / update / delete operation.
 */
public class AuditLogger {

    public static void log(String actionType, String module, String description) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            String sql = "INSERT INTO audit_logs (action_type, module, description) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, actionType);
            ps.setString(2, module);
            ps.setString(3, description);
            ps.executeUpdate();
        } catch (Exception e) {
            // Logging failure should never break the main operation
            e.printStackTrace();
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception e) { }
        }
    }
}
