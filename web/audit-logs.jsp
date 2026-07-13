<%@page import="java.sql.ResultSet, java.sql.Statement, java.sql.DriverManager, java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Audit Logs & Backup</title>
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
        
        .sidebar { width: 260px; height: 100vh; background: #090d16; padding: 25px 20px; position: fixed; box-sizing: border-box; }
        .sidebar-brand { display: flex; align-items: center; gap: 10px; color: var(--cyan-color); font-size: 1.3rem; font-weight: 600; margin-bottom: 40px; }
        .sidebar-brand i { font-size: 1.5rem; }
        
        .nav-list { list-style: none; padding: 0; margin: 0; }
        .nav-item { 
            display: flex; align-items: center; gap: 15px; padding: 12px 15px; 
            color: var(--text-color); text-decoration: none; margin-bottom: 8px; 
            border-radius: 8px; font-size: 0.95rem; transition: all 0.3s ease; 
        }
        .nav-item i { width: 20px; font-size: 1.1rem; }
        .nav-item:hover { color: white; background: rgba(255,255,255,0.05); }
        
        .nav-item.active { 
            background: rgba(93, 242, 236, 0.1); color: var(--cyan-color); font-weight: 600; 
            border-left: 4px solid var(--cyan-color); border-radius: 0 8px 8px 0; padding-left: 11px;
        }
        
        .logout-btn { color: #f87171; margin-top: auto; position: absolute; bottom: 30px; width: calc(100% - 40px); }
        .logout-btn:hover { background: rgba(248, 113, 113, 0.1); color: #f87171; }

        .main-content { margin-left: 260px; padding: 40px; width: calc(100% - 260px); box-sizing: border-box; }
        .main-title { font-size: 1.6rem; color: white; margin-bottom: 30px; display: flex; align-items: center; gap: 15px; }
        .main-title i { color: var(--cyan-color); }
        
        .card { background: var(--secondary-bg); padding: 30px; border-radius: 12px; margin-bottom: 25px; border: 1px solid rgba(255,255,255,0.03); }
        .card h3 { margin-top: 0; margin-bottom: 20px; font-weight: 400; font-size: 1.15rem; display: flex; align-items: center; gap: 10px; }

        /* Filter bar */
        .filter-bar { display: flex; gap: 15px; margin-bottom: 20px; flex-wrap: wrap; }
        .filter-bar select, .filter-bar input {
            padding: 10px 14px; background: #0f1524; border: 1px solid #24314b; 
            color: white; border-radius: 8px; font-family: 'Poppins', sans-serif; font-size: 0.9rem;
        }
        .filter-bar select:focus, .filter-bar input:focus { outline: none; border-color: var(--cyan-color); }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { color: var(--cyan-color); padding: 14px; border-bottom: 1px solid #24314b; text-align: left; font-weight: 600; font-size: 0.9rem; }
        td { padding: 14px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #e2e8f0; font-size: 0.9rem; }
        .empty-row td { text-align: center; color: var(--text-color); padding: 24px; }
        .table-wrap { max-height: 450px; overflow-y: auto; }

        .badge { padding: 4px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }
        .badge-add    { background: rgba(74, 222, 128, 0.1);  color: #4ade80; }
        .badge-update { background: rgba(250, 204, 21, 0.1);  color: #facc15; }
        .badge-delete { background: rgba(248, 113, 113, 0.1); color: #f87171; }
        .badge-default{ background: rgba(93, 242, 236, 0.1);  color: var(--cyan-color); }

        /* Backup section */
        .backup-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        @media (max-width: 1000px) { .backup-grid { grid-template-columns: 1fr; } }
        .backup-box {
            background: #0f1524; border: 1px solid #24314b; border-radius: 10px;
            padding: 24px; text-align: center;
        }
        .backup-box i { font-size: 1.8rem; color: var(--cyan-color); margin-bottom: 12px; }
        .backup-box h4 { margin: 8px 0; font-size: 1rem; font-weight: 600; }
        .backup-box p { color: var(--text-color); font-size: 0.85rem; margin-bottom: 18px; line-height: 1.5; }
        .backup-box button {
            background: var(--cyan-color); color: #090d16; border: none; padding: 10px 20px;
            border-radius: 8px; cursor: pointer; font-weight: 600; font-size: 0.9rem;
            font-family: 'Poppins', sans-serif; width: 100%;
        }
        .backup-box button:hover { opacity: 0.9; }
        .backup-box button.secondary { background: transparent; border: 1px solid var(--cyan-color); color: var(--cyan-color); }
        .last-backup-note { color: var(--text-color); font-size: 0.85rem; margin-top: 20px; text-align: center; }
        .coming-soon { 
            display: inline-block; background: rgba(250, 204, 21, 0.1); color: #facc15; 
            font-size: 0.7rem; padding: 2px 8px; border-radius: 5px; margin-left: 8px; vertical-align: middle;
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
        <a href="attendance-report.jsp" class="nav-item"><i class="fa-solid fa-chart-line"></i> Reports (PDF/Excel)</a>
        <a href="audit-logs.jsp" class="nav-item active"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a>
        
        <a href="logout.jsp" class="nav-item logout-btn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<!-- ─── MAIN CONTENT ─── -->
<div class="main-content">
    
    <div class="main-title">
        <i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup
    </div>

    <!-- ═══════════ AUDIT LOG TABLE ═══════════ -->
    <div class="card">
        <h3><i class="fa-solid fa-list-check" style="color: var(--cyan-color);"></i> System Activity Log</h3>

        <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Action</th>
                    <th>Module</th>
                    <th>Description</th>
                    <th>Performed By</th>
                    <th>Date & Time</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        String q = "SELECT action_type, module, description, performed_by, log_time " +
                                   "FROM audit_logs ORDER BY log_time DESC LIMIT 50";
                        ResultSet rs = conn.createStatement().executeQuery(q);
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                            String action = rs.getString("action_type");
                            String badgeClass = "badge-default";
                            if ("ADD".equalsIgnoreCase(action)) badgeClass = "badge-add";
                            else if ("UPDATE".equalsIgnoreCase(action)) badgeClass = "badge-update";
                            else if ("DELETE".equalsIgnoreCase(action)) badgeClass = "badge-delete";
                %>
                        <tr>
                            <td><span class="badge <%= badgeClass %>"><%= action %></span></td>
                            <td><%= rs.getString("module") %></td>
                            <td><%= rs.getString("description") %></td>
                            <td><%= rs.getString("performed_by") %></td>
                            <td><%= rs.getTimestamp("log_time") %></td>
                        </tr>
                <%
                        }
                        if (!any) {
                %>
                        <tr class="empty-row"><td colspan="5">No activity logged yet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <tr class="empty-row"><td colspan="5">Audit log table not found. Run create_audit_logs_table.sql first.</td></tr>
                <%
                    }
                %>
            </tbody>
        </table>
        </div>
    </div>

    <!-- ═══════════ BACKUP SECTION (UI ONLY) ═══════════ -->
    <div class="card">
        <h3><i class="fa-solid fa-database" style="color: var(--cyan-color);"></i> Database Backup <span class="coming-soon">Coming Soon</span></h3>

        <div class="backup-grid">
            <div class="backup-box">
                <i class="fa-solid fa-cloud-arrow-down"></i>
                <h4>Backup Now</h4>
                <p>Create a full snapshot of the database (students, courses, payments, exams).</p>
                <button disabled>Backup Now</button>
            </div>
            <div class="backup-box">
                <i class="fa-solid fa-file-arrow-down"></i>
                <h4>Download Latest Backup</h4>
                <p>Download the most recent backup file to your computer as a .sql file.</p>
                <button class="secondary" disabled>Download Backup</button>
            </div>
            <div class="backup-box">
                <i class="fa-solid fa-clock-rotate-left"></i>
                <h4>Restore From Backup</h4>
                <p>Upload a previous backup file to restore the database to that point.</p>
                <button class="secondary" disabled>Restore</button>
            </div>
        </div>

        <p class="last-backup-note">
            <i class="fa-solid fa-circle-info"></i>
            Backup & restore functionality will be enabled once the storage engine is configured.
        </p>
    </div>

</div>

<% if (conn != null) conn.close(); %>
</body>
</html>
