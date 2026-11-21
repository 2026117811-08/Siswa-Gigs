/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.siswagigs.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/student/ProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // SHA-256 hex (same format as the hashes already stored in users.password_hash)
    private String sha256(String input) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] bytes = md.digest(input.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        // Retrieve form fields
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String matricNumber = request.getParameter("matricNumber");
        String programme = request.getParameter("programme");
        String departmentName = request.getParameter("departmentName");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Server-side validation: Name must not contain numbers
        if (fullName == null || fullName.matches(".*\\d.*") || email == null || !email.contains("@")) {
            response.sendRedirect("profile.jsp?error=invalid_format");
            return;
        }

        // Validate password matching if entered
        if (newPassword != null && !newPassword.isEmpty()) {
            if (!newPassword.equals(confirmPassword)) {
                response.sendRedirect("profile.jsp?error=password_mismatch");
                return;
            }
        }

        String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // 1. Update users table (full_name, email, phone_number, password_hash)
            if (newPassword != null && !newPassword.isEmpty()) {
                String updateUserSql = "UPDATE users SET full_name = ?, email = ?, phone_number = ?, password_hash = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateUserSql);
                pstmt.setString(1, fullName);
                pstmt.setString(2, email);
                pstmt.setString(3, phoneNumber);
                pstmt.setString(4, sha256(newPassword));
                pstmt.setInt(5, userId);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                String updateUserSql = "UPDATE users SET full_name = ?, email = ?, phone_number = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateUserSql);
                pstmt.setString(1, fullName);
                pstmt.setString(2, email);
                pstmt.setString(3, phoneNumber);
                pstmt.setInt(4, userId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            session.setAttribute("fullName", fullName);

            // 2. Handle PDF Resume Upload
            Part filePart = request.getPart("resumeFile");
            String dbResumePath = null;

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                if (!fileName.toLowerCase().endsWith(".pdf")) {
                    conn.close();
                    response.sendRedirect("profile.jsp?error=invalid_file_type");
                    return;
                }

                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "resumes";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String uniqueFileName = "resume_" + userId + "_" + System.currentTimeMillis() + ".pdf";
                String filePath = uploadPath + File.separator + uniqueFileName;
                dbResumePath = "uploads/resumes/" + uniqueFileName;

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            // 3. Update students table (matric_number, programme, department_name, resume_path)
            if (dbResumePath != null) {
                String updateStudentSql = "UPDATE students SET matric_number = ?, programme = ?, department_name = ?, resume_path = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateStudentSql);
                pstmt.setString(1, matricNumber);
                pstmt.setString(2, programme);
                pstmt.setString(3, departmentName);
                pstmt.setString(4, dbResumePath);
                pstmt.setInt(5, userId);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                String updateStudentSql = "UPDATE students SET matric_number = ?, programme = ?, department_name = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateStudentSql);
                pstmt.setString(1, matricNumber);
                pstmt.setString(2, programme);
                pstmt.setString(3, departmentName);
                pstmt.setInt(4, userId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            conn.close();
            response.sendRedirect("profile.jsp?status=success");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ignore) { }
            response.sendRedirect("profile.jsp?error=" + URLEncoder.encode(String.valueOf(e.getMessage()), "UTF-8"));
        }
    }
}