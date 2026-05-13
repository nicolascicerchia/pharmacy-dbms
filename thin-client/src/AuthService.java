import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;

public class AuthService {

    public String login(String username, String password) {
        String sql = "{CALL p_login(?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, username);
            cs.setString(2, password);

            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                return rs.getString("ruolo");
            } else {
                return null; // login fallito
            }

        } catch (Exception e) {
            System.out.println("Errore login: " + e.getMessage());
            return null;
        }
    }
}
