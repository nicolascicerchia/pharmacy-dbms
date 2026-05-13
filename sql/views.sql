USE farmacia;

-- =====================================================
-- VIEW 1: ricerca medicinali
-- =====================================================

CREATE OR REPLACE VIEW v_medicinali_vendibili AS
SELECT
	m.nome,
    m.nome_ditta,
    m.mutuabile,
    m.ricetta,
    m.giacenza_tot,

    COUNT(DISTINCT CASE
        WHEN s.id_vendita IS NULL
        	AND s.scadenza > DATE_ADD(CURDATE(), INTERVAL 4 MONTH)
        THEN s.codice
    END) AS scatole_vendibili,

    GROUP_CONCAT(DISTINCT u.tipo ORDER BY u.tipo SEPARATOR ', ') AS usi,
    MIN(s.num_scaffale) AS num_scaffale,
    MIN(s.num_cassetto) AS num_cassetto
    
FROM medicinale m
LEFT JOIN scatola s
    ON s.nome_medicinale = m.nome
   	AND s.nome_ditta = m.nome_ditta
LEFT JOIN utilizzo ut
    ON ut.nome_medicinale = m.nome
   	AND ut.nome_ditta = m.nome_ditta
LEFT JOIN uso u
    ON u.tipo = ut.tipo
GROUP BY
	m.nome,
    m.nome_ditta,
    m.mutuabile,
    m.ricetta,
    m.giacenza_tot;
    
-- =====================================================
-- VIEW 2: report giacenza
-- =====================================================

CREATE OR REPLACE VIEW v_report_giacenza AS

SELECT
    m.nome,
    m.nome_ditta,
    m.giacenza_tot
FROM medicinale m
ORDER BY
    m.nome_ditta,
    m.nome;

-- =====================================================
-- VIEW 3: report scadenze
-- =====================================================

CREATE OR REPLACE VIEW v_report_scadenze AS

SELECT
    s.codice,
    s.nome_medicinale,
    s.nome_ditta,
    s.lotto,
    s.scadenza,
    s.num_scaffale,
    s.num_cassetto
FROM scatola s
WHERE s.id_vendita IS NULL
	AND s.scadenza <= DATE_ADD(CURDATE(), INTERVAL 4 MONTH)
ORDER BY
    s.scadenza,
    s.num_scaffale,
    s.num_cassetto;







    
    