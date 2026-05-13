USE farmacia;

-- =====================================================
-- DATI NEL DATABASE FARMACIA
-- =====================================================

-- Eliminazione di dati precedenti

DELETE FROM scatola;
DELETE FROM utilizzo;
DELETE FROM medicinale;
DELETE FROM recapito;
DELETE FROM indirizzo;
DELETE FROM vendita;
DELETE FROM uso;
DELETE FROM cliente;
DELETE FROM ditta;
DELETE FROM utenti;

-- =====================================================
-- UTENTI
-- =====================================================

INSERT INTO utenti (username, password, ruolo) VALUES
('admin', MD5('admin123'), 'AM'),
('medico', MD5('medico123'), 'PM');

-- =====================================================
-- DITTE
-- =====================================================

INSERT INTO ditta (nome_ditta) VALUES
('Angelini'),
('Bayer'),
('Pfizer');

-- =====================================================
-- INDIRIZZI
-- =====================================================

INSERT INTO indirizzo (nome_ditta, via_comune, di_fatturazione) VALUES
('Angelini', 'Via Roma 10, Ancona', TRUE),
('Bayer', 'Via Milano 22, Milano', TRUE),
('Pfizer', 'Via Torino 15, Roma', TRUE);

-- =====================================================
-- RECAPITI
-- =====================================================

INSERT INTO recapito (nome_ditta, valore, tipo, preferito) VALUES
('Angelini', 'info@angelini.it', 'email', TRUE),
('Bayer', 'contatti@bayer.it', 'email', TRUE),
('Pfizer', 'contatti@pfizer.it', 'email', TRUE);

-- =====================================================
-- MEDICINALI
-- =====================================================

INSERT INTO medicinale (nome, nome_ditta, mutuabile, ricetta, giacenza_tot) VALUES
('Tachipirina', 'Angelini', TRUE, FALSE, 3),
('Aspirina', 'Bayer', FALSE, FALSE, 2),
('AntibioticoX', 'Pfizer', TRUE, TRUE, 1),
('Broncoflu', 'Angelini', FALSE, FALSE, 1);

-- =====================================================
-- USI
-- =====================================================

INSERT INTO uso (tipo) VALUES
('febbre'),
('dolore'),
('raffreddore'),
('infiammazione'),
('infezione'),
('tosse');

-- =====================================================
-- UTILIZZO
-- =====================================================

INSERT INTO utilizzo (nome_medicinale, nome_ditta, tipo) VALUES
('Tachipirina', 'Angelini', 'febbre'),
('Tachipirina', 'Angelini', 'dolore'),
('Aspirina', 'Bayer', 'dolore'),
('Aspirina', 'Bayer', 'infiammazione'),
('AntibioticoX', 'Pfizer', 'infezione'),
('Broncoflu', 'Angelini', 'raffreddore'),
('Broncoflu', 'Angelini', 'tosse');

-- =====================================================
-- CLIENTI
-- =====================================================

INSERT INTO cliente (cf) VALUES
('RSSMRA80A01H501U'),
('BNCLCU90B12H501X');

-- =====================================================
-- SCATOLE
-- =====================================================

INSERT INTO scatola (
    lotto,
    scadenza,
    num_cassetto,
    num_scaffale,
    nome_medicinale,
    nome_ditta,
    id_vendita
) VALUES
('L001', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1, 2, 'Tachipirina', 'Angelini', NULL),
('L001', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 1, 2, 'Tachipirina', 'Angelini', NULL),
('L004', DATE_ADD(CURDATE(), INTERVAL 2 MONTH), 1, 2, 'Tachipirina', 'Angelini', NULL),

('L002', DATE_ADD(CURDATE(), INTERVAL 8 MONTH), 2, 3, 'Aspirina', 'Bayer', NULL),
('L006', DATE_ADD(CURDATE(), INTERVAL 3 MONTH), 2, 3, 'Aspirina', 'Bayer', NULL),

('L003', DATE_ADD(CURDATE(), INTERVAL 10 MONTH), 3, 1, 'AntibioticoX', 'Pfizer', NULL),

('L005', DATE_ADD(CURDATE(), INTERVAL 9 MONTH), 4, 2, 'Broncoflu', 'Angelini', NULL);



