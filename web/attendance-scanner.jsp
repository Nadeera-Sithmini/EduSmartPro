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
    <title>QR Attendance Scanner - Smart Student Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght=300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- QR Scanner JS Library (html5-qrcode: actively maintained, replaces broken Instascan/rawgit) -->
    <script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>

    <style>
        :root {
            --bg-color: #0b0c10;
            --secondary-bg: #1f2833;
            --cyan-color: #66fcf1;
            --dark-cyan: #45a29e;
            --text-color: #c5c6c7;
            --white: #ffffff;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: radial-gradient(circle at center, #0f172a, #020617);
            color: var(--white);
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

        .header-title { 
            color: var(--cyan-color); 
            margin-bottom: 30px; 
            border-bottom: 1px solid rgba(102, 252, 241, 0.2); 
            padding-bottom: 15px; 
        }

        .header-title h2 {
            font-size: 1.8rem;
            font-weight: 600;
            text-shadow: 0 0 10px rgba(102, 252, 241, 0.2);
        }

        /* 🎥 GRID WORK */
        .scanner-grid { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 30px; 
        }

        @media (max-width: 1000px) { 
            .scanner-grid { grid-template-columns: 1fr; } 
        }

        .card { 
            background: rgba(30, 41, 59, 0.6); 
            padding: 30px; 
            border-radius: 12px; 
            border: 1px solid rgba(102, 252, 241, 0.1); 
            text-align: center; 
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: var(--cyan-color);
            box-shadow: 0 5px 15px rgba(102, 252, 241, 0.05);
        }

        .card h3 { 
            color: var(--cyan-color); 
            margin-top: 0; 
            margin-bottom: 20px; 
            font-weight: 500;
        }

        /* html5-qrcode renders into this div (was a <video> before) */
        #preview {
            width: 100%;
            max-width: 400px;
            margin: 0 auto;
            border-radius: 10px;
            overflow: hidden;
            border: 2px solid var(--cyan-color);
            background: #000;
            box-shadow: 0 0 15px rgba(102, 252, 241, 0.2);
            min-height: 200px;
        }

        .no-camera-msg {
            color: var(--text-color);
            font-size: 0.85rem;
            padding: 20px;
        }

        .form-control { 
            width: 100%; 
            padding: 12px; 
            background: rgba(15, 23, 42, 0.6); 
            border: 1px solid rgba(255, 255, 255, 0.1); 
            border-radius: 8px; 
            color: var(--white); 
            box-sizing: border-box; 
            font-size: 0.95rem; 
            text-align: center; 
            transition: all 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--cyan-color);
            box-shadow: 0 0 10px rgba(102, 252, 241, 0.1);
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 20px 0;
            color: var(--text-color);
            font-size: 0.8rem;
        }
        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: rgba(255,255,255,0.1);
        }

        .btn-prime { 
            background: var(--cyan-color); 
            color: #0b0c10; 
            border: none; 
            padding: 12px 20px; 
            border-radius: 8px; 
            cursor: pointer; 
            font-weight: 600; 
            width: 100%; 
            margin-top: 15px; 
            transition: 0.3s ease; 
        }

        .btn-prime:hover { 
            background: var(--dark-cyan); 
            box-shadow: 0 0 15px rgba(102, 252, 241, 0.3);
        }

        .alert-box { 
            padding: 15px; 
            border-radius: 8px; 
            margin-top: 15px; 
            font-weight: 600; 
            display: none; 
            font-size: 0.9rem;
        }

        .alert-success { background: rgba(34, 197, 94, 0.15); color: #22c55e; border: 1px solid #22c55e; }
        .alert-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; border: 1px solid #ef4444; }
    </style>
</head>
<body>

    <!-- 🛠️ SIDEBAR KOTASA -->
    <div class="sidebar">
        <div class="sidebar-brand">
            <i class="fa-solid fa-graduation-cap"></i>
            <h3>EduSmart Pro</h3>
        </div>
        <ul class="sidebar-menu">
            <li>
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

            <!-- 3. Attendance (Active කර ඇත) -->
            <li class="active">
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
                <a href="audit-logs.jsp"><i class="fa-solid fa-shield-halved"></i> Audit Logs & Backup</a>
            </li>

            <li class="sidebar-footer">
                <a href="logout.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </li>
        </ul>
    </div>

    <!-- 🛠️ MAIN PANEL KOTASA -->
    <div class="main-content">
        <div class="dashboard-card">

            <%
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_new_db", "root", "");
            %>

            <div class="header-title">
                <h2><i class="fa-solid fa-qrcode"></i> QR Code Attendance System</h2>
            </div>

            <div class="scanner-grid">
                <!-- 🎥 SCANNER CAMERA CARD -->
                <div class="card">
                    <h3><i class="fa-solid fa-camera"></i> Live Scanner</h3>
                    <div id="preview"></div>
                    <div id="scan-message" class="alert-box"></div>
                </div>

                <!-- 📝 MANUAL / AUTO MARK FORM -->
                <div class="card">
                    <h3>Mark Attendance</h3>
                    <form id="attendanceForm" action="AttendanceServlet" method="POST">
                        <div class="form-group" style="margin-bottom: 20px; text-align: left;">
                            <label style="color: var(--text-color); font-size: 0.85rem; display: block; margin-bottom: 8px;">Select Course Context</label>
                            <select name="course_id" id="course_id" class="form-control" style="text-align-last: center;" required>
                                <option value="">-- Select Course --</option>
                                <option value="programming-fundamentals">Programming Fundamentals</option>
<option value="database-systems">Database Systems</option>
<option value="web-development">Web Development</option>
<option value="data-structures-algorithms">Data Structures &amp; Algorithms</option>
<option value="software-engineering-principles">Software Engineering Principles</option>
<option value="object-oriented-programming">Object Oriented Programming</option>
<option value="mathematics-for-computing">Mathematics for Computing</option>
<option value="operating-systems">Operating Systems</option>
<option value="computer-networks">Computer Networks</option>
<option value="mobile-app-development">Mobile App Development</option>
<option value="machine-learning-fundamentals">Machine Learning Fundamentals</option>
<option value="software-project-management">Software Project Management</option>
<option value="cloud-computing">Cloud Computing</option>
                                <%
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery("SELECT id, course_name FROM courses");
                                    while(rs.next()) {
                                %>
                                <option value="<%= rs.getInt("id") %>"><%= rs.getString("course_name") %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group" style="text-align: left; margin-bottom: 10px;">
                            <label style="color: var(--text-color); font-size: 0.85rem; display: block; margin-bottom: 8px;">Scanned Student ID (auto-filled by QR)</label>
                            <input type="text" name="student_id" id="student_id" class="form-control" placeholder="Scan QR or select manually below" readonly>
                        </div>

                        <div class="divider">OR SELECT MANUALLY</div>

                        <div class="form-group" style="text-align: left; margin-bottom: 10px;">
                            <label style="color: var(--text-color); font-size: 0.85rem; display: block; margin-bottom: 8px;">Select Student</label>
                            <select id="manual_student" class="form-control" style="text-align-last: center;">
                                <option value="">-- Select Student --</option>
                                <%
                                    Statement st2 = conn.createStatement();
                                    ResultSet rs2 = st2.executeQuery("SELECT student_id, fullname FROM students ORDER BY fullname");
                                    while(rs2.next()) {
                                %>
                                <option value="<%= rs2.getString("student_id") %>"><%= rs2.getString("fullname") %> (<%= rs2.getString("student_id") %>)</option>
                                <% } %>
                            </select>
                        </div>

                        <button type="submit" class="btn-prime"><i class="fa-solid fa-check"></i> Submit Attendance</button>
                    </form>
                </div>
            </div>

            <% if(conn != null) conn.close(); %>

        </div>
    </div>

<!-- 📷 HTML5-QRCODE CONFIGURATION JS -->
<script>
    let isProcessing = false;

    function onScanSuccess(decodedText, decodedResult) {
        if (isProcessing) return;

        let courseId = document.getElementById('course_id').value;
        if (!courseId) {
            showMsg("Please select a Course before scanning!", "danger");
            return;
        }

        isProcessing = true;
        document.getElementById('student_id').value = decodedText;

        showMsg("QR Detected! Submitting Attendance...", "success");
        setTimeout(() => {
            document.getElementById('attendanceForm').submit();
        }, 1000);
    }

    function onScanFailure(error) {
        // Continuous scan attempts fail silently until a QR code is found - no need to log
    }

    const html5QrCode = new Html5Qrcode("preview");

    Html5Qrcode.getCameras().then(cameras => {
        if (cameras && cameras.length) {
            const cameraId = cameras.length > 1 ? cameras[1].id : cameras[0].id;

            html5QrCode.start(
                cameraId,
                {
                    fps: 10,
                    qrbox: { width: 250, height: 250 }
                },
                onScanSuccess,
                onScanFailure
            ).catch(err => {
                document.getElementById('preview').innerHTML =
                    '<p class="no-camera-msg"><i class="fa-solid fa-keyboard"></i><br>Camera unavailable — use the "Select Student" dropdown instead.</p>';
            });
        } else {
            document.getElementById('preview').innerHTML =
                '<p class="no-camera-msg"><i class="fa-solid fa-keyboard"></i><br>No camera found — use the "Select Student" dropdown instead.</p>';
        }
    }).catch(err => {
        document.getElementById('preview').innerHTML =
            '<p class="no-camera-msg"><i class="fa-solid fa-keyboard"></i><br>Camera unavailable — use the "Select Student" dropdown instead.</p>';
    });

    function showMsg(text, type) {
        let msgBox = document.getElementById('scan-message');
        msgBox.innerText = text;
        msgBox.className = "alert-box alert-" + type;
        msgBox.style.display = "block";
    }

    // Manual dropdown selection fills the student_id field, no camera needed
    document.getElementById('manual_student').addEventListener('change', function () {
        document.getElementById('student_id').value = this.value;
    });

    // URL එකෙන් Error/Success මැසේජ් ආවොත් පෙන්වන්න
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('status')) {
        if (urlParams.get('status') === 'success') {
            showMsg("Attendance Marked Successfully!", "success");
        } else if (urlParams.get('status') === 'duplicate') {
            showMsg("Attendance Already Marked for Today!", "danger");
        } else if (urlParams.get('status') === 'invalid') {
            showMsg("Invalid Student ID or Course!", "danger");
        }
    }
</script>
</body>
</html>
