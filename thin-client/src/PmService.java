import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;

public class PmService {

    // =========================
    // PM2 - Cerca medicinale
    // =========================
    public void cercaMedicinale(String testo) {
        String sql = "{CALL p_cerca_medicinale(?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, testo);

            try (ResultSet rs = cs.executeQuery()) {
                boolean trovato = false;

                System.out.println("\n--- Risultati ricerca ---");

                while (rs.next()) {
                    trovato = true;

                    System.out.println("--------------------------------");
                    System.out.println("Nome: " + rs.getString("nome"));
                    System.out.println("Ditta: " + rs.getString("nome_ditta"));
                    System.out.println("Mutuabile: " + Main.Utils.scriviSiNo(rs.getBoolean("mutuabile")));
                    System.out.println("Ricetta: " + Main.Utils.scriviSiNo(rs.getBoolean("ricetta")));
                    System.out.println("Giacenza totale: " + rs.getInt("giacenza_tot"));
                    System.out.println("Scatole vendibili: " + rs.getInt("scatole_vendibili"));
                    System.out.println("Usi: " + rs.getString("usi"));
                    System.out.println("Scaffale: " + rs.getInt("num_scaffale"));
                    System.out.println("Cassetto: " + rs.getInt("num_cassetto"));
                }

                if (!trovato) {
                    System.out.println("Nessun medicinale trovato.");
                }
            }

        } catch (Exception e) {
            System.out.println("Errore ricerca medicinale: " + e.getMessage());
        }
    }

    // =========================
    // PM1 - Registra vendita
    // =========================
    public void registraVendita(String cf_cliente, int codice) {
        String sql = "{CALL p_registra_vendita(?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            if (cf_cliente == null || cf_cliente.isBlank()) {
                cs.setNull(1, java.sql.Types.CHAR);
            } else {
                cs.setString(1, cf_cliente);
            }

            cs.setInt(2, codice);

            cs.execute();

            System.out.println("Vendita registrata correttamente.");

        } catch (Exception e) {
            System.out.println("Errore registrazione vendita: " + e.getMessage());
        }
    }
}
