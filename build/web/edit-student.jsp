<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Student Details</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght=300;400;600&display=swap" rel="stylesheet">
</head>
<body>
    <%
        
        String studentId = request.getParameter("id");
        String fullname="", email="", phone="", dob="", course="";
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            
            String sql = "SELECT * FROM students WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, studentId);
            ResultSet rs = stmt.executeQuery();
            
            if(rs.next()) {
                fullname = rs.getString("fullname");
                email = rs.getString("email");
                phone = rs.getString("phone");
                dob = rs.getString("dob");
                course = rs.getString("course");
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    %>

    <div class="container">
        <div class="form-box">
            <h2>Edit Student Info</h2>
            <p class="subtitle">Modify the student details below</p>
            
            <form action="UpdateStudentServlet" method="POST">
                <input type="hidden" name="id" value="<%= studentId %>">

                <div class="input-group">
                    <input type="text" name="fullname" value="<%= fullname %>" required style="color:#fff;">
                </div>

                <div class="input-group">
                    <input type="email" name="email" value="<%= email %>" required style="color:#fff;">
                </div>

                <div class="input-group">
                    <input type="text" name="phone" value="<%= phone %>" required style="color:#fff;">
                </div>

                <div class="input-group">
                    <input type="date" name="dob" value="<%= dob %>" required style="color:#fff;">
                </div>

                <div class="input-group">
                    <input type="text" name="course" value="<%= course %>" required style="color:#fff;">
                </div>

                <button type="submit" class="btn-submit">Update Details</button>
                
                <p style="margin-top: 20px; font-size: 0.9rem;">
                    <a href="view-students.jsp" style="color: #66fcf1; text-decoration: none;">Cancel & Go Back</a>
                </p>
            </form>
        </div>
    </div>
</body>
</html>
