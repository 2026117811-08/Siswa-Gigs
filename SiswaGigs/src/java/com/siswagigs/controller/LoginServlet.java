/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.siswagigs.controller;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedhash = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder(2 * encodedhash.length);
            for (byte b : encodedhash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Failed to hash password", e);
        }
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        String email = request.getParameter("email");
        String rawPassword = request.getParameter("password");
        String hashedPassword = hashPassword(rawPassword);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                // 1. Semak sama ada emel wujud di dalam database (sebagai Student)
                String checkEmailSql = "SELECT u.user_id, u.role FROM users u WHERE u.email = ? AND u.role = 'Student'";
                try (PreparedStatement emailStmt = conn.prepareStatement(checkEmailSql)) {
                    emailStmt.setString(1, email);
                    try (ResultSet emailRs = emailStmt.executeQuery()) {
                        if (!emailRs.next()) {
                            // Emel tidak wujud langsung dalam database
                            response.sendRedirect("student/login.jsp?error=email_not_found");
                            return;
                        }
                    }
                }

                // 2. Semak gabungan emel dan password yang betul
                String sql = "SELECT u.user_id, u.full_name, u.role, s.student_id, s.matric_number " +
                             "FROM users u JOIN students s ON u.user_id = s.user_id " +
                             "WHERE u.email = ? AND u.password_hash = ? AND u.role = 'Student'";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, email);
                    pstmt.setString(2, hashedPassword);
                    
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            // Berjaya! Cipta session untuk student
                            HttpSession session = request.getSession();
                            session.setAttribute("userId", rs.getInt("user_id"));
                            session.setAttribute("studentId", rs.getInt("student_id"));
                            session.setAttribute("fullName", rs.getString("full_name"));
                            session.setAttribute("matricNumber", rs.getString("matric_number"));
                            session.setAttribute("role", rs.getString("role"));
                            
                            response.sendRedirect("student/dashboard.jsp");
                        } else {
                            // Emel wujud, tetapi password salah
                            response.sendRedirect("student/login.jsp?error=wrong_password");
                        }
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.getWriter().println("Error: MySQL JDBC Driver not found! " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("Database Error: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Handles secure student login with specific error alerts";
    }
}