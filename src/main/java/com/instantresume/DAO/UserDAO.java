package com.instantresume.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

import com.instantresume.VO.UserVO;


public class UserDAO {

	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	private DataSource dataFactory;

	public UserDAO() {
		try {
			Context ctx = new InitialContext();
			Context envContext = (Context) ctx.lookup("java:/comp/env");
			dataFactory = (DataSource) envContext.lookup("jdbc/mysql");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public int login(String userID, String userPW) {
		String SQL = "SELECT USER_PW FROM USER_DATA WHERE USER_ID = ?";
		try {
			conn = dataFactory.getConnection();

			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				if (rs.getString(1).equals(userPW)) {
					return -1;
				} else {
					return 0;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -2;
	}

	public void signUp(UserVO userVO) {
		String userID = userVO.getUserID();
		String userPW = userVO.getUserPW();
		String userName = userVO.getUserName();
		String emailYN = userVO.getEmailYN();
		
		if (userID != "" && userPW != "" && userName != "") {
			try {
				conn = dataFactory.getConnection();
	
				String query = "insert into user_data" + "(user_id, user_pw, user_name, email_yn) " + "values('" + userID
						+ "','" + userPW + "','" + userName + "','" + emailYN + "');";
	
				System.out.println("addUser(): " + query);
	
				pstmt = conn.prepareStatement(query);
				pstmt.executeUpdate();
	
				pstmt.close();
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		} else {
			System.out.println("signUp O");
		}
	}

	public List<UserVO> listUsers() {
		List<UserVO> list = new ArrayList<UserVO>();

		try {
			conn = dataFactory.getConnection();

			String query = "SELECT * FROM instant_resume.user_data;";
			System.out.println(query);

			pstmt = conn.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				String userID = rs.getString("user_id");
				String userPW = rs.getString("user_pw");
				String userName = rs.getString("user_name");
				String emailYN = rs.getString("EMAIL_YN");
				String profilePic = rs.getString("profile_pic");
				String joinDate = rs.getString("JOIN_DATE").substring(0, 10);

				UserVO vo = new UserVO();

				vo.setUserID(userID);
				vo.setUserPW(userPW);
				vo.setUserName(userName);
				vo.setEmailYN(emailYN);
				vo.setProfilePic(profilePic);
				vo.setJoinDate(joinDate);

				list.add(vo);
			}

			rs.close();
			pstmt.close();
			conn.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<UserVO> userInfo(String userID) {
		List<UserVO> list = new ArrayList<UserVO>();

		try {
			conn = dataFactory.getConnection();

			String query = "SELECT * FROM instant_resume.user_data where user_id = '" + userID + "';";
			System.out.println(query);

			pstmt = conn.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				String userPW = rs.getString("user_pw");
				String userName = rs.getString("user_name");
				String emailYN = rs.getString("EMAIL_YN");
				String profilePic = rs.getString("profile_pic");
				String joinDate = rs.getString("JOIN_DATE").substring(0, 10);

				UserVO vo = new UserVO();

				vo.setUserID(userID);
				vo.setUserPW(userPW);
				vo.setUserName(userName);
				vo.setEmailYN(emailYN);
				vo.setProfilePic(profilePic);
				vo.setJoinDate(joinDate);

				list.add(vo);
			}

			rs.close();
			pstmt.close();
			conn.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	

public boolean updateInfo(String userId, String userName, String oldPassword, String newPassword, String emailYN) {
    //PW 포함 업데이트
	if (checkPassword(userId, oldPassword)) {
        try {
            conn = dataFactory.getConnection();
            String query = "UPDATE USER_DATA SET user_pw = ?, user_name = ?, email_YN = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, newPassword);
            pstmt.setString(2, userName);
            pstmt.setString(3, emailYN);
            pstmt.setString(4, userId);
            pstmt.executeUpdate();
            pstmt.close();
            conn.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    return false;
}

public boolean updateInfo(String userId, String userName, String oldPassword, String emailYN) {
	//PW 제외 업데이트
	if (checkPassword(userId, oldPassword)) {
		try {
			conn = dataFactory.getConnection();
			String query = "UPDATE USER_DATA SET user_name = ?, email_YN = ? WHERE user_id = ?";
			pstmt = conn.prepareStatement(query);
			pstmt.setString(1, userName);
			pstmt.setString(2, emailYN);
			pstmt.setString(3, userId);
			pstmt.executeUpdate();
			pstmt.close();
			conn.close();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	return false;
}

	public boolean checkPassword(String userId, String oldPassword) {
	    String SQL = "SELECT USER_PW FROM USER_DATA WHERE USER_ID = ?";
	    try {
	        conn = dataFactory.getConnection();
	        pstmt = conn.prepareStatement(SQL);
	        pstmt.setString(1, userId);
	        rs = pstmt.executeQuery();
	        if (rs.next()) {
	            if (rs.getString(1).equals(oldPassword)) {
	                return true;
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return false;
	}


	public boolean deleteUser(String userID, String userPW) {
	    String SQL = "SELECT USER_PW FROM USER_DATA WHERE USER_ID = ?";

	    try {
	        conn = dataFactory.getConnection();
	        pstmt = conn.prepareStatement(SQL);
	        pstmt.setString(1, userID);
	        rs = pstmt.executeQuery();

	        if (rs.next()) {
	            if (rs.getString(1).equals(userPW)) {
	                SQL = "DELETE FROM USER_DATA WHERE USER_ID = ?";
	                pstmt = conn.prepareStatement(SQL);
	                pstmt.setString(1, userID);
	                pstmt.executeUpdate();

	                return true;
	            } else {
	                return false;
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return false;
	}

	public void setProfilePicture(String userId, String fileName) {
	    try {
	        conn = dataFactory.getConnection();
	        String query = "UPDATE USER_DATA SET profile_pic = ? WHERE user_id = ?";
	        pstmt = conn.prepareStatement(query);
	        pstmt.setString(1, fileName);
	        pstmt.setString(2, userId);
	        pstmt.executeUpdate();
	        pstmt.close();
	        conn.close();
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	}

	}

