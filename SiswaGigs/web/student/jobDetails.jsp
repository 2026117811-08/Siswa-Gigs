<%-- 
    Document   : jobDetails
    Created on : Nov 21, 2026, 7:43:09 PM
    Author     : HP
--%>

<%-- 
    Document   : jobDetails
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String matricNumber = (String) userSession.getAttribute("matricNumber");
    int studentId = (Integer) userSession.getAttribute("userId");

    String jobIdStr = request.getParameter("id");
    if (jobIdStr == null || jobIdStr.isEmpty()) {
        response.sendRedirect("JobServlet");
        return;
    }

    int jobId = Integer.parseInt(jobIdStr);
    HashMap job = null;
    ArrayList skillList = new ArrayList();

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // Fetch job & employer details
        String sql = "SELECT j.*, e.company_name, e.business_sector FROM jobs j " +
                     "JOIN employers e ON j.employer_id = e.employer_id " +
                     "WHERE j.job_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, jobId);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            job = new HashMap();
            job.put("jobId", rs.getInt("job_id"));
            job.put("jobTitle", rs.getString("job_title"));
            job.put("description", rs.getString("description"));
            job.put("location", rs.getString("location"));
            job.put("hourlyRate", rs.getDouble("hourly_rate"));
            job.put("vacancies", rs.getInt("vacancies"));
            job.put("companyName", rs.getString("company_name"));
            job.put("sector", rs.getString("business_sector"));
            job.put("postedDate", rs.getDate("posted_date"));
        }
        rs.close();
        pstmt.close();

        // Fetch skills required for this job
        String sqlSkills = "SELECT s.skill_name FROM skills s " +
                           "JOIN job_skills js ON s.skill_id = js.skill_id " +
                           "WHERE js.job_id = ?";
        PreparedStatement pstmtSkills = conn.prepareStatement(sqlSkills);
        pstmtSkills.setInt(1, jobId);
        ResultSet rsSkills = pstmtSkills.executeQuery();
        while (rsSkills.next()) {
            skillList.add(rsSkills.getString("skill_name"));
        }
        rsSkills.close();
        pstmtSkills.close();
        conn.close();

    } catch (Exception e) {
        e.printStackTrace();
    }

    if (job == null) {
        response.sendRedirect("JobServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= job.get("jobTitle") %> | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; color: #0f172a; }
        .sidebar { min-height: 100vh; background: #0f172a; color: white; position: fixed; top: 0; left: 0; width: 260px; z-index: 1000; }
        .main-content { margin-left: 260px; }
        @media (max-width: 767.98px) {
            .sidebar { position: static; min-height: auto; }
            .main-content { margin-left: 0; }
        }
        .top-navbar { background: #ffffff; border-bottom: 1px solid #e2e8f0; height: 70px; }
        .detail-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <div class="row g-0">
            <%@ include file="sidebar.jsp" %>

            <div class="col main-content">
                <div class="top-navbar px-4 px-md-5 d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-semibold text-uppercase tracking-wider">Student Portal</span>
                        <h5 class="fw-bold text-dark mb-0">Job Details & Application</h5>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm" type="button" data-bs-toggle="dropdown">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 24px; height: 24px; font-size: 0.75rem;">
                                <%= (fullName != null && !fullName.isEmpty()) ? fullName.substring(0, 1).toUpperCase() : "S" %>
                            </div>
                            <span><%= fullName != null ? fullName : "Student" %></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                            <li><h6 class="dropdown-header text-muted small"><%= matricNumber != null ? matricNumber : "-" %></h6></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                        </ul>
                    </div>
                </div>

                <div class="p-4 p-md-5">
                    <div class="mb-4">
                        <a href="JobServlet" class="btn btn-outline-secondary btn-sm rounded-pill px-3 fw-semibold">
                            <i class="bi bi-arrow-left me-1"></i> Back to Explore Gigs
                        </a>
                    </div>

                    <div class="row g-4">
                        <!-- Main Job Info -->
                        <div class="col-lg-8">
                            <div class="detail-card p-4 p-md-5 shadow-sm h-100">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill fw-semibold">
                                        <i class="bi bi-geo-alt me-1"></i> <%= job.get("location") %>
                                    </span>
                                    <span class="text-success fw-bold fs-5">RM <%= String.format("%.2f", job.get("hourlyRate")) %> / hr</span>
                                </div>
                                
                                <h2 class="fw-bold text-dark mb-3"><%= job.get("jobTitle") %></h2>
                                
                                <div class="d-flex align-items-center gap-3 text-muted small mb-4 pb-3 border-bottom flex-wrap">
                                    <span><i class="bi bi-building me-1"></i> <%= job.get("companyName") %></span>
                                    <span>•</span>
                                    <span><i class="bi bi-briefcase me-1"></i> Sector: <%= job.get("sector") != null ? job.get("sector") : "Campus Department" %></span>
                                    <span>•</span>
                                    <span><i class="bi bi-people me-1"></i> Vacancies: <%= job.get("vacancies") %></span>
                                </div>

                                <!-- Required Skills Section -->
                                <div class="mb-4">
                                    <h5 class="fw-bold text-dark mb-2"><i class="bi bi-tools me-2 text-primary"></i>Required Skills</h5>
                                    <div>
                                        <%
                                            if (skillList.isEmpty()) {
                                        %>
                                                <span class="text-muted small">No specific skills required. Open to all students.</span>
                                        <%
                                            } else {
                                                for (Object skillObj : skillList) {
                                        %>
                                                    <span class="badge bg-light text-dark border px-3 py-2 me-2 mb-2 fw-semibold"><%= skillObj.toString() %></span>
                                        <%
                                                }
                                            }
                                        %>
                                    </div>
                                </div>

                                <h5 class="fw-bold text-dark mb-3">Job Description & Requirements</h5>
                                <p class="text-secondary leading-relaxed mb-4" style="white-space: pre-line;"><%= job.get("description") %></p>
                            </div>
                        </div>

                        <!-- Application Action Card (Direct Apply Button Only) -->
                        <div class="col-lg-4">
                            <div class="detail-card p-4 shadow-sm">
                                <h5 class="fw-bold text-dark mb-3">Submit Application</h5>
                                <p class="text-muted small mb-4">Clicking submit will send your current profile details and resume attached in your student profile for this gig.</p>
                                
                                <form action="../ApplicationServlet" method="POST">
                                    <input type="hidden" name="jobId" value="<%= job.get("jobId") %>">
                                    <input type="hidden" name="studentId" value="<%= studentId %>">

                                    <button type="submit" class="btn btn-primary w-100 rounded-pill py-2.5 fw-semibold shadow-sm">
                                        <i class="bi bi-send me-2"></i> Apply Now
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>