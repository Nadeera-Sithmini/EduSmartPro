<%@page import="java.sql.ResultSet, java.sql.Statement, java.sql.DriverManager, java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reports & Analytics</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { 
            --bg-color: #0b111e; 
            --secondary-bg: #151c2c; 
            --cyan-color: #5df2ec; 
            --text-color: #94a3b8; 
        }
        body { margin: 0; font-family: 'Poppins', sans-serif; background: var(--bg-color); display: flex; color: white; }
        
        /* ─── SIDEBAR STYLE (EDU SMART PRO) ─── */
        .sidebar { width: 260px; height: 100vh; background: #090d16; padding: 25px 20px; position: fixed; box-sizing: border-box; }
        .sidebar-brand { display: flex; align-items: center; gap: 10px; color: var(--cyan-color); font-size: 1.3rem; font-weight: 600; margin-bottom: 40px; }
        .sidebar-brand i { font-size: 1.5rem; }
        
        .nav-list { list-style: none; padding: 0; margin: 0; }
        .nav-item { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            padding: 12px 15px; 
            color: var(--text-color); 
            text-decoration: none; 
            margin-bottom: 8px; 
            border-radius: 8px; 
            font-size: 0.95rem;
            transition: all 0.3s ease; 
        }
        .nav-item i { width: 20px; font-size: 1.1rem; }
        .nav-item:hover { color: white; background: rgba(255,255,255,0.05); }
        
        .nav-item.active { 
            background: rgba(93, 242, 236, 0.1); 
            color: var(--cyan-color); 
            font-weight: 600; 
            border-left: 4px solid var(--cyan-color);
            border-radius: 0 8px 8px 0;
            padding-left: 11px;
        }
        
        .logout-btn { color: #f87171; margin-top: auto; position: absolute; bottom: 30px; width: calc(100% - 40px); }
        .logout-btn:hover { background: rgba(248, 113, 113, 0.1); color: #f87171; }

        /* ─── MAIN CONTENT STYLE ─── */
        .main-content { margin-left: 260px; padding: 40px; width: calc(100% - 260px); box-sizing: border-box; }
        .main-title { font-size: 1.6rem; color: white; margin-bottom: 30px; display: flex; align-items: center; gap: 15px; }
        .main-title i { color: var(--cyan-color); }
        
        .card { background: var(--secondary-bg); padding: 30px; border-radius: 12px; margin-bottom: 25px; border: 1px solid rgba(255,255,255,0.03); }
        .card h3 { margin-top: 0; margin-bottom: 20px; font-weight: 400; font-size: 1.15rem; display: flex; align-items: center; gap: 10px; }

        /* ─── SUMMARY STAT CARDS ─── */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
        @media (max-width: 1100px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        .stat-card { 
            background: var(--secondary-bg); 
            border: 1px solid rgba(255,255,255,0.03); 
            border-radius: 12px; 
            padding: 24px; 
            display: flex; 
            align-items: center; 
            gap: 16px; 
        }
        .stat-icon { 
            width: 50px; height: 50px; 
            border-radius: 10px; 
            display: flex; align-items: center; justify-content: center; 
            font-size: 1.3rem; 
            background: rgba(93, 242, 236, 0.1); 
            color: var(--cyan-color); 
            flex-shrink: 0;
        }
        .stat-icon.green { background: rgba(74, 222, 128, 0.1); color: #4ade80; }
        .stat-icon.yellow { background: rgba(250, 204, 21, 0.1); color: #facc15; }
        .stat-icon.pink { background: rgba(244, 114, 182, 0.1); color: #f472b6; }
        .stat-info .stat-value { font-size: 1.5rem; font-weight: 600; color: white; line-height: 1.2; }
        .stat-info .stat-label { font-size: 0.85rem; color: var(--text-color); margin-top: 2px; }

        /* Table Style */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { color: var(--cyan-color); padding: 14px; border-bottom: 1px solid #24314b; text-align: left; font-weight: 600; font-size: 0.9rem; }
        td { padding: 14px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #e2e8f0; font-size: 0.9rem; }
        .badge { padding: 4px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }
        .badge-present { background: rgba(74, 222, 128, 0.1); color: #4ade80; }
        .badge-grade { background: rgba(93, 242, 236, 0.1); color: var(--cyan-color); }
        .empty-row td { text-align: center; color: var(--text-color); padding: 24px; }
        .table-wrap { max-height: 400px; overflow-y: auto; }

        /* ─── PRINT BUTTON ─── */
        .print-btn-wrap { display: flex; justify-content: flex-end; margin-bottom: 20px; }
        .btn-print { 
            background: var(--cyan-color); 
            color: #090d16; 
            border: none; 
            padding: 12px 22px; 
            border-radius: 8px; 
            cursor: pointer; 
            font-weight: 600; 
            font-size: 0.95rem; 
            font-family: 'Poppins', sans-serif;
            display: flex; align-items: center; gap: 10px; 
            transition: 0.3s;
        }
        .btn-print:hover { opacity: 0.9; box-shadow: 0 0 15px rgba(93, 242, 236, 0.3); }

        /* ─── PRINT MODE ─── */
        @media print {
            body { background: white; color: black; display: block; }
            .sidebar, .print-btn-wrap { display: none !important; }
            .main-content { margin-left: 0; width: 100%; padding: 10px; }
            .stat-card, .card { 
                background: white; 
                border: 1px solid #ccc; 
                box-shadow: none; 
                break-inside: avoid; 
                page-break-inside: avoid;
            }
            .stat-info .stat-value, .main-title, .card h3, th { color: #000 !important; }
            .stat-icon { background: #eee !important; color: #000 !important; }
            td { color: #000 !important; }
            .badge, .badge-present, .badge-grade { background: #eee !important; color: #000 !important; border: 1px solid #999; }
            .table-wrap { max-height: none; overflow: visible; }
            table { page-break-inside: auto; }
            tr { page-break-inside: avoid; }
        }
    </style>
</head>
<body>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
%>

<!-- ─── SIDEBAR ─── -->
<div class="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-graduation-cap"></i>
        <span>EduSmart Pro</span>
    </div>
    <div class="nav-list">
        <a href="dashboard.jsp" class="nav-item"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
        <a href="view-students.jsp" class="nav-item"><i class="fa-solid fa-user-graduate"></i> Student Registrar</a>
        <a href="manage-courses.jsp" class="nav-item"><i class="fa-solid fa-book"></i> Courses & Subjects</a>
        <a href="attendance-scanner.jsp" class="nav-item"><i class="fa-solid fa-calendar-check"></i> Attendance (QR)</a>
        <a href="manage-fees.jsp" class="nav-item"><i class="fa-solid fa-credit-card"></i> Finance & Fees</a>
        <a href="manage-exams.jsp" class="nav-item"><i class="fa-solid fa-file-invoice"></i> Exams & GPA</a>
        <a href="attendance-report.jsp" class="nav-item active"><i class="fa-solid fa-chart-line"></i> Reports (PDF/Excel)</a>
        <a href="audit-logs.jsp" class="nav-item"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a>
        
        <a href="logout.jsp" class="nav-item logout-btn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<!-- ─── MAIN CONTENT ─── -->
<div class="main-content">
    
    <div class="main-title">
        <i class="fa-solid fa-chart-line"></i> Reports & Analytics
    </div>

    <div class="print-btn-wrap">
        <button class="btn-print" onclick="window.print()">
            <i class="fa-solid fa-print"></i> Print Report
        </button>
    </div>

    <!-- ═══════════ OVERALL SUMMARY ═══════════ -->
    <div class="stats-grid">
        <%
            int totalStudents = 0, totalCourses = 0, todayAttendance = 0;
            double totalRevenue = 0.0, avgGpa = 0.0;
            try {
                Statement s1 = conn.createStatement();
                ResultSet r1 = s1.executeQuery("SELECT COUNT(*) AS cnt FROM students");
                if (r1.next()) totalStudents = r1.getInt("cnt");
            } catch (Exception e) { /* table may not exist yet */ }

            try {
                Statement s2 = conn.createStatement();
                ResultSet r2 = s2.executeQuery("SELECT COUNT(*) AS cnt FROM courses");
                if (r2.next()) totalCourses = r2.getInt("cnt");
            } catch (Exception e) { }

            try {
                Statement s3 = conn.createStatement();
                ResultSet r3 = s3.executeQuery("SELECT COUNT(*) AS cnt FROM attendance WHERE attendance_date = CURDATE()");
                if (r3.next()) todayAttendance = r3.getInt("cnt");
            } catch (Exception e) { }

            try {
                Statement s4 = conn.createStatement();
                ResultSet r4 = s4.executeQuery("SELECT COALESCE(SUM(amount),0) AS total FROM payments");
                if (r4.next()) totalRevenue = r4.getDouble("total");
            } catch (Exception e) { }

            try {
                Statement s5 = conn.createStatement();
                ResultSet r5 = s5.executeQuery("SELECT COALESCE(AVG(gpa),0) AS avgg FROM exam_marks");
                if (r5.next()) avgGpa = r5.getDouble("avgg");
            } catch (Exception e) { }
        %>
        <div class="stat-card">
            <div class="stat-icon"><i class="fa-solid fa-user-graduate"></i></div>
            <div class="stat-info">
                <div class="stat-value"><%= totalStudents %></div>
                <div class="stat-label">Total Students</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="fa-solid fa-book"></i></div>
            <div class="stat-info">
                <div class="stat-value"><%= totalCourses %></div>
                <div class="stat-label">Active Courses</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon yellow"><i class="fa-solid fa-calendar-check"></i></div>
            <div class="stat-info">
                <div class="stat-value"><%= todayAttendance %></div>
                <div class="stat-label">Present Today</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon pink"><i class="fa-solid fa-sack-dollar"></i></div>
            <div class="stat-info">
                <div class="stat-value">LKR <%= String.format("%,.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
        </div>
    </div>

    <!-- ═══════════ ATTENDANCE RECORDS ═══════════ -->
    <div class="card">
        <h3><i class="fa-solid fa-calendar-check" style="color: var(--cyan-color);"></i> Attendance Records</h3>
        <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Course</th>
                    <th>Date</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        String q1 = "SELECT s.fullname, c.course_name, a.attendance_date, a.status " +
                                    "FROM attendance a " +
                                    "JOIN students s ON a.student_id = s.id " +
                                    "JOIN courses c ON a.course_id = c.id " +
                                    "ORDER BY a.attendance_date DESC, a.id DESC LIMIT 20";
                        ResultSet rA = conn.createStatement().executeQuery(q1);
                        boolean any = false;
                        while (rA.next()) {
                            any = true;
                %>
                        <tr>
                            <td><%= rA.getString("fullname") %></td>
                            <td><%= rA.getString("course_name") %></td>
                            <td><%= rA.getDate("attendance_date") %></td>
                            <td><span class="badge badge-present"><%= rA.getString("status") %></span></td>
                        </tr>
                <%
                        }
                        if (!any) {
                %>
                        <tr class="empty-row"><td colspan="4">No attendance records found.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <tr class="empty-row"><td colspan="4">No attendance records found.</td></tr>
                <%
                    }
                %>
            </tbody>
        </table>
        </div>
    </div>

    <!-- ═══════════ FINANCE / PAYMENT HISTORY ═══════════ -->
    <div class="card">
        <h3><i class="fa-solid fa-credit-card" style="color: var(--cyan-color);"></i> Finance & Payment History</h3>
        <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Course</th>
                    <th>Amount (LKR)</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        String q2 = "SELECT s.fullname, c.course_name, p.amount, p.payment_date " +
                                    "FROM payments p " +
                                    "JOIN students s ON p.student_id = s.id " +
                                    "JOIN courses c ON s.course_id = c.id " +
                                    "ORDER BY p.id DESC LIMIT 20";
                        ResultSet rF = conn.createStatement().executeQuery(q2);
                        boolean any2 = false;
                        while (rF.next()) {
                            any2 = true;
                %>
                        <tr>
                            <td><%= rF.getString("fullname") %></td>
                            <td><%= rF.getString("course_name") %></td>
                            <td>LKR <%= String.format("%,.2f", rF.getDouble("amount")) %></td>
                            <td><%= rF.getTimestamp("payment_date") %></td>
                        </tr>
                <%
                        }
                        if (!any2) {
                %>
                        <tr class="empty-row"><td colspan="4">No payment records found.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <tr class="empty-row"><td colspan="4">No payment records found.</td></tr>
                <%
                    }
                %>
            </tbody>
        </table>
        </div>
    </div>

    <!-- ═══════════ EXAM RESULTS & GPA ═══════════ -->
    <div class="card">
        <h3><i class="fa-solid fa-file-invoice" style="color: var(--cyan-color);"></i> Exam Results & GPA</h3>
        <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Subject</th>
                    <th>Marks</th>
                    <th>Grade</th>
                    <th>GPA</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        String q3 = "SELECT s.fullname, sub.subject_name, m.marks, m.grade, m.gpa " +
                                    "FROM exam_marks m " +
                                    "JOIN students s ON m.student_id = s.id " +
                                    "JOIN subjects sub ON m.subject_id = sub.id " +
                                    "ORDER BY m.id DESC LIMIT 20";
                        ResultSet rE = conn.createStatement().executeQuery(q3);
                        boolean any3 = false;
                        while (rE.next()) {
                            any3 = true;
                %>
                        <tr>
                            <td><%= rE.getString("fullname") %></td>
                            <td><%= rE.getString("subject_name") %></td>
                            <td><%= rE.getDouble("marks") %></td>
                            <td><span class="badge badge-grade"><%= rE.getString("grade") %></span></td>
                            <td style="color: var(--cyan-color); font-weight: 600;"><%= String.format("%.2f", rE.getDouble("gpa")) %></td>
                        </tr>
                <%
                        }
                        if (!any3) {
                %>
                        <tr class="empty-row"><td colspan="5">No exam records found.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <tr class="empty-row"><td colspan="5">No exam records found.</td></tr>
                <%
                    }
                %>
            </tbody>
        </table>
        </div>
    </div>

</div>

<% if (conn != null) conn.close(); %>
</body>
</html>
