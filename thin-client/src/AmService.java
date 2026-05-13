import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;

public class AmService {

    // =========================
    // AM2 - Upsert ditta
    // =========================
    public void upsertDitta(String nome_ditta, String via_comune, boolean di_fatturazione,
                           String valore, String tipo, boolean preferito) {

        String sql = "{CALL p_upsert_ditta(?, ?, ?, ?, ?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, nome_ditta);
            cs.setString(2, via_comune);
            cs.setBoolean(3, di_fatturazione);
            cs.setString(4, valore);
            cs.setString(5, tipo);
            cs.setBoolean(6, preferito);

            cs.execute();

            System.out.println("Ditta salvata correttamente.");

        } catch (Exception e) {
            System.out.println("Errore salvataggio ditta: " + e.getMessage());
        }
    }

    // =========================
    // AM1 - Registra medicinale
    // =========================
    public void registraMedicinale(String nome, String nome_ditta,
                                   boolean mutuabile, boolean ricetta) {

        String sql = "{CALL p_registra_medicinale(?, ?, ?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, nome);
            cs.setString(2, nome_ditta);
            cs.setBoolean(3, mutuabile);
            cs.setBoolean(4, ricetta);

            cs.execute();

            System.out.println("Medicinale registrato.");

        } catch (Exception e) {
            System.out.println("Errore registrazione medicinale: " + e.getMessage());
        }
    }

    // =========================
    // AM4 - Rifornimento scatola
    // =========================
    public void registraScatola(String lotto, String scadenza,
                                int num_cassetto, int num_scaffale,
                                String nome_medicinale, String nome_ditta) {

        String sql = "{CALL p_registra_scatola(?, ?, ?, ?, ?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, lotto);
            cs.setDate(2, Date.valueOf(scadenza));
            cs.setInt(3, num_cassetto);
            cs.setInt(4, num_scaffale);
            cs.setString(5, nome_medicinale);
            cs.setString(6, nome_ditta);

            cs.execute();

            System.out.println("Scatola registrata.");

        } catch (Exception e) {
            System.out.println("Errore registrazione scatola: " + e.getMessage());
        }
    }

    // =========================
    // AM3 - Report giacenza
    // =========================
    public void reportGiacenza() {
        String sql = "{CALL p_report_giacenza()}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            System.out.println("\n--- REPORT GIACENZA ---");

            while (rs.next()) {
                System.out.println("----------------------");
                System.out.println("Nome: " + rs.getString("nome"));
                System.out.println("Ditta: " + rs.getString("nome_ditta"));
                System.out.println("Giacenza: " + rs.getInt("giacenza_tot"));
            }

        } catch (Exception e) {
            System.out.println("Errore report giacenza: " + e.getMessage());
        }
    }

    // =========================
    // AM5 - Report scadenze
    // =========================
    public void reportScadenze() {
        String sql = "{CALL p_report_scadenze()}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            System.out.println("\n--- REPORT SCADENZE ---");

            boolean trovato = false;

            while (rs.next()) {
                trovato = true;

                System.out.println("----------------------");
                System.out.println("Nome: " + rs.getString("nome_medicinale"));
                System.out.println("Ditta: " + rs.getString("nome_ditta"));
                System.out.println("Scadenza: " + Main.Utils.scriviData(rs.getString("scadenza")));
                System.out.println("Scaffale: " + rs.getInt("num_scaffale"));
                System.out.println("Cassetto: " + rs.getInt("num_cassetto"));
                System.out.println("Codice: " + rs.getInt("codice"));
                System.out.println("Lotto: " + rs.getString("lotto"));
            }

            if (!trovato) {
                System.out.println("Non ci sono medicinali scaduti o in scadenza.");
            }
        } catch (Exception e) {
            System.out.println("Errore report scadenze: " + e.getMessage());
        }
    }

    // =========================
    // AM6 - Elimina scatole
    // =========================
    public void eliminaScatole() {
        String sql = "{CALL p_elimina_scatole_scadute()}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    System.out.println(rs.getString("messaggio"));
                }
            }
        } catch (Exception e) {
            System.out.println("Errore eliminazione scaduti: " + e.getMessage());
        }
    }

    // =========================
    // AM7 - Elimina lotto
    // =========================
    public void eliminaLotto(String nome_medicinale, String lotto) {
        String sql = "{CALL p_elimina_lotto(?, ?)}";

        try (Connection conn = Db.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, nome_medicinale);
            cs.setString(2, lotto);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    System.out.println(rs.getString("messaggio"));
                }
            }
        } catch (Exception e) {
            System.out.println("Errore eliminazione lotto: " + e.getMessage());
        }
    }
}
