import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Scanner;

public class Main {

    private static final Scanner scanner = new Scanner(System.in);
    private static final AuthService authService = new AuthService();
    private static final PmService pmService = new PmService();
    private static final AmService amService = new AmService();

    public static void main(String[] args) {

        System.out.println("=== Gestionale Farmacia ===");

        // =========================
        // LOGIN
        // =========================
        String username = stringaObbligatoria("Username: ");

        String password = stringaObbligatoria("Password: ");

        String ruolo = authService.login(username, password);

        if (ruolo == null) {
            System.out.println("Login fallito.");
            return;
        }

        System.out.println("Login riuscito. Ruolo: " + ruolo);

        // ==============================
        // SERVICE IN FUNZIONE DEL RUOLO
        // ==============================
        if (ruolo.equals("AM")) {
            menuAmministrativo();
        } else if (ruolo.equals("PM")) {
            menuPersonaleMedico();
        } else {
            System.out.println("Ruolo non riconosciuto.");
        }
    }

    // =========================
    // MENU AM
    // =========================
    private static void menuAmministrativo() {

        int scelta;

        do {
            System.out.println("\n--- MENU AMMINISTRATIVO ---");
            System.out.println("1. Registra/aggiorna ditta");
            System.out.println("2. Registra medicinale");
            System.out.println("3. Registra scatola");
            System.out.println("4. Report giacenza");
            System.out.println("5. Report scadenze");
            System.out.println("6. Elimina scatole scadute");
            System.out.println("7. Elimina lotto");
            System.out.println("0. Esci");

            scelta = leggiIntero("Scelta: ");

            switch (scelta) {
                case 1:
                    String nome_ditta = stringaObbligatoria("Nome ditta: ");

                    String indirizzo = stringaObbligatoria("Indirizzo: ");

                    boolean fatturazione = leggiSiNo("Indirizzo di fatturazione (sì/no): ");

                    String recapito = stringaObbligatoria("Recapito: ");

                    String tipo = stringaObbligatoria("Tipo recapito: ");

                    boolean preferito = leggiSiNo("Preferito (sì/no): ");

                    amService.upsertDitta(nome_ditta, indirizzo, fatturazione, recapito, tipo, preferito);
                    break;

                case 2:
                    String nome_medicinale = stringaObbligatoria("Nome medicinale: ");

                    String ditta = stringaObbligatoria("Ditta: ");

                    boolean mutuabile = leggiSiNo("Mutuabile (sì/no): ");

                    boolean ricetta = leggiSiNo("Richiede ricetta (sì/no): ");

                    amService.registraMedicinale(nome_medicinale, ditta, mutuabile, ricetta);
                    break;

                case 3:
                    String lotto = stringaObbligatoria("Lotto: ");

                    String scadenza = leggiData("Scadenza (DD-MM-YYYY): ");

                    int cassetto = leggiIntero("Cassetto: ");

                    int scaffale = leggiIntero("Scaffale: ");

                    String medicinale = stringaObbligatoria("Medicinale: ");

                    String nomeDitta = stringaObbligatoria("Ditta: ");

                    amService.registraScatola(lotto, scadenza, cassetto, scaffale, medicinale, nomeDitta);
                    break;

                case 4:
                    amService.reportGiacenza();
                    break;

                case 5:
                    amService.reportScadenze();
                    break;

                case 6:
                    amService.eliminaScatole();
                    break;

                case 7:
                    String nomeMedicinale = stringaObbligatoria("Medicinale: ");
                    String lottoFallato = stringaObbligatoria("Inserisci lotto da eliminare: ");
                    amService.eliminaLotto(nomeMedicinale, lottoFallato);
                    break;
                case 0:
                    System.out.println("Uscita...");
                    break;
                default:
                    System.out.println("Scelta non valida.");
            }

        } while (scelta != 0);
    }

    // =========================
    // MENU PM
    // =========================
    private static void menuPersonaleMedico() {

        int scelta;

        do {
            System.out.println("\n--- MENU PERSONALE MEDICO ---");
            System.out.println("1. Cerca medicinale");
            System.out.println("2. Registra vendita");
            System.out.println("0. Esci");

            scelta = leggiIntero("Scelta: ");

            switch (scelta) {
                case 1:
                    String testo = stringaObbligatoria("Cerca medicinale/ditta/uso: ");
                    pmService.cercaMedicinale(testo);
                    break;
                case 2:
                    int codice = leggiIntero("Codice scatola scannerizzato: ");

                    String cf_cliente = stringaOpzionale("Codice fiscale cliente (INVIO anche con nessuna registrazione): ");

                    pmService.registraVendita(cf_cliente, codice);
                    break;
                case 0:
                    System.out.println("Uscita...");
                    break;
                default:
                    System.out.println("Scelta non valida.");
            }

        } while (scelta != 0);
    }

    // =============================
    // LETTURA STRINGA OBBLIGATORIA
    // =============================
    private static String stringaObbligatoria(String messaggio) {
        while (true) {
            System.out.print(messaggio);
            String stringa = scanner.nextLine().trim();

            if (!stringa.isEmpty()) {
                return stringa;
            }

            System.out.println("Campo obbligatorio. Riprova.");
        }
    }

    // =============================
    // LETTURA STRINGA OPZIONALE
    // =============================
    private static String stringaOpzionale(String messaggio) {
        System.out.print(messaggio);
        String stringa = scanner.nextLine().trim();

        return stringa.isEmpty() ? null : stringa;
    }

    // =============================
    // LETTURA INTERO
    // =============================
    private static int leggiIntero(String messaggio) {
        while (true) {
            System.out.print(messaggio);
            String intero = scanner.nextLine().trim();

            try {
                return Integer.parseInt(intero);
            } catch (NumberFormatException e) {
                System.out.println("Valore non valido. Inserisci un numero intero.");
            }
        }
    }

    // =============================
    // LETTURA DATA
    // =============================
    private static String leggiData(String messaggio) {
        DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        while (true) {
            System.out.print(messaggio);
            String input_data = scanner.nextLine().trim();

            try {
                LocalDate data = LocalDate.parse(input_data, inputFormatter);
                return data.format(outputFormatter);
            } catch (DateTimeParseException e) {
                System.out.println("Data non valida.");
            }
        }
    }

    // =============================
    // LETTURA SI/NO
    // =============================
    private static boolean leggiSiNo(String messaggio) {
        while (true) {
            System.out.print(messaggio);
            String si_no = scanner.nextLine().trim().toLowerCase();

            if (si_no.equals("si") || si_no.equals("sì") || si_no.equals("s")) {
                return true;
            }

            if (si_no.equals("no") || si_no.equals("n")) {
                return false;
            }

            System.out.println("Risposta non valida. Scrivi sì oppure no.");
        }
    }

    // Sezione dedicata a funzioni utilizzabili tra i vari file java
    public class Utils {

        // =============================
        // LEGGI SI/NO
        // =============================
        public static String scriviSiNo(boolean valore) {
            return valore ? "Sì" : "No";
        }

        // =============================
        // SCRITTURA DATA
        // =============================
        public static String scriviData(String data_db) {
            DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

            try {
                LocalDate data = LocalDate.parse(data_db, inputFormatter);
                return data.format(outputFormatter);
            } catch (Exception e) {
                return data_db;
            }
        }
    }
}