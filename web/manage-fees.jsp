<%@page import="java.sql.ResultSet, java.sql.Statement, java.sql.DriverManager, java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Finance & Fee Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { 
            --bg-color: #0b111e; 
            --secondary-bg: #151c2c; 
            --cyan-color: #5df2ec; 
            --text-color: #94a3b8; 
            --success: #00f2fe;
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
        
        /* Active Sidebar Item Style */
        .nav-item.active { 
            background: rgba(93, 242, 236, 0.1); 
            color: var(--cyan-color); 
            font-weight: 600; 
            border-left: 4px solid var(--cyan-color);
            border-radius: 0 8px 8px 0;
            padding-left: 11px; /* Border එක නිසා balance කරන්න */
        }
        
        .logout-btn { color: #f87171; margin-top: auto; position: absolute; bottom: 30px; width: calc(100% - 40px); }
        .logout-btn:hover { background: rgba(248, 113, 113, 0.1); color: #f87171; }

        /* ─── MAIN CONTENT STYLE ─── */
        .main-content { margin-left: 260px; padding: 40px; width: calc(100% - 260px); box-sizing: border-box; }
        .main-title { font-size: 1.6rem; color: white; margin-bottom: 30px; display: flex; align-items: center; gap: 15px; }
        .main-title i { color: var(--cyan-color); }
        
        .card { background: var(--secondary-bg); padding: 30px; border-radius: 12px; margin-bottom: 25px; border: 1px solid rgba(255,255,255,0.03); }
        .card h3 { margin-top: 0; margin-bottom: 20px; font-weight: 400; font-size: 1.15rem; display: flex; align-items: center; gap: 10px; }
        
        /* Forms & Inputs */
        .form-group { margin-bottom: 20px; }
        .form-label { display: block; margin-bottom: 8px; color: var(--text-color); font-size: 0.9rem; }
        .form-control { width: 100%; padding: 12px; background: #0f1524; border: 1px solid #24314b; color: white; border-radius: 8px; font-family: 'Poppins', sans-serif; box-sizing: border-box; font-size: 0.95rem; transition: 0.3s; }
        .form-control:focus { outline: none; border-color: var(--cyan-color); }
        
        .btn-prime { background: var(--cyan-color); color: #090d16; padding: 14px; border: none; border-radius: 8px; cursor: pointer; width: 100%; font-weight: 600; font-size: 1rem; transition: 0.3s; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .btn-prime:hover { opacity: 0.9; box-shadow: 0 0 15px rgba(93, 242, 236, 0.3); }
        
        /* Table Style */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { color: var(--cyan-color); padding: 14px; border-bottom: 1px solid #24314b; text-align: left; font-weight: 600; font-size: 0.95rem; }
        td { padding: 14px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #e2e8f0; font-size: 0.95rem; }
    </style>
</head>
<body>

<!-- ─── SIDEBAR (EDU SMART PRO STYLE) ─── -->
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
        <a href="manage-fees.jsp" class="nav-item active"><i class="fa-solid fa-credit-card"></i> Finance & Fees</a>
        <a href="manage-exams.jsp" class="nav-item"><i class="fa-solid fa-file-invoice"></i> Exams & GPA</a>
        <a href="attendance-report.jsp" class="nav-item"><i class="fa-solid fa-chart-line"></i> Reports (PDF/Excel)</a>
        <a href="audit-logs.jsp" class="nav-item"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a>
        
        <a href="logout.jsp" class="nav-item logout-btn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<!-- ─── MAIN CONTENT ─── -->
<div class="main-content">
    
    <div class="main-title">
        <i class="fa-solid fa-credit-card"></i> Fee Management System
    </div>

    <div class="card">
        <h3><i class="fa-solid fa-circle-plus" style="color: var(--cyan-color);"></i> Record New Payment</h3>
        <form action="PaymentServlet" method="POST">
            <div class="form-group">
                <label class="form-label">Select Student</label>
                <select name="student_id" class="form-control" required>
                    <option value="">-- Select Student --</option>
                    <% 
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
                            Statement st = conn.createStatement();
                            ResultSet rs = st.executeQuery("SELECT id, fullname, student_id FROM students ORDER BY fullname");
                            while(rs.next()) {
                    %>
                                <option value="<%= rs.getInt("id") %>"><%= rs.getString("fullname") %> (<%= rs.getString("student_id") %>)</option>
                    <% 
                            }
                            conn.close();
                        } catch(Exception e) { e.printStackTrace(); }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label">Amount</label>
                <input type="number" step="0.01" name="amount" class="form-control" placeholder="Amount Paid (LKR)" required>
            </div>
            
            <button type="submit" class="btn-prime"><i class="fa-solid fa-check"></i> Submit Payment</button>
        </form>
    </div>

    <div class="card">
        <h3>Recent Transactions</h3>
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
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
                        // Note: joins directly to students.course (text code like "se") since
                        // courses table has no matching code column to join on reliably.
                        String query = "SELECT p.amount, p.payment_date, s.fullname, s.course " +
                                        "FROM payments p " +
                                        "JOIN students s ON p.student_id = s.id " +
                                        "ORDER BY p.id DESC LIMIT 5";
                        ResultSet rsT = conn.createStatement().executeQuery(query);
                        boolean hasRows = false;
                        while(rsT.next()) {
                            hasRows = true;
                %>
                        <tr>
                            <td><%= rsT.getString("fullname") %></td>
                            <td><%= rsT.getString("course") %></td>
                            <td>LKR <%= String.format("%.2f", rsT.getDouble("amount")) %></td>
                            <td><%= rsT.getTimestamp("payment_date") %></td>
                        </tr>
                <% 
                        }
                        if (!hasRows) {
                %>
                        <tr><td colspan="4" style="text-align:center; color:var(--text-color);">No payments recorded yet.</td></tr>
                <%
                        }
                        conn.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                %>
                        <tr><td colspan="4" style="text-align:center; color:#ef4444;">DB Error: <%= e.getMessage() %></td></tr>
                <%  }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
