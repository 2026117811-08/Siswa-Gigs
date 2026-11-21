package com.siswagigs.controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/JobServlet")
public class JobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }

        List jobList = new ArrayList();
        
        String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            // Query incorporating employer details and aggregated required skills
            String sql = "SELECT j.*, e.company_name, e.business_sector, " +
                         "GROUP_CONCAT(s.skill_name SEPARATOR ', ') AS required_skills " +
                         "FROM jobs j " +
                         "JOIN employers e ON j.employer_id = e.employer_id " +
                         "LEFT JOIN job_skills js ON j.job_id = js.job_id " +
                         "LEFT JOIN skills s ON js.skill_id = s.skill_id " +
                         "WHERE j.job_status = 'Available' " +
                         "GROUP BY j.job_id " +
                         "ORDER BY j.posted_date DESC";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                HashMap job = new HashMap();
                job.put("jobId", rs.getInt("job_id"));
                job.put("jobTitle", rs.getString("job_title"));
                job.put("description", rs.getString("description"));
                job.put("location", rs.getString("location"));
                job.put("hourlyRate", rs.getDouble("hourly_rate"));
                job.put("vacancies", rs.getInt("vacancies"));
                job.put("companyName", rs.getString("company_name"));
                job.put("sector", rs.getString("business_sector") != null ? rs.getString("business_sector") : "Campus Department");
                job.put("requiredSkills", rs.getString("required_skills") != null ? rs.getString("required_skills") : "General Skills");
                job.put("postedDate", rs.getDate("posted_date"));
                jobList.add(job);
            }
            
            rs.close();
            pstmt.close();
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        request.setAttribute("jobList", jobList);
        request.getRequestDispatcher("jobList.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}