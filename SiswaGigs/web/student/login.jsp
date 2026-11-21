<%-- 
    Document   : login
    Created on : Nov 21, 2026, 2:16:03 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login | Siswa-Gigs</title>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #2563eb 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
        }
        .login-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5 col-lg-4">
                <div class="card login-card p-4 p-md-5 bg-white">
                    <div class="text-center mb-4">
                        <a href="../index.jsp" class="text-decoration-none fs-4 fw-bold text-primary d-inline-flex align-items-center gap-2 mb-2">
                            <i class="bi bi-briefcase-fill"></i> Siswa<span class="text-dark">-Gigs</span>
                        </a>
                        <h4 class="fw-bold text-dark">Student Login</h4>
                        <p class="text-muted small">Access your student portal to explore gigs</p>
                    </div>

                    <!-- Alert / Mesej Ralat Spesifik -->
                    <%
                        String registration = request.getParameter("registration");
                        String error = request.getParameter("error");
                        
                        if ("success".equals(registration)) {
                    %>
                        <div class="alert alert-success text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-check-circle-fill me-1"></i> Registration successful! Please log in.
                        </div>
                    <%
                        }
                        if ("email_not_found".equals(error)) {
                    %>
                        <div class="alert alert-danger text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Email not found! Please register an account first.
                        </div>
                    <%
                        }
                        if ("wrong_password".equals(error)) {
                    %>
                        <div class="alert alert-warning text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i> Incorrect password. Please try again.
                        </div>
                    <%
                        }
                    %>

                    <!-- Login Form -->
                    <form action="../LoginServlet" method="POST">
                        <div class="mb-3">
                            <label for="email" class="form-label fw-semibold small">Student Email</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                <input type="email" class="form-control bg-light border-start-0" id="email" name="email" placeholder="student@uitm.edu.my" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label fw-semibold small">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-lock text-muted"></i></span>
                                <input type="password" class="form-control bg-light border-start-0" id="password" name="password" placeholder="Enter your password" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold rounded-pill shadow-sm mb-3">
                            Log In
                        </button>

                        <div class="text-center text-muted small">
                            Don't have an account? <a href="register.jsp" class="text-primary text-decoration-none fw-semibold">Register</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>