USE farmacia;

-- Rendiamo rieseguibile lo script

DROP INDEX IF EXISTS idx_scatole_vendibili ON scatola;
DROP INDEX IF EXISTS idx_scadenza ON scatola;
DROP INDEX IF EXISTS idx_lotto ON scatola;
DROP INDEX IF EXISTS idx_utilizzo ON utilizzo;

-- Ottimizza la ricerca delle scatole vendibili di un medicinale

CREATE INDEX idx_scatole_vendibili
ON scatola(nome_medicinale, nome_ditta, id_vendita, scadenza);

-- Ottimizza il report e la ricerca per scadenza

CREATE INDEX idx_scadenza
ON scatola(scadenza);

-- Ottimizza la ricerca e rimozione per lotto

CREATE INDEX idx_lotto
ON scatola(lotto);

-- Ottimizza la ricerca di medicinali per utilizzo

CREATE INDEX idx_utilizzo
ON utilizzo(tipo);