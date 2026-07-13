<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course & Subject Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-color: #0b0c10;
            --secondary-bg: #1f2833;
            --cyan-color: #66fcf1;
            --dark-cyan: #45a29e;
            --text-color: #c5c6c7;
            --white: #ffffff;
            --success: #2ecc71;
            --sidebar-width: 260px;
        }

        body {
            margin: 0;
            padding: 0;
            background-color: var(--bg-color);
            color: var(--white);
            font-family: 'Poppins', sans-serif;
            display: flex;
        }

        /* --- SIDEBAR STYLE --- */
        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            background: #0f141c;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            box-sizing: border-box;
            border-right: 1px solid rgba(255,255,255,0.05);
        }

        .logo-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 0 25px 30px 25px;
        }

        .logo-section i {
            font-size: 2rem;
            color: var(--cyan-color);
        }

        .logo-section h2 {
            margin: 0;
            font-size: 1.35rem;
            font-weight: 600;
            color: var(--cyan-color);
        }

        .menu-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .menu-item a {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 14px 25px;
            color: var(--text-color);
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 400;
            transition: 0.3s ease;
            position: relative;
        }

        .menu-item a i {
            font-size: 1.1rem;
            width: 20px;
        }

        /* Active Menu Item styling */
        .menu-item.active a {
            color: var(--cyan-color);
            background: rgba(102, 252, 241, 0.05);
        }

        .menu-item.active a::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: var(--cyan-color);
            border-radius: 0 4px 4px 0;
            box-shadow: 0 0 10px var(--cyan-color);
        }

        .menu-item a:hover {
            color: var(--white);
            background: rgba(255, 255, 255, 0.02);
        }

        .menu-item.logout {
            margin-top: auto;
        }

        .menu-item.logout a {
            color: #ff4d4d;
        }
        .menu-item.logout a:hover {
            background: rgba(255, 77, 77, 0.05);
        }

        /* --- MAIN CONTENT AREA --- */
        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: 30px;
            min-height: 100vh;
            box-sizing: border-box;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header-title {
            color: var(--cyan-color);
            margin-bottom: 30px;
            border-bottom: 2px solid var(--secondary-bg);
            padding-bottom: 15px;
        }

        .header-title h2 {
            margin: 0;
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        /* --- INNER INTERNAL TABS --- */
        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .tab-btn {
            background: var(--secondary-bg);
            color: var(--text-color);
            border: 1px solid rgba(102,252,241,0.2);
            padding: 10px 20px;
            cursor: pointer;
            border-radius: 5px;
            font-weight: 600;
            transition: 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .tab-btn.active, .tab-btn:hover {
            background: var(--cyan-color);
            color: var(--bg-color);
            box-shadow: 0 0 10px rgba(102,252,241,0.4);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 30px;
        }

        @media (max-width: 1024px) {
            .tab-content.active {
                grid-template-columns: 1fr;
            }
        }

        .card {
            background: var(--secondary-bg);
            padding: 25px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            height: fit-content;
        }

        .card h3 {
            color: var(--cyan-color);
            margin-top: 0;
            margin-bottom: 20px;
            font-size: 1.2rem;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            color: var(--text-color);
            font-size: 0.85rem;
            margin-bottom: 5px;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 5px;
            color: var(--white);
            box-sizing: border-box;
        }

        select.form-control option {
            background: var(--secondary-bg);
            color: var(--white);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--cyan-color);
        }

        .row {
            display: flex;
            gap: 10px;
        }

        .btn-prime {
            background: var(--cyan-color);
            color: var(--bg-color);
            border: none;
            padding: 12px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
            width: 100%;
            margin-top: 10px;
            transition: 0.3s;
        }

        .btn-prime:hover {
            background: var(--dark-cyan);
        }

        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: transparent;
        }

        th {
            background: rgba(102,252,241,0.1);
            color: var(--cyan-color);
            text-align: left;
            padding: 12px;
            font-size: 0.9rem;
            border-bottom: 2px solid rgba(102,252,241,0.2);
        }

        td {
            padding: 12px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            font-size: 0.85rem;
            color: var(--text-color);
        }

        .badge {
            background: rgba(102,252,241,0.2);
            color: var(--cyan-color);
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
        }

        .action-btns {
            display: flex;
            gap: 5px;
        }

        .btn-edit {
            background: rgba(102,252,241,0.1);
            color: var(--cyan-color);
            border: 1px solid var(--cyan-color);
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            display: inline-block;
        }

        .btn-delete {
            background: rgba(255,77,77,0.1);
            color: #ff4d4d;
            border: 1px solid #ff4d4d;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
            display: inline-block;
        }
    </style>
</head>
<body>

<!-- 🌐 EduSmart Pro SIDEBAR -->
<div class="sidebar">
    <div class="logo-section">
        <i class="fa-solid fa-graduation-cap"></i>
        <h2>EduSmart Pro</h2>
    </div>
    <ul class="menu-list">
        <li class="menu-item"><a href="dashboard.jsp"><i class="fa-solid fa-chart-pie"></i> Dashboard</a></li>
        <li class="menu-item"><a href="student-registration.jsp"><i class="fa-solid fa-user-gear"></i> Student Registrar</a></li>
        <li class="menu-item active"><a href="manage-courses.jsp"><i class="fa-solid fa-book"></i> Courses & Subjects</a></li>
        <li class="menu-item"><a href="attendance-scanner.jsp"><i class="fa-solid fa-calendar-days"></i> Attendance (QR)</a></li>
        <li class="menu-item"><a href="finance.jsp"><i class="fa-solid fa-credit-card"></i> Finance & Fees</a></li>
        <li class="menu-item"><a href="exams.jsp"><i class="fa-solid fa-file-invoice"></i> Exams & GPA</a></li>
        <li class="menu-item"><a href="attendance-report.jsp"><i class="fa-solid fa-chart-line"></i> Reports (PDF/Excel)</a></li>
        <li class="menu-item"><a href="audit.jsp"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a></li>
        <li class="menu-item logout"><a href="logout.jsp"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
    </ul>
</div>

<!-- 🚀 MAIN CONTENT AREA -->
<div class="main-content">
    <%
        // ඩේටාබේස් කනෙක්ෂන් එක ආරම්භ කිරීම
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");

        // --- Course Edit Mode ඩේටා ඇදීම ---
        String editCourseId = request.getParameter("editCourseId");
        String cName = request.getParameter("cName") != null ? request.getParameter("cName") : "";
        String cFee = request.getParameter("cFee") != null ? request.getParameter("cFee") : "";
        String duration = request.getParameter("duration") != null ? request.getParameter("duration") : "";
        String capacity = request.getParameter("capacity") != null ? request.getParameter("capacity") : "";
        String prereq = request.getParameter("prereq") != null ? request.getParameter("prereq") : "";
        boolean isCourseEdit = (editCourseId != null);

        // --- Subject Edit Mode ඩේටා ඇදීම ---
        String editSubId = request.getParameter("editSubId");
        String subName = request.getParameter("subName") != null ? request.getParameter("subName") : "";
        String assignedCourseId = request.getParameter("courseId") != null ? request.getParameter("courseId") : "";
        String credits = request.getParameter("credits") != null ? request.getParameter("credits") : "";
        String semester = request.getParameter("semester") != null ? request.getParameter("semester") : "";
        boolean isSubjectEdit = (editSubId != null);
    %>

    <div class="container">
        <div class="header-title">
            <h2><i class="fa-solid fa-book-bookmark"></i> Academic Management</h2>
        </div>

        <!-- 📑 INTERNAL TABS -->
        <div class="tabs">
            <button id="btn-courses" class="tab-btn active" onclick="switchTab('courses')"><i class="fa-solid fa-book"></i> Course Management</button>
            <button id="btn-subjects" class="tab-btn" onclick="switchTab('subjects')"><i class="fa-solid fa-book-open"></i> Subject Management</button>
        </div>

        <!-- 🚀 SECTION 1: COURSE MANAGEMENT -->
        <div id="courses" class="tab-content active">
            <!-- Add / Edit Course Form -->
            <div class="card">
                <h3><%= isCourseEdit ? "Edit Course" : "Add New Course" %></h3>
                <form action="CourseServlet" method="POST">
                    
                    <% if(isCourseEdit) { %>
                        <input type="hidden" name="course_id" value="<%= editCourseId %>">
                    <% } %>

                    <div class="form-group">
    <label>Course Name</label>
    <select name="course_name" class="form-control" required>
        <option value="" disabled <%= cName.isEmpty() ? "selected" : "" %>>-- Select Course Name --</option>
        <option value="Programming Fundamentals" <%= "Programming Fundamentals".equals(cName) ? "selected" : "" %>>Programming Fundamentals</option>
        <option value="Database Systems" <%= "Database Systems".equals(cName) ? "selected" : "" %>>Database Systems</option>
        <option value="Web Development" <%= "Web Development".equals(cName) ? "selected" : "" %>>Web Development</option>
        <option value="Data Structures &amp; Algorithms" <%= "Data Structures & Algorithms".equals(cName) ? "selected" : "" %>>Data Structures &amp; Algorithms</option>
        <option value="Software Engineering Principles" <%= "Software Engineering Principles".equals(cName) ? "selected" : "" %>>Software Engineering Principles</option>
        <option value="Object Oriented Programming" <%= "Object Oriented Programming".equals(cName) ? "selected" : "" %>>Object Oriented Programming</option>
        <option value="Mathematics for Computing" <%= "Mathematics for Computing".equals(cName) ? "selected" : "" %>>Mathematics for Computing</option>
        <option value="Operating Systems" <%= "Operating Systems".equals(cName) ? "selected" : "" %>>Operating Systems</option>
        <option value="Computer Networks" <%= "Computer Networks".equals(cName) ? "selected" : "" %>>Computer Networks</option>
        <option value="Mobile App Development" <%= "Mobile App Development".equals(cName) ? "selected" : "" %>>Mobile App Development</option>
        <option value="Machine Learning Fundamentals" <%= "Machine Learning Fundamentals".equals(cName) ? "selected" : "" %>>Machine Learning Fundamentals</option>
        <option value="Software Project Management" <%= "Software Project Management".equals(cName) ? "selected" : "" %>>Software Project Management</option>
        <option value="Cloud Computing" <%= "Cloud Computing".equals(cName) ? "selected" : "" %>>Cloud Computing</option>
    </select>
</div>
                    <div class="row">
                        <div class="form-group" style="flex:1;">
                            <label>Course Fee (LKR)</label>
                            <input type="number" name="course_fee" class="form-control" placeholder="65000" value="<%= cFee %>" required>
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Duration</label>
                            <input type="text" name="duration" class="form-control" placeholder="e.g., 4 Years" value="<%= duration %>" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group" style="flex:1;">
                            <label>Capacity (Max Students)</label>
                            <input type="number" name="capacity" class="form-control" placeholder="50" value="<%= capacity %>" required>
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Prerequisites</label>
                            <input type="text" name="prerequisites" class="form-control" placeholder="e.g., A/L Passed" value="<%= prereq %>">
                        </div>
                    </div>
                    <button type="submit" class="btn-prime"><%= isCourseEdit ? "Update Course" : "Save Course" %></button>
                    
                    <% if(isCourseEdit) { %>
                        <a href="manage-courses.jsp" class="btn-delete" style="text-decoration: none; display: block; text-align: center; margin-top: 10px; padding: 10px;">Cancel Edit</a>
                    <% } %>
                </form>
            </div>

            <!-- Course List Table -->
            <div class="card">
                <h3>Existing Courses</h3>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Course Name</th>
                                <th>Fee</th>
                                <th>Duration</th>
                                <th>Capacity</th>
                                <th>Prerequisites</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Statement stCourse = conn.createStatement();
                                ResultSet rsCourse = stCourse.executeQuery("SELECT * FROM courses ORDER BY id DESC");
                                while(rsCourse.next()) {
                            %>
                            <tr>
                                <td><%= rsCourse.getString("course_name") %></td>
                                <td>LKR <%= String.format("%,.2f", rsCourse.getDouble("course_fee")) %></td>
                                <td><%= rsCourse.getString("duration") %></td>
                                <td><%= rsCourse.getInt("capacity") %> Students</td>
                                <td><span class="badge"><%= (rsCourse.getString("prerequisites") != null && !rsCourse.getString("prerequisites").trim().isEmpty()) ? rsCourse.getString("prerequisites") : "None" %></span></td>
                                <td class="action-btns">
                                    <a href="CourseServlet?action=edit&id=<%= rsCourse.getInt("id") %>" class="btn-edit" style="text-decoration: none;">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <a href="CourseServlet?action=delete&id=<%= rsCourse.getInt("id") %>" 
                                       class="btn-delete" 
                                       onclick="return confirm('Are you sure you want to delete this course? All related subjects will be deleted!');" 
                                       style="text-decoration: none;">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 🚀 SECTION 2: SUBJECT MANAGEMENT -->
        <div id="subjects" class="tab-content">
            <!-- Add / Edit Subject Form -->
            <div class="card">
                <h3><%= isSubjectEdit ? "Edit Subject" : "Add & Assign Subject" %></h3>
                <form action="SubjectServlet" method="POST">
                    
                    <% if(isSubjectEdit) { %>
                        <input type="hidden" name="subject_id" value="<%= editSubId %>">
                    <% } %>

                    <div class="form-group">
                        <label>Subject Name</label>
                        <input type="text" name="subject_name" class="form-control" placeholder="e.g., Database Management" value="<%= subName %>" required>
                    </div>
                    <div class="form-group">
                        <label>Assign to Course</label>
                        <select name="assigned_course" class="form-control" required>
                            <option value="">-- Select Course --</option>
                            <%
                                Statement stCourseDrop = conn.createStatement();
                                ResultSet rsCourseDrop = stCourseDrop.executeQuery("SELECT id, course_name FROM courses");
                                while(rsCourseDrop.next()) {
                                    String selected = (assignedCourseId.equals(String.valueOf(rsCourseDrop.getInt("id")))) ? "selected" : "";
                            %>
                            <option value="<%= rsCourseDrop.getInt("id") %>" <%= selected %>><%= rsCourseDrop.getString("course_name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="row">
                        <div class="form-group" style="flex:1;">
                            <label>Credit Hours</label>
                            <input type="number" name="credits" class="form-control" placeholder="3" value="<%= credits %>" required>
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Semester</label>
                            <select name="semester" class="form-control" required>
                                <option value="Semester 1" <%= "Semester 1".equals(semester) ? "selected" : "" %>>Semester 1</option>
                                <option value="Semester 2" <%= "Semester 2".equals(semester) ? "selected" : "" %>>Semester 2</option>
                                <option value="Semester 3" <%= "Semester 3".equals(semester) ? "selected" : "" %>>Semester 3</option>
                                <option value="Semester 4" <%= "Semester 4".equals(semester) ? "selected" : "" %>>Semester 4</option>
                            </select>
                        </div>
                    </div>
                    <button type="submit" class="btn-prime"><%= isSubjectEdit ? "Update Subject" : "Save Subject" %></button>
                    
                    <% if(isSubjectEdit) { %>
                        <a href="manage-courses.jsp#subjects" class="btn-delete" style="text-decoration: none; display: block; text-align: center; margin-top: 10px; padding: 10px;">Cancel Edit</a>
                    <% } %>
                </form>
            </div>

            <!-- Subject List Table -->
            <div class="card">
                <h3>Subject Structure (Semester-wise)</h3>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Subject Name</th>
                                <th>Belongs To Course</th>
                                <th>Credits</th>
                                <th>Semester</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Statement stSub = conn.createStatement();
                                ResultSet rsSub = stSub.executeQuery("SELECT s.*, c.course_name FROM subjects s JOIN courses c ON s.course_id = c.id ORDER BY s.semester ASC, s.id DESC");
                                while(rsSub.next()) {
                            %>
                            <tr>
                                <td><%= rsSub.getString("subject_name") %></td>
                                <td><%= rsSub.getString("course_name") %></td>
                                <td><%= rsSub.getInt("credits") %> Credits</td>
                                <td><span class="badge" style="background: rgba(69,162,158,0.3); color: var(--cyan-color);"><%= rsSub.getString("semester") %></span></td>
                                <td class="action-btns">
                                    <a href="SubjectServlet?action=edit&id=<%= rsSub.getInt("id") %>" class="btn-edit" style="text-decoration: none;">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <a href="SubjectServlet?action=delete&id=<%= rsSub.getInt("id") %>" 
                                       class="btn-delete" 
                                       onclick="return confirm('Are you sure you want to delete this subject?');" 
                                       style="text-decoration: none;">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<%
    if(conn != null) conn.close();
%>

<script>
    function switchTab(tabId) {
        document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        
        document.getElementById(tabId).classList.add('active');
        document.getElementById('btn-' + tabId).classList.add('active');
    }

    window.onload = function() {
        if(window.location.hash === '#subjects' || window.location.search.includes('editSubId')) {
            switchTab('subjects');
        } else {
            switchTab('courses');
        }
    }
</script>
</body>
</html>