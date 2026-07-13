<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Smart Student Management</title>
    <!-- Icons වලට Font Awesome ලින්ක් එක -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght=300;400;500;600&display=swap" rel="stylesheet">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: radial-gradient(circle at center, #0f172a, #020617);
            color: #fff;
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ----------------- 🚀 SIDEBAR STYLES ----------------- */
        .sidebar {
            width: 260px;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(12px);
            border-right: 1px solid rgba(102, 252, 241, 0.1);
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            left: 0;
            top: 0;
            z-index: 100;
        }

        .sidebar-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 40px;
            padding-left: 10px;
        }

        .sidebar-brand i {
            color: #66fcf1;
            font-size: 1.5rem;
        }

        .sidebar-brand h3 {
            font-size: 1.2rem;
            font-weight: 600;
            letter-spacing: 1px;
            background: linear-gradient(to right, #66fcf1, #45f3ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .sidebar-menu {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 15px;
            color: #94a3b8;
            text-decoration: none;
            padding: 12px 15px;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .sidebar-menu a i {
            font-size: 1.1rem;
            width: 20px;
        }

        .sidebar-menu li.active a, .sidebar-menu a:hover {
            color: #66fcf1;
            background: rgba(102, 252, 241, 0.05);
            box-shadow: inset 3px 0 0 #66fcf1;
            padding-left: 18px;
        }

        .sidebar-footer {
            margin-top: auto;
        }

        .sidebar-footer a {
            color: #ef4444;
        }
        .sidebar-footer a:hover {
            background: rgba(239, 68, 68, 0.05);
            box-shadow: inset 3px 0 0 #ef4444;
            color: #ff6b6b;
        }

        /* ----------------- 🚀 MAIN CONTENT STYLES ----------------- */
        .main-content {
            margin-left: 260px; /* Sidebar එකට ඉඩ තැබීම */
            padding: 40px;
            width: calc(100% - 260px);
        }

        .dashboard-card {
            background: rgba(30, 41, 59, 0.4);
            border: 1px solid rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .header-section h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: #66fcf1;
            text-shadow: 0 0 10px rgba(102, 252, 241, 0.2);
        }

        .btn-add {
            background: rgba(102, 252, 241, 0.1);
            color: #66fcf1;
            border: 1px solid #66fcf1;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-add:hover {
            background: #66fcf1;
            color: #0b0c10;
            box-shadow: 0 0 15px rgba(102, 252, 241, 0.4);
        }

        /* Search Section */
        .search-container {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }

        .search-input {
            flex: 1;
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 12px 20px;
            border-radius: 8px;
            color: #fff;
            font-size: 0.95rem;
            transition: all 0.3s;
        }

        .search-input:focus {
            outline: none;
            border-color: #66fcf1;
            box-shadow: 0 0 10px rgba(102, 252, 241, 0.1);
        }

        .btn-search {
            background: #66fcf1;
            color: #0b0c10;
            border: none;
            padding: 0 30px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-search:hover {
            box-shadow: 0 0 15px rgba(102, 252, 241, 0.4);
            transform: translateY(-1px);
        }

        /* Table Styles */
        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            background: rgba(102, 252, 241, 0.05);
            color: #66fcf1;
            padding: 15px;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-bottom: 1px solid rgba(102, 252, 241, 0.2);
        }

        td {
            padding: 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 0.9rem;
            color: #cbd5e1;
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.02);
            color: #fff;
        }

        /* Action Buttons */
        .btn-action {
            padding: 6px 14px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
        }

        .btn-edit {
            background: rgba(56, 189, 248, 0.1);
            color: #38bdf8;
            border: 1px solid #38bdf8;
            margin-right: 8px;
        }

        .btn-edit:hover {
            background: #38bdf8;
            color: #0f172a;
        }

        .btn-delete {
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
            border: 1px solid #ef4444;
        }

        .btn-delete:hover {
            background: #ef4444;
            color: #fff;
        }
        
        /* --- 📊 DASHBOARD CARDS STYLES --- */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: rgba(30, 41, 59, 0.6);
            border: 1px solid rgba(102, 252, 241, 0.1);
            padding: 20px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            border-color: #66fcf1;
            box-shadow: 0 5px 15px rgba(102, 252, 241, 0.1);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .icon-blue { background: rgba(56, 189, 248, 0.1); color: #38bdf8; }
        .icon-green { background: rgba(34, 197, 94, 0.1); color: #22c55e; }
        .icon-red { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

        .stat-info h4 {
            font-size: 0.85rem;
            color: #94a3b8;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-info p {
            font-size: 1.8rem;
            font-weight: 600;
            color: #fff;
            margin-top: 5px;
        }
    </style>
</head>
<body>

    <!-- 🛠️ UPDATED SIDEBAR KOTASA -->
    <div class="sidebar">
        <div class="sidebar-brand">
            <i class="fa-solid fa-graduation-cap"></i>
            <h3>EduSmart Pro</h3>
        </div>
        <ul class="sidebar-menu">
            <li class="active">
                <a href="view-students.jsp"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
            </li>
            
            <!-- 1. Student Management -->
            <li>
                <a href="index.html"><i class="fa-solid fa-user-gear"></i> Student Registrar</a>
            </li>
            
            <!-- 2. Course & Subjects -->
            <li>
                <a href="manage-courses.jsp"><i class="fa-solid fa-book-open"></i> Courses & Subjects</a>
            </li>
            
            <!-- 3. Attendance (ලින්ක් එක අප්ඩේට් කරන ලදි) -->
            <li>
                <a href="attendance-scanner.jsp"><i class="fa-solid fa-calendar-check"></i> Attendance (QR)</a>
            </li>
            
            <!-- 4. Fee Management -->
            <li>
                <a href="manage-fees.jsp"><i class="fa-solid fa-credit-card"></i> Finance & Fees</a>
            </li>
            
            <!-- 5. Exams & GPA -->
            <li>
                <a href="manage-exams.jsp"><i class="fa-solid fa-file-invoice"></i> Exams & GPA</a>
            </li>

            <!-- 6. Reports & Analytics -->
            <li>
                <a href="attendance-report.jsp"><i class="fa-solid fa-chart-line"></i> Reports (PDF/Excel)</a>
            </li>
            
            <!-- 7. System Security & Logs -->
            <li>
                <a href="#"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a>
            </li>
            
            <li class="sidebar-footer">
                <a href="#"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </li>
        </ul>
    </div>

    <!-- 🛠️ MAIN PANEL KOTASA -->
    <div class="main-content">
        <div class="dashboard-card">
            
            <div class="header-section">
                <h2>Admin Dashboard</h2>
                <a href="index.html" class="btn-add">
                    <i class="fa-solid fa-plus"></i> Add New Student
                </a>
            </div>
            <!-- 📊 DASHBOARD OVERVIEW CARDS -->
            <%
                int totalStudents = 0;
                int activeStudents = 0;
                int inactiveStudents = 0;
                
                java.sql.Connection cardConn = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    cardConn = java.sql.DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
                    
                    // 1. Total Students ගණන ගන්නවා
                    java.sql.Statement stTotal = cardConn.createStatement();
                    java.sql.ResultSet rsTotal = stTotal.executeQuery("SELECT COUNT(*) FROM students");
                    if(rsTotal.next()) totalStudents = rsTotal.getInt(1);
                    
                    // 2. Active Students ගණන ගන්නවා
                    java.sql.Statement stActive = cardConn.createStatement();
                    java.sql.ResultSet rsActive = stActive.executeQuery("SELECT COUNT(*) FROM students WHERE status='Active'");
                    if(rsActive.next()) activeStudents = rsActive.getInt(1);
                    
                    // 3. Inactive Students ගණන ගන්නවා
                    java.sql.Statement stInactive = cardConn.createStatement();
                    java.sql.ResultSet rsInactive = stInactive.executeQuery("SELECT COUNT(*) FROM students WHERE status='Inactive'");
                    if(rsInactive.next()) inactiveStudents = rsInactive.getInt(1);
                    
                } catch(Exception e) {
                    // එරර් එකක් ආවොත් ප්‍රින්ට් නොකර ඉන්නවා
                } finally {
                    if(cardConn != null) cardConn.close();
                }
            %>
            <div class="stats-container">
                <!-- Total Students Card -->
                <div class="stat-card">
                    <div class="stat-icon icon-blue">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    <div class="stat-info">
                        <h4>Total Students</h4>
                        <p><%= totalStudents %></p>
                    </div>
                </div>

                <!-- Active Students Card -->
                <div class="stat-card">
                    <div class="stat-icon icon-green">
                        <i class="fa-solid fa-user-check"></i>
                    </div>
                    <div class="stat-info">
                        <h4>Active Students</h4>
                        <p><%= activeStudents %></p>
                    </div>
                </div>

                <!-- Inactive Students Card -->
                <div class="stat-card">
                    <div class="stat-icon icon-red">
                        <i class="fa-solid fa-user-slash"></i>
                    </div>
                    <div class="stat-info">
                        <h4>Inactive Students</h4>
                        <p><%= inactiveStudents %></p>
                    </div>
                </div>
            </div>

            <!-- Search Form -->
            <!-- 🔍 ADVANCED FILTERS FORM -->
            <form action="view-students.jsp" method="GET">
                <div class="search-container" style="display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 30px;">
                    <!-- Text Search -->
                    <input type="text" name="search" class="search-input" style="flex: 2; min-width: 200px;" placeholder="Search by Name or Email..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    
                    <!-- Course Filter -->
                    <select name="filterCourse" class="search-input" style="flex: 1; min-width: 150px; background: rgba(15, 23, 42, 0.8); color: #fff;">
                        <option value="">All Courses</option>
                        <option value="se" <%= "se".equals(request.getParameter("filterCourse")) ? "selected" : "" %>>Software Engineering</option>
                        <option value="cs" <%= "cs".equals(request.getParameter("filterCourse")) ? "selected" : "" %>>Computer Science</option>
                        <option value="ds" <%= "ds".equals(request.getParameter("filterCourse")) ? "selected" : "" %>>Data Science</option>
                    </select>

                    <!-- Gender Filter -->
                    <select name="filterGender" class="search-input" style="flex: 1; min-width: 130px; background: rgba(15, 23, 42, 0.8); color: #fff;">
                        <option value="">All Genders</option>
                        <option value="Male" <%= "Male".equals(request.getParameter("filterGender")) ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= "Female".equals(request.getParameter("filterGender")) ? "selected" : "" %>>Female</option>
                    </select>

                    <!-- Status Filter -->
                    <select name="filterStatus" class="search-input" style="flex: 1; min-width: 130px; background: rgba(15, 23, 42, 0.8); color: #fff;">
                        <option value="">All Status</option>
                        <option value="Active" <%= "Active".equals(request.getParameter("filterStatus")) ? "selected" : "" %>>Active</option>
                        <option value="Inactive" <%= "Inactive".equals(request.getParameter("filterStatus")) ? "selected" : "" %>>Inactive</option>
                    </select>

                    <button type="submit" class="btn-search" style="padding: 0 25px;">Filter</button>
                    <a href="view-students.jsp" style="background: rgba(255,255,255,0.05); color: #fff; border: 1px solid rgba(255,255,255,0.1); padding: 12px 20px; border-radius: 8px; text-decoration: none; font-size: 0.95rem; display: flex; align-items: center; justify-content: center;">Reset</a>
                </div>
            </form>

            <!-- 📊 STUDENT LIST TABLE -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Photo</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Gender</th>
                            <th>Course</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
                                
                                String search = request.getParameter("search");
                                String filterCourse = request.getParameter("filterCourse");
                                String filterGender = request.getParameter("filterGender");
                                String filterStatus = request.getParameter("filterStatus");
                                
                                // Dynamic SQL Query එක හදනවා (1=1 දාන්නේ ඊළඟට AND කෑලි ලේසියෙන් එකතු කරන්න)
                                String sql = "SELECT * FROM students WHERE 1=1";
                                
                                if (search != null && !search.trim().isEmpty()) {
                                    sql += " AND (fullname LIKE ? OR email LIKE ?)";
                                }
                                if (filterCourse != null && !filterCourse.trim().isEmpty()) {
                                    sql += " AND course = ?";
                                }
                                if (filterGender != null && !filterGender.trim().isEmpty()) {
                                    sql += " AND gender = ?";
                                }
                                if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                                    sql += " AND status = ?";
                                }
                                
                                PreparedStatement pstmt = conn.prepareStatement(sql);
                                int paramIndex = 1;
                                
                                // Parameters ටික පිළිවෙලට Set කරනවා
                                if (search != null && !search.trim().isEmpty()) {
                                    pstmt.setString(paramIndex++, "%" + search + "%");
                                    pstmt.setString(paramIndex++, "%" + search + "%");
                                }
                                if (filterCourse != null && !filterCourse.trim().isEmpty()) {
                                    pstmt.setString(paramIndex++, filterCourse);
                                }
                                if (filterGender != null && !filterGender.trim().isEmpty()) {
                                    pstmt.setString(paramIndex++, filterGender);
                                }
                                if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                                    pstmt.setString(paramIndex++, filterStatus);
                                }
                                
                                ResultSet rs = pstmt.executeQuery();
                                boolean hasData = false;
                                
                                while(rs.next()) {
                                    hasData = true;
                                    String statusColor = "Active".equals(rs.getString("status")) ? "#22c55e" : "#ef4444";
                        %>
                        <tr>
                            <td><%= rs.getString("student_id") != null ? rs.getString("student_id") : rs.getInt("id") %></td>
                            <td>
    
    <img src="<%= (rs.getString("photo_path") != null && !rs.getString("photo_path").trim().isEmpty()) ? rs.getString("photo_path") : "images/default-avatar.png" %>" 
         style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover; border: 2px solid #66fcf1; box-shadow: 0 0 8px rgba(102,252,241,0.3);">
</td>
                            <td><%= rs.getString("fullname") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("phone") %></td>
                            <td><%= rs.getString("gender") %></td>
                            <td style="color: #66fcf1; font-weight: 500; text-transform: uppercase;"><%= rs.getString("course") %></td>
                            <td>
                                <span style="background: <%= statusColor + "15" %>; color: <%= statusColor %>; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; border: 1px solid <%= statusColor + "30" %>;">
                                    <%= rs.getString("status") %>
                                </span>
                            </td>
                            <td>
                                <a href="edit-student.jsp?id=<%= rs.getInt("id") %>" class="btn-action btn-edit">
                                    <i class="fa-solid fa-pen-to-square"></i> Edit
                                </a>
                                <a href="DeleteStudentServlet?id=<%= rs.getInt("id") %>" class="btn-action btn-delete" onclick="return confirm('Are you sure you want to delete this student?');">
                                    <i class="fa-solid fa-trash"></i> Delete
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if(!hasData) {
                                    out.println("<tr><td colspan='8' style='text-align:center; color:#94a3b8; padding:30px;'>No students found matching the filters.</td></tr>");
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if(conn != null) conn.close();
                            }
                        %>
                    </tbody>
                </table>
            </div>

        </div>
    </div>

</body>
</html>