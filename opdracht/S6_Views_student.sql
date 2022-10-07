-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
--     CREATE OR REPLACE VIEW personeel AS
-- 	     SELECT mnr, voorl, naam as medewerker, afd, functie
--       FROM medewerkers;
-- 3. Is de view "deelnemers" updatable ? Waarom ?
--      De view deelnemers bestaat uit twee tabellen hierdoor valt niet exact te achterhalen welke data waar uitkomt,
--      hierdoor kan je het niet updaten. Bij personeel kan het wel

CREATE OR REPLACE VIEW personeel AS
    SELECT mnr, voorl, naam as medewerker, afd, functie
    FROM medewerkers;

CREATE OR REPLACE VIEW deelnemers AS
    SELECT DISTINCT inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
    FROM inschrijvingen
    INNER JOIN uitvoeringen ON uitvoeringen.begindatum = inschrijvingen.begindatum AND uitvoeringen.cursus= inschrijvingen.cursus;

SELECT personeel.mnr ,personeel.voorl, personeel.medewerker,
deelnemers.begindatum, deelnemers.docent, deelnemers.locatie
FROM personeel
INNER JOIN deelnemers ON deelnemers.cursist= personeel.mnr;


-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen: 
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt. 
-- 2. Maak een tweede view met de naam "daguitvoeringen". 
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen:
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt.
-- 2. Maak een tweede view met de naam "daguitvoeringen".
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT


Create OR REPLACE VIEW dagcursussen AS
    SELECT cursussen.code, cursussen.omschrijving, cursussen.type FROM cursussen
    WHERE cursussen.lengte = 1
    ORDER BY cursussen.code;


CREATE OR REPLACE VIEW daguitvoeringen AS
    SELECT uitvoeringen.cursus, uitvoeringen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
    FROM uitvoeringen
    INNER JOIN dagcursussen ON dagcursussen.code = uitvoeringen.cursus
    ORDER BY uitvoeringen.begindatum

SELECT * FROM dagcursussen

SELECT * FROM daguitvoeringen

-- RESTRICT zorgt ervoor dat je het alleen kan verwijderen als
-- er geen andere objecten(view) gebruik van maken
DROP VIEW IF EXISTS dagcursussen RESTRICT

--CASCADE zorgt ervoor dat deze view maar ook de onderliggende
--Objecten verwijderd worden die hier afhankelijk  van zijn
DROP VIEW IF EXISTS dagcursussen CASCADE

