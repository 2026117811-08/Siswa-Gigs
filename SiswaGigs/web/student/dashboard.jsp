<%-- 
    Document   : dashboard
    Created on : Nov 21, 2026, 2:35:30 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Security check for session
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String matricNumber = (String) userSession.getAttribute("matricNumber");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | Siswa-Gigs</title>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f1f5f9; /* Tona slate lembut yang profesional */
        }
        /* Sidebar styling */
        .sidebar {
            min-height: 100vh;
            background: #0f172a;
            color: white;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            z-index: 1000;
            border-right: 1px solid #1e293b;
        }
        .main-content {
            margin-left: 260px;
        }
        @media (max-width: 767.98px) {
            .sidebar {
                position: static;
                min-height: auto;
            }
            .main-content {
                margin-left: 0;
            }
        }
        /* Stat Cards */
        .stat-card {
            border: none;
            border-radius: 14px;
            background: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.08);
        }
        /* Clean Header Card */
        .welcome-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <div class="row g-0">
            
            <!-- Sidebar Include -->
            <%@ include file="sidebar.jsp" %>

            <!-- Main Content Area -->
            <div class="col main-content p-4 p-md-5">
                
                <!-- Top Navigation Header -->
                <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom border-2">
                    <div>
                        <h4 class="fw-bold text-dark mb-1">Dashboard Overview</h4>
                        <p class="text-muted small mb-0">Welcome back, track your academic gigs and earnings here.</p>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-white bg-white border rounded-pill px-3 py-2 dropdown-toggle fw-semibold small shadow-sm d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-size: 0.8rem;">
                                <%= fullName.substring(0, 1).toUpperCase() %>
                            </div>
                            <span><%= fullName %></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2">
                            <li><h6 class="dropdown-header text-muted small"><%= matricNumber %></h6></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                        </ul>
                    </div>
                </div>

                <!-- Welcome Profile Card -->
                <div class="welcome-card p-4 p-md-4 mb-4 shadow-sm d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                    <div>
                        <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-semibold mb-2">Student Session Active</span>
                        <h3 class="fw-bold text-dark mb-1">Hello, <%= fullName %>!</h3>
                        <p class="text-muted small mb-0">Matric Number: <span class="fw-semibold text-dark"><%= matricNumber %></span></p>
                    </div>
                    <div>
                        <a href="#" class="btn btn-primary px-4 py-2 rounded-2 fw-semibold shadow-sm small">
                            <i class="bi bi-search me-1"></i> Browse Gigs
                        </a>
                    </div>
                </div>

                <!-- Dashboard Stats Cards (3 Kotak Utama) -->
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="stat-card p-4 border">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div class="bg-primary bg-opacity-10 text-primary p-3 rounded-3 fs-4 d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                    <i class="bi bi-file-earmark-text"></i>
                                </div>
                                <span class="text-muted small fw-medium">Real-time</span>
                            </div>
                            <h6 class="text-muted small mb-1 fw-medium">Active Applications</h6>
                            <h2 class="fw-bold text-dark mb-0">0</h2>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card p-4 border">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div class="bg-success bg-opacity-10 text-success p-3 rounded-3 fs-4 d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                                <span class="text-muted small fw-medium">Confirmed</span>
                            </div>
                            <h6 class="text-muted small mb-1 fw-medium">Hired Gigs</h6>
                            <h2 class="fw-bold text-dark mb-0">0</h2>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="stat-card p-4 border">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div class="bg-warning bg-opacity-10 text-warning p-3 rounded-3 fs-4 d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                    <i class="bi bi-wallet2"></i>
                                </div>
                                <span class="text-muted small fw-medium">Lifetime</span>
                            </div>
                            <h6 class="text-muted small mb-1 fw-medium">Total Earnings</h6>
                            <h2 class="fw-bold text-dark mb-0">RM 0.00</h2>
                        </div>
                    </div>
                </div>

            </div>
            
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
