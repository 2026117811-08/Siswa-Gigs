/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.siswagigs.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ApplicationServlet")
public class ApplicationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String jobIdStr = request.getParameter("jobId");

        if (jobIdStr == null || jobIdStr.isEmpty()) {
            response.sendRedirect("student/JobServlet");
            return;
        }

        int jobId = Integer.parseInt(jobIdStr);

        String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // 1. Retrieve student_id from students table using session userId
            int studentId = 0;
            String getStudentSql = "SELECT student_id FROM students WHERE user_id = ?";
            PreparedStatement pstmtStudent = conn.prepareStatement(getStudentSql);
            pstmtStudent.setInt(1, userId);
            ResultSet rsStudent = pstmtStudent.executeQuery();

            if (rsStudent.next()) {
                studentId = rsStudent.getInt("student_id");
            }
            rsStudent.close();
            pstmtStudent.close();

            if (studentId == 0) {
                conn.close();
                response.sendRedirect("student/JobServlet?error=student_not_found");
                return;
            }

            // 2. Check if the student has an active/pending/accepted application for this job
            // (Exclude 'Rejected' so they can re-apply if rejected before)
            String checkSql = "SELECT application_status FROM applications WHERE job_id = ? AND student_id = ? AND application_status != 'Rejected'";
            PreparedStatement pstmtCheck = conn.prepareStatement(checkSql);
            pstmtCheck.setInt(1, jobId);
            pstmtCheck.setInt(2, studentId);
            ResultSet rsCheck = pstmtCheck.executeQuery();

            if (rsCheck.next()) {
                // Already has a pending or accepted application
                rsCheck.close();
                pstmtCheck.close();
                conn.close();
                response.sendRedirect("student/application.jsp?status=duplicate");
                return;
            }
            rsCheck.close();
            pstmtCheck.close();

            // 3. Insert new application record into 'applications' table
            String insertSql = "INSERT INTO applications (job_id, student_id, application_date, application_status) VALUES (?, ?, NOW(), 'Pending')";
            PreparedStatement pstmtInsert = conn.prepareStatement(insertSql);
            pstmtInsert.setInt(1, jobId);
            pstmtInsert.setInt(2, studentId);
            pstmtInsert.executeUpdate();

            pstmtInsert.close();
            conn.close();

            // Redirect to application history page upon successful submission
            response.sendRedirect("student/application.jsp?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = URLEncoder.encode(e.getMessage(), "UTF-8");
            response.sendRedirect("student/jobDetails.jsp?id=" + jobId + "&error=" + errorMsg);
        }
    }
}