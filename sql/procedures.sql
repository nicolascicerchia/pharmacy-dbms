USE farmacia;

-- Rendiamo rieseguibile lo script

DROP PROCEDURE IF EXISTS p_cerca_medicinale;
DROP PROCEDURE IF EXISTS p_registra_vendita;
DROP PROCEDURE IF EXISTS p_registra_medicinale;
DROP PROCEDURE IF EXISTS p_registra_scatola;
DROP PROCEDURE IF EXISTS p_report_giacenza;
DROP PROCEDURE IF EXISTS p_report_scadenze;
DROP PROCEDURE IF EXISTS p_elimina_scatole_scadute;
DROP PROCEDURE IF EXISTS p_elimina_lotto;
DROP PROCEDURE IF EXISTS p_upsert_ditta;
DROP PROCEDURE IF EXISTS p_login;

-- =====================================================
-- PROCEDURE 1: cerca medicinale
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_cerca_medicinale (
    IN p_testo VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- READ COMMITTED + READ ONLY: lettura su vista con dati già confermati
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET TRANSACTION READ ONLY;

    START TRANSACTION;

    SELECT *
    FROM v_medicinali_vendibili
    -- Introduco anche il controllo per un matching parziale
    WHERE nome LIKE CONCAT('%', p_testo, '%')
    	OR nome_ditta LIKE CONCAT('%', p_testo, '%')
    	OR usi LIKE CONCAT('%', p_testo, '%');

    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 2: registra vendita
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_registra_vendita (
    IN p_cf_cliente CHAR(16),
    IN p_codice INT
)
BEGIN
    DECLARE p_id_vendita INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    -- SERIALIZABLE: evita anomalie su doppia vendita o incoerenza di disponibilità
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    START TRANSACTION;
    
    INSERT INTO vendita(cf_cliente)
    VALUES (p_cf_cliente);
    SET p_id_vendita = LAST_INSERT_ID();
    UPDATE scatola
    SET id_vendita = p_id_vendita
    WHERE codice = p_codice
    	AND id_vendita IS NULL;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Scatola non disponibile alla vendita';
    END IF;
    
    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 3: registra medicinale
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_registra_medicinale (
    IN p_nome VARCHAR(100),
    IN p_nome_ditta VARCHAR(100),
    IN p_mutuabile BOOLEAN,
    IN p_ricetta BOOLEAN
)
BEGIN
	-- DEFAULT ISOLATION LEVEL: singolo INSERT e atomicità gestita dai vicoli PK/FK
    INSERT INTO medicinale (
        nome,
        nome_ditta,
        mutuabile,
        ricetta
    )
    VALUES (
        p_nome,
        p_nome_ditta,
        p_mutuabile,
        p_ricetta
    );
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 4: registra scatola
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_registra_scatola (
    IN p_lotto VARCHAR(50),
    IN p_scadenza DATE,
    IN p_num_cassetto INT,
    IN p_num_scaffale INT,
    IN p_nome_medicinale VARCHAR(100),
    IN p_nome_ditta VARCHAR(100)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- SERIALIZABLE: INSERT su scatola e UPDATE su medicinale
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
    START TRANSACTION;

    INSERT INTO scatola (
        lotto,
        scadenza,
        num_cassetto,
        num_scaffale,
        nome_medicinale,
        nome_ditta
    )
    VALUES (
        p_lotto,
        p_scadenza,
        p_num_cassetto,
        p_num_scaffale,
        p_nome_medicinale,
        p_nome_ditta
    );
    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 5: report giacenza
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_report_giacenza ()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- READ COMMITTED + READ ONLY: lettura su vista con dati già confermati
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET TRANSACTION READ ONLY;

    START TRANSACTION;

    SELECT *
    FROM v_report_giacenza;

    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 6: report scadenze
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_report_scadenze ()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL;
	END;
	-- READ COMMITTED + READ ONLY: lettura su vista con dati già confermati
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET TRANSACTION READ ONLY;
	
	START TRANSACTION;
	
	SELECT *
	FROM v_report_scadenze;
	
	COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 7: registra/aggiorna ditta
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_upsert_ditta (
    IN p_nome_ditta VARCHAR(100),
    IN p_via_comune VARCHAR(150),
    IN p_di_fatturazione BOOLEAN,
    IN p_valore VARCHAR(50),
    IN p_tipo VARCHAR(20),
    IN p_preferito BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- READ COMMITTED: UPSERT su più tabelle
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    START TRANSACTION;

    INSERT IGNORE INTO ditta (nome_ditta)
	VALUES (p_nome_ditta);

    INSERT INTO indirizzo (
        nome_ditta,
        via_comune,
        di_fatturazione
    )
    VALUES (
        p_nome_ditta,
        p_via_comune,
        p_di_fatturazione
    )
    ON DUPLICATE KEY UPDATE
        di_fatturazione = VALUES(di_fatturazione);

    INSERT INTO recapito (
        nome_ditta,
        valore,
        tipo,
        preferito
    )
    VALUES (
        p_nome_ditta,
        p_valore,
        p_tipo,
        p_preferito
    )
    ON DUPLICATE KEY UPDATE
        tipo = VALUES(tipo),
        preferito = VALUES(preferito);

    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 8: elimina scatole scadute
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_elimina_scatole_scadute ()
BEGIN
	DECLARE righe_eliminate INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- READ COMMITTED: eliminazione su più righe
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    START TRANSACTION;

    DELETE FROM scatola
    WHERE id_vendita IS NULL
    	AND scadenza <= DATE_ADD(CURDATE(), INTERVAL 4 MONTH);
    
    SET righe_eliminate = ROW_COUNT();

    IF righe_eliminate = 0 THEN
        SELECT 'Non erano presenti farmaci scaduti' AS messaggio;
    ELSE
        SELECT CONCAT('Eliminate ', righe_eliminate, ' scatole scadute') AS messaggio;
    END IF;
    
    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 9: elimina lotto
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_elimina_lotto (
    IN p_lotto VARCHAR(50),
    IN p_nome_medicinale VARCHAR(100)
)
BEGIN
	DECLARE righe_eliminate INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
	-- READ COMMITTED: eliminazione su più righe
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    START TRANSACTION;

    DELETE FROM scatola
    WHERE lotto = p_lotto
    	AND nome_medicinale = p_nome_medicinale
    	AND id_vendita IS NULL;
    
    SET righe_eliminate = ROW_COUNT();

    IF righe_eliminate = 0 THEN
        SELECT 'Non erano presenti lotti fallati per questo medicinale' AS messaggio;
    ELSE
        SELECT CONCAT('Eliminate ', righe_eliminate, ' scatole del lotto indicato') AS messaggio;
    END IF;

    COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE 10: login
-- =====================================================

DELIMITER $$

CREATE PROCEDURE p_login (
    IN p_username VARCHAR(45),
    IN p_password CHAR(32)
)
BEGIN
	-- DEFAULT ISOLATION LEVEL: singola lettura con nessuna modifica dati
    SELECT ruolo
    FROM utenti
    WHERE username = p_username
    	AND password = MD5(p_password);
END$$

DELIMITER ;






