<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Session eka invalidate karala, user login state eka clear karanawa
    session.invalidate();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="1;url=login.html">
    <title>Logging Out...</title>
    <style>
        body {
            margin: 0;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: radial-gradient(circle at center, #0f172a, #020617);
            font-family: 'Poppins', Arial, sans-serif;
            color: #c5c6c7;
        }
        .box { text-align: center; }
        .box i {
            font-size: 2.5rem;
            color: #66fcf1;
            margin-bottom: 15px;
            display: block;
        }
        .box h2 { color: #fff; font-weight: 500; margin: 0 0 8px 0; }
        .box p { color: #94a3b8; font-size: 0.9rem; margin: 0; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="box">
        <i class="fa-solid fa-right-from-bracket"></i>
        <h2>Logging you out...</h2>
        <p>Redirecting to login page.</p>
    </div>
</body>
</html>
