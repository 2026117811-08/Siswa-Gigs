package com.siswagigs.controller;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

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
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String matricNumber = request.getParameter("matricNumber");
        String studyYearStr = request.getParameter("studyYear");
        String programme = request.getParameter("programme");
        String departmentName = request.getParameter("departmentName");
        String rawPassword = request.getParameter("password");

        // Strict Server-Side Validation checks
        if (fullName == null || !fullName.matches("^[A-Za-z\\s]+$") ||
            email == null || !email.contains("@") ||
            phone == null || !phone.matches("^[0-9]+$") ||
            matricNumber == null || !matricNumber.matches("^[0-9]+$")) {
            
            response.sendRedirect("student/register.jsp?error=invalid_format");
            return;
        }

        String securePasswordHash = hashPassword(rawPassword);

        Connection conn = null;
        PreparedStatement pstmtUser = null;
        PreparedStatement pstmtStudent = null;
        ResultSet generatedKeys = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            conn.setAutoCommit(false);

            // 1. Insert into 'users' parent table
            String sqlUser = "INSERT INTO users (full_name, email, password_hash, role, phone_number) VALUES (?, ?, ?, 'Student', ?)";
            pstmtUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            pstmtUser.setString(1, fullName);
            pstmtUser.setString(2, email);
            pstmtUser.setString(3, securePasswordHash);
            pstmtUser.setString(4, phone);
            
            pstmtUser.executeUpdate();

            int userId = 0;
            generatedKeys = pstmtUser.getGeneratedKeys();
            if (generatedKeys.next()) {
                userId = generatedKeys.getInt(1);
            }

            // 2. Insert into 'students' child table
            String sqlStudent = "INSERT INTO students (user_id, matric_number, programme, department_name, study_year) VALUES (?, ?, ?, ?, ?)";
            pstmtStudent = conn.prepareStatement(sqlStudent);
            pstmtStudent.setInt(1, userId);
            pstmtStudent.setString(2, matricNumber);
            pstmtStudent.setString(3, programme);
            pstmtStudent.setString(4, departmentName);
            pstmtStudent.setInt(5, Integer.parseInt(studyYearStr));
            
            pstmtStudent.executeUpdate();

            conn.commit();
            response.sendRedirect("student/login.jsp?registration=success");

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            
            // Check for MySQL Duplicate Entry Error Code (1062)
            if (e.getErrorCode() == 1062) {
                // Redirect back with a specific duplicate error flag
                response.sendRedirect("student/register.jsp?error=duplicate");
            } else {
                e.printStackTrace();
                response.getWriter().println("Database Error: " + e.getMessage());
            }
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.getWriter().println("Registration Error: " + e.getMessage());
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (SQLException e) { }
            try { if (pstmtUser != null) pstmtUser.close(); } catch (SQLException e) { }
            try { if (pstmtStudent != null) pstmtStudent.close(); } catch (SQLException e) { }
            try { if (conn != null) conn.close(); } catch (SQLException e) { }
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
        return "Handles secure student registration with duplicate key checking";
    }
}