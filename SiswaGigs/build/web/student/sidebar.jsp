<%-- 
    Document   : sidebar
    Created on : Nov 21, 2026, 2:33:38 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String currentUri = request.getRequestURI();
    String currentServlet = request.getServletPath();

    boolean isDashboard =
            currentUri.contains("dashboard.jsp");

    boolean isProfile =
            currentUri.contains("profile.jsp");

    boolean isExploreGigs =
            currentServlet.contains("JobServlet") ||
            currentUri.contains("JobServlet") ||
            currentUri.contains("jobList.jsp") ||
            currentUri.contains("jobDetails.jsp");

    boolean isApplications =
            currentUri.contains("application.jsp");

    boolean isWorkRecords =
            currentServlet.contains("WorkRecordServlet") ||
            currentUri.contains("WorkRecordServlet") ||
            currentUri.contains("workRecord.jsp");

    boolean isWageCalculation =
            currentServlet.contains("WageCalculationServlet") ||
            currentUri.contains("WageCalculationServlet") ||
            currentUri.contains("wageCalculation.jsp");

    boolean isPayments =
            currentServlet.contains("PaymentServlet") ||
            currentUri.contains("PaymentServlet") ||
            currentUri.contains("payment.jsp");

    boolean isReports =
            currentServlet.contains("ReportServlet") ||
            currentUri.contains("ReportServlet") ||
            currentUri.contains("reportDashboard.jsp");

    String activeClass = "active text-white shadow-sm bg-primary";
    String inactiveClass = "text-secondary nav-hover-custom";
%>

<!-- Sidebar Desktop (Professional Dark Corporate Theme) -->
<div class="col-md-3 col-lg-2 sidebar d-none d-md-flex flex-column justify-content-between p-4 shadow" style="background-color: #0f172a; min-height: 100vh; border-right: 1px solid #1e293b;">
    
    <!-- Bahagian Atas: Logo & Menu Utama -->
    <div>
        <a href="dashboard.jsp" class="text-decoration-none fs-5 fw-bold text-white d-flex align-items-center gap-2 mb-4 px-2">
            <div class="bg-primary text-white p-2 rounded-2 shadow-sm d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                <i class="bi bi-briefcase-fill fs-6"></i>
            </div>
            <span>Siswa<span class="text-primary">-Gigs</span></span>
        </a>
        
        <div class="text-uppercase text-muted fs-7 fw-bold px-2 mb-2" style="font-size: 0.7rem; letter-spacing: 0.05em;">Menu Utama</div>
        
        <ul class="nav flex-column gap-1">
            <li class="nav-item">
                <a href="dashboard.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isDashboard ? activeClass : inactiveClass %>">
                    <i class="bi bi-speedometer2 me-2"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a href="profile.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isProfile ? activeClass : inactiveClass %>">
                    <i class="bi bi-person-circle me-2"></i> Profile
                </a>
            </li>
            <li class="nav-item">
                <a href="JobServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isExploreGigs ? activeClass : inactiveClass %>">
                    <i class="bi bi-search me-2"></i> Explore Gigs
                </a>
            </li>
            <li class="nav-item">
                <a href="application.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isApplications ? activeClass : inactiveClass %>">
                    <i class="bi bi-file-earmark-text me-2"></i> My Applications
                </a>
            </li>
            <li class="nav-item">
                <a href="workRecord.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isWorkRecords ? activeClass : inactiveClass %>">
                    <i class="bi bi-clock-history me-2"></i> Work Records
                </a>
            </li>
            <li class="nav-item">
                <a href="WageCalculationServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isWageCalculation ? activeClass : inactiveClass %>">
                    <i class="bi bi-calculator me-2"></i> Wage Calculation
                </a>
            </li>
            <li class="nav-item">
                <a href="payment.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isPayments ? activeClass : inactiveClass %>">
                    <i class="bi bi-cash-coin me-2"></i> Payments
                </a>
            </li>
            <li class="nav-item">
                <a href="ReportServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isReports ? activeClass : inactiveClass %>">
                    <i class="bi bi-bar-chart-line me-2"></i> Reports &amp; Analytics
                </a>
            </li>
        </ul>
    </div>

    <!-- Bahagian Bawah: Butang Log Out di Bawah Sekali -->
    <div class="mt-auto pt-3">
        <hr class="border-secondary opacity-25 mb-3">
        <a href="../LogoutServlet" class="nav-link text-danger px-3 py-2.5 fw-medium rounded-2 d-flex align-items-center logout-btn-custom">
            <i class="bi bi-box-arrow-right me-2 fs-5"></i> Log Out
        </a>
    </div>
</div>

<!-- Mobile Navbar -->
<nav class="navbar navbar-dark px-4 py-3 d-md-none shadow-sm" style="background-color: #0f172a; border-bottom: 1px solid #1e293b;">
    <div class="container-fluid p-0">
        <a href="dashboard.jsp" class="navbar-brand fw-bold text-white d-flex align-items-center gap-2">
            <div class="bg-primary text-white p-1.5 rounded-2 shadow-sm">
                <i class="bi bi-briefcase-fill fs-6"></i>
            </div>
            <span>Siswa-Gigs</span>
        </a>
        <button class="btn text-white border border-secondary rounded-2 px-3 py-1.5 fw-medium" type="button" data-bs-toggle="offcanvas" data-bs-target="#mobileSidebar" style="background-color: #1e293b;">
            <i class="bi bi-list fs-5 me-1"></i> Menu
        </button>
    </div>
</nav>

<!-- Mobile Offcanvas Sidebar Menu -->
<div class="offcanvas offcanvas-start text-white border-0 shadow" tabindex="-1" id="mobileSidebar" style="background-color: #0f172a;">
    <div class="offcanvas-header border-bottom border-secondary">
        <h5 class="offcanvas-title fw-bold text-white d-flex align-items-center gap-2">
            <div class="bg-primary text-white p-1.5 rounded-2">
                <i class="bi bi-briefcase-fill fs-6"></i>
            </div>
            Siswa-Gigs
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body p-4 d-flex flex-column justify-content-between">
        <div>
            <div class="text-uppercase text-muted fs-7 fw-bold px-2 mb-2" style="font-size: 0.7rem; letter-spacing: 0.05em;">Menu Utama</div>
            <ul class="nav flex-column gap-1">
                <li class="nav-item">
                    <a href="dashboard.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isDashboard ? activeClass : inactiveClass %>">
                        <i class="bi bi-speedometer2 me-2"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="profile.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isProfile ? activeClass : inactiveClass %>">
                        <i class="bi bi-person-circle me-2"></i> Profile
                    </a>
                </li>
                <li class="nav-item">
                    <a href="JobServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isExploreGigs ? activeClass : inactiveClass %>">
                        <i class="bi bi-search me-2"></i> Explore Gigs
                    </a>
                </li>
                <li class="nav-item">
                    <a href="application.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isApplications ? activeClass : inactiveClass %>">
                        <i class="bi bi-file-earmark-text me-2"></i> My Applications
                    </a>
                </li>
                <li class="nav-item">
                    <a href="workRecord.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isWorkRecords ? activeClass : inactiveClass %>">
                        <i class="bi bi-clock-history me-2"></i> Work Records
                    </a>
                </li>
                <li class="nav-item">
                    <a href="WageCalculationServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isWageCalculation ? activeClass : inactiveClass %>">
                        <i class="bi bi-calculator me-2"></i> Wage Calculation
                    </a>
                </li>
                <li class="nav-item">
                    <a href="payment.jsp" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isPayments ? activeClass : inactiveClass %>">
                        <i class="bi bi-cash-coin me-2"></i> Payments
                    </a>
                </li>
                <li class="nav-item">
                    <a href="ReportServlet" class="nav-link px-3 py-2.5 fw-medium rounded-2 <%= isReports ? activeClass : inactiveClass %>">
                        <i class="bi bi-bar-chart-line me-2"></i> Reports &amp; Analytics
                    </a>
                </li>
            </ul>
        </div>
        
        <div class="mt-auto pt-3">
            <hr class="border-secondary opacity-25 mb-3">
            <a href="../LogoutServlet" class="nav-link text-danger px-3 py-2.5 fw-medium rounded-2 d-flex align-items-center logout-btn-custom">
                <i class="bi bi-box-arrow-right me-2 fs-5"></i> Log Out
            </a>
        </div>
    </div>
</div>

<style>
    /* Kesan warna teks pautan biasa di dalam menu gelap */
    .sidebar .nav-link:not(.active), .offcanvas .nav-link:not(.active) {
        color: #94a3b8 !important;
    }
    .nav-hover-custom {
        transition: all 0.2s ease;
    }
    .nav-hover-custom:hover {
        background-color: #1e293b !important;
        color: #ffffff !important;
        transform: translateX(3px);
    }
    .logout-btn-custom {
        transition: all 0.2s ease;
    }
    .logout-btn-custom:hover {
        background-color: rgba(239, 68, 68, 0.15) !important;
        color: #ef4444 !important;
    }
</style>
