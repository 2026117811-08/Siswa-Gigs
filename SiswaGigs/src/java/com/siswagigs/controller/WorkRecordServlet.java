/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.siswagigs.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.sql.*;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/WorkRecordServlet")
public class WorkRecordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        String appIdStr = request.getParameter("applicationId");
        String workDateStr = request.getParameter("workDate");
        String clockInStr = request.getParameter("clockIn");
        String clockOutStr = request.getParameter("clockOut");

        if (appIdStr == null || workDateStr == null || clockInStr == null || clockOutStr == null
                || appIdStr.isEmpty() || workDateStr.isEmpty() || clockInStr.isEmpty() || clockOutStr.isEmpty()) {
            response.sendRedirect("workRecord.jsp?error=missing_fields");
            return;
        }

        String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            int applicationId = Integer.parseInt(appIdStr);
            LocalDate workDate = LocalDate.parse(workDateStr);
            Time clockIn = Time.valueOf(clockInStr + ":00");
            Time clockOut = Time.valueOf(clockOutStr + ":00");

            if (workDate.isAfter(LocalDate.now())) {
                response.sendRedirect("workRecord.jsp?error=future_date");
                return;
            }
            if (!clockOut.after(clockIn)) {
                response.sendRedirect("workRecord.jsp?error=invalid_time");
                return;
            }

            // Hours = minutes between clock in and out / 60, 2 decimals
            long minutes = (clockOut.getTime() - clockIn.getTime()) / 60000;
            BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);

            try (Connection conn = DriverManager.getConnection(dbURL, "root", "")) {

                // Make sure this application belongs to this student AND is Hired; get the rate from the job
                String checkSql = "SELECT j.hourly_rate FROM applications a " +
                                  "JOIN students s ON a.student_id = s.student_id " +
                                  "JOIN jobs j ON a.job_id = j.job_id " +
                                  "WHERE a.application_id = ? AND s.user_id = ? AND a.application_status = 'Hired'";
                BigDecimal rate = null;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, applicationId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            rate = rs.getBigDecimal("hourly_rate");
                        }
                    }
                }
                if (rate == null) {
                    response.sendRedirect("workRecord.jsp?error=not_allowed");
                    return;
                }

                // Block duplicate record for same application and date
                String dupSql = "SELECT 1 FROM work_records WHERE application_id = ? AND work_date = ?";
                try (PreparedStatement ps = conn.prepareStatement(dupSql)) {
                    ps.setInt(1, applicationId);
                    ps.setDate(2, Date.valueOf(workDate));
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            response.sendRedirect("workRecord.jsp?error=duplicate");
                            return;
                        }
                    }
                }

                String insertSql = "INSERT INTO work_records (application_id, hours_worked, hourly_rate, work_date, work_status, clock_in, clock_out) " +
                                   "VALUES (?, ?, ?, ?, 'Pending', ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, applicationId);
                    ps.setBigDecimal(2, hours);
                    ps.setBigDecimal(3, rate);
                    ps.setDate(4, Date.valueOf(workDate));
                    ps.setTime(5, clockIn);
                    ps.setTime(6, clockOut);
                    ps.executeUpdate();
                }
            }
            response.sendRedirect("workRecord.jsp?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("workRecord.jsp?error=" + URLEncoder.encode(String.valueOf(e.getMessage()), "UTF-8"));
        }
    }
}