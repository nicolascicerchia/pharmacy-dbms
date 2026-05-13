import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Db {
    private static final String URL = "jdbc:mysql://localhost:3306/farmacia";
    // Inserire qui le proprie credenziali MySQL
    private static final String USER = "INSERIRE_USERNAME";
    private static final String PASSWORD = "INSERIRE_PASSWORD";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
