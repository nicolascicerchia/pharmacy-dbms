USE farmacia;

-- Rendiamo rieseguibile lo script

DROP TABLE IF EXISTS scatola;
DROP TABLE IF EXISTS utilizzo;
DROP TABLE IF EXISTS medicinale;
DROP TABLE IF EXISTS recapito;
DROP TABLE IF EXISTS indirizzo;
DROP TABLE IF EXISTS vendita;
DROP TABLE IF EXISTS uso;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS ditta;
DROP TABLE IF EXISTS utenti;

-- Tabella utenti del sistema
-- Gestisce autenticazione e ruoli (AM = amministrativo, PM = personale medico)

CREATE TABLE utenti (
    username VARCHAR(45) PRIMARY KEY,
    password CHAR(32) NOT NULL,
    ruolo ENUM('AM', 'PM') NOT NULL
);

-- Tabella delle ditte fornitrici dei medicinali

CREATE TABLE ditta (
    nome_ditta VARCHAR(100) PRIMARY KEY
);

-- Tabella clienti con identificazione tramite codice fiscale

CREATE TABLE cliente (
    cf CHAR(16) PRIMARY KEY
);

-- Tipologie di utilizzo del medicinale

CREATE TABLE uso (
    tipo VARCHAR(50) PRIMARY KEY
);

-- Tabella delle vendite effettuate
-- Ogni vendita può includere più scatole

CREATE TABLE vendita (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cf_cliente CHAR(16),
    FOREIGN KEY (cf_cliente) REFERENCES cliente(cf)
);

-- Indirizzi associati a una ditta
-- Una ditta può avere più indirizzi, ma uno solo di fatturazione

CREATE TABLE indirizzo (
    nome_ditta VARCHAR(100),
    via_comune VARCHAR(150),
    di_fatturazione BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (nome_ditta, via_comune),
    FOREIGN KEY (nome_ditta) REFERENCES ditta(nome_ditta)
);

-- Recapiti della ditta
-- Una ditta può avere più recapiti, ma uno solo preferito

CREATE TABLE recapito (
    nome_ditta VARCHAR(100),
    valore VARCHAR(50),
    tipo VARCHAR(20),
    preferito BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (nome_ditta, valore),
    FOREIGN KEY (nome_ditta) REFERENCES ditta(nome_ditta)
);

-- Tabella dei medicinali
-- Identificati da nome e nome_ditta
-- giacenza_tot è una ridondanza per ottimizzare le query

CREATE TABLE medicinale (
    nome VARCHAR(100),
    nome_ditta VARCHAR(100),
    mutuabile BOOLEAN NOT NULL,
    ricetta BOOLEAN NOT NULL,
    giacenza_tot INT NOT NULL DEFAULT 0,
    PRIMARY KEY (nome, nome_ditta),
    FOREIGN KEY (nome_ditta) REFERENCES ditta(nome_ditta),
    CHECK (giacenza_tot >= 0)
);

-- Tabella ponte tra medicinale e uso (relazione molti-a-molti)

CREATE TABLE utilizzo (
    nome_medicinale VARCHAR(100),
    nome_ditta VARCHAR(100),
    tipo VARCHAR(50),
    PRIMARY KEY (nome_medicinale, nome_ditta, tipo),
    FOREIGN KEY (nome_medicinale, nome_ditta)
        REFERENCES medicinale(nome, nome_ditta),
    FOREIGN KEY (tipo)
        REFERENCES uso(tipo)
);

-- Rappresenta la singola confezione fisica di un medicinale
-- Contiene lotto, scadenza e posizione fisica
-- id_vendita NULL = disponibile, NOT NULL = venduta

CREATE TABLE scatola (
    codice INT AUTO_INCREMENT PRIMARY KEY,
    lotto VARCHAR(50) NOT NULL,
    scadenza DATE NOT NULL,
    num_cassetto INT NOT NULL,
    num_scaffale INT NOT NULL,
    nome_medicinale VARCHAR(100) NOT NULL,
    nome_ditta VARCHAR(100) NOT NULL,
    id_vendita INT,
    FOREIGN KEY (nome_medicinale, nome_ditta)
        REFERENCES medicinale(nome, nome_ditta),
    FOREIGN KEY (id_vendita)
        REFERENCES vendita(id)
);

