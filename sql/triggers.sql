USE farmacia;

-- Rendiamo rieseguibile lo script

DROP TRIGGER IF EXISTS recapito_preferito_unico_insert;
DROP TRIGGER IF EXISTS recapito_preferito_unico_update;
DROP TRIGGER IF EXISTS indirizzo_preferito_unico_insert;
DROP TRIGGER IF EXISTS indirizzo_preferito_unico_update;
DROP TRIGGER IF EXISTS giacenza_incremento_scatola;
DROP TRIGGER IF EXISTS giacenza_update_scatola;
DROP TRIGGER IF EXISTS blocco_vendita_scadenza;

-- =====================================================
-- TRIGGER 1: recapito preferito unico su inserimento
-- =====================================================

DELIMITER $$

CREATE TRIGGER recapito_preferito_unico_insert
BEFORE INSERT ON recapito
FOR EACH ROW
BEGIN
	IF NEW.preferito = TRUE THEN
		IF (
			SELECT COUNT(*)
			FROM recapito
			WHERE nome_ditta = NEW.nome_ditta
				AND preferito = TRUE
		) > 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Esiste già un recapito preferito per questa ditta';
		END IF;
	END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 2: recapito preferito su aggiornamento
-- =====================================================

DELIMITER $$

CREATE TRIGGER recapito_preferito_unico_update
BEFORE UPDATE ON recapito
FOR EACH ROW
BEGIN
    IF NEW.preferito = TRUE AND OLD.preferito = FALSE THEN
        IF (
            SELECT COUNT(*)
            FROM recapito
            WHERE nome_ditta = NEW.nome_ditta
            	AND preferito = TRUE
            	AND NOT (nome_ditta = OLD.nome_ditta AND valore = OLD.valore)
        ) > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esiste già un recapito preferito per questa ditta';
        END IF;
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 3: indirizzo preferito unico su inserimento
-- =====================================================

DELIMITER $$

CREATE TRIGGER indirizzo_preferito_unico_insert
BEFORE INSERT ON indirizzo
FOR EACH ROW
BEGIN
	IF NEW.di_fatturazione = TRUE THEN
		IF (
			SELECT COUNT(*)
			FROM indirizzo
			WHERE nome_ditta = NEW.nome_ditta
				AND di_fatturazione = TRUE
		) > 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Esiste già un indirizzo di fatturazione per questa ditta';
		END IF;
	END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 4: indirizzo preferito su aggiornamento
-- =====================================================

DELIMITER $$

CREATE TRIGGER indirizzo_preferito_unico_update
BEFORE UPDATE ON indirizzo
FOR EACH ROW
BEGIN
    IF NEW.di_fatturazione = TRUE AND OLD.di_fatturazione = FALSE THEN
        IF (
            SELECT COUNT(*)
            FROM indirizzo
            WHERE nome_ditta = NEW.nome_ditta
            	AND di_fatturazione = TRUE
            	AND NOT (nome_ditta = OLD.nome_ditta AND via_comune = OLD.via_comune)
        ) > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esiste già un indirizzo di fatturazione per questa ditta';
        END IF;
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 5: giacenza su inserimento scatola
-- =====================================================

DELIMITER $$

CREATE TRIGGER giacenza_incremento_scatola
AFTER INSERT ON scatola
FOR EACH ROW
BEGIN
    IF NEW.id_vendita IS NULL THEN
        UPDATE medicinale
        SET giacenza_tot = giacenza_tot + 1
        WHERE nome = NEW.nome_medicinale
        	AND nome_ditta = NEW.nome_ditta;
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 6: giacenza su vendita/annullamento scatola
-- =====================================================

DELIMITER $$

CREATE TRIGGER giacenza_decremento_scatola
AFTER UPDATE ON scatola
FOR EACH ROW
BEGIN
	-- CASO 1: vendita
	IF OLD.id_vendita IS NULL AND NEW.id_vendita IS NOT NULL THEN
		UPDATE medicinale
		SET giacenza_tot = giacenza_tot - 1
		WHERE nome = NEW.nome_medicinale
			AND nome_ditta = NEW.nome_ditta;
	END IF;
	-- CASO 2: reso/annullamento vendita
	IF OLD.id_vendita IS NOT NULL AND NEW.id_vendita IS NULL THEN
		UPDATE medicinale
		SET giacenza_tot = giacenza_tot + 1
		WHERE nome = NEW.nome_medicinale
			AND nome_ditta = NEW.nome_ditta;
	END IF;
END$$

DELIMITER ;

-- =====================================================
-- TRIGGER 7: blocco vendita per scadenza
-- =====================================================

DELIMITER $$

CREATE TRIGGER blocco_vendita_scadenza
BEFORE UPDATE ON scatola
FOR EACH ROW
BEGIN
	-- fase di vendita
	IF OLD.id_vendita IS NULL AND NEW.id_vendita IS NOT NULL THEN
		-- controllo scadenza
		IF NEW.scadenza <= DATE_ADD(CURDATE(), INTERVAL 4 MONTH) THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vendita non consentita: scatola scaduta o con scadenza inferiore a 4 mesi';
        END IF;
	END IF;
END$$

DELIMITER ;














