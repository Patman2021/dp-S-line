-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S2: Data Manipulation Language
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen. Draai daarna
-- alle wijzigingen in de database terug met de queries helemaal onderaan.
-- ------------------------------------------------------------------------



-- S2.1. Vier-daagse cursussen
--
-- Geef code en omschrijving van alle cursussen die precies vier dagen duren.
DROP VIEW IF EXISTS s2_1; CREATE OR REPLACE VIEW s2_1 AS
SELECT * from cursussen where lengte =4;-- [TEST]


-- S2.2. Medewerkersoverzicht
--
-- Geef alle informatie van alle medewerkers, gesorteerd op functie,
-- en per functie op leeftijd (van jong naar oud).
DROP VIEW IF EXISTS s2_2; CREATE OR REPLACE VIEW s2_2 ASSELECT * from medewerkers ORDER by functie , gbdatum DESC ;    --[TEST]



-- S2.3. Door het land
--
-- Welke cursussen zijn in Utrecht en/of in Maastricht uitgevoerd? Geef
-- code en begindatum.
DROP VIEW IF EXISTS s2_3; CREATE OR REPLACE VIEW s2_3 AS
select cursus, begindatum from uitvoeringen where locatie= 'MAASTRICHT' or  locatie = 'UTRECHT';--[TEST]


-- S2.4. Namen
--
-- Geef de naam en voorletters van alle medewerkers, behalve van R. Jansen.
DROP VIEW IF EXISTS s2_4; CREATE OR REPLACE VIEW s2_4 AS
select * from medewerkers where  naam != 'Jansen' and  voorl != 'R'; --[TEST]


-- S2.5. Nieuwe SQL-cursus
--
-- Er wordt een nieuwe uitvoering gepland voor cursus S02, en wel op de
-- komende 2 maart. De cursus wordt gegeven in Leerdam door Nick Smit.
-- Voeg deze gegevens toe.
INSERT into uitvoeringen (cursus, begindatum, docent, locatie)
VALUES ('S02', '2023-03-01',(select mnr from medewerkers where naam = 'SMIT' AND  voorl= 'N') , 'LEERDAM' )
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]


-- S2.6. Stagiairs
--
-- Neem één van je collega-studenten aan als stagiair ('STAGIAIR') en
-- voer zijn of haar gegevens in. Kies een personeelnummer boven de 8000.
INSERT  into medewerkers (mnr, naam, voorl, functie,
                          chef, gbdatum, maandsal, comm, afd)
VALUES (8010,'BOSMAN','J', 'STAGIAIR',7788,'1998-09-01',300, NULL,20 );

ON CONFLICT DO NOTHING;                                                                                         -- [TEST]


-- S2.7. Nieuwe schaal
--
-- We breiden het salarissysteem uit naar zes schalen. Voer een extra schaal in voor mensen die
-- tussen de 3001 en 4000 euro verdienen. Zij krijgen een toelage van 500 euro.
INSERT into schalen  (snr,bovengrens,ondergrens,toelage)
VALUES(6, 4000, 3001, 500);
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]


-- S2.8. Nieuwe cursus
--
-- Er wordt een nieuwe 6-daagse cursus 'Data & Persistency' in het programma opgenomen.
-- Voeg deze cursus met code 'D&P' toe, maak twee uitvoeringen in Leerdam en schrijf drie
-- mensen in.
INSERT into cursussen (code,"type",lengte,omschrijving)
VALUES('D&P','DSG', 6, 'Data & Persistency');
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]
INSERT into uitvoeringen (cursus,begindatum,docent,locatie)
VALUES('D&P', '2022-09-15', 8010, 'LEERDAM');
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]
INSERT INTO uitvoeringen (cursus,begindatum,docent,locatie)
VALUES('D&P', '2022-10-15', 8010,'LEERDAM');
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]
INSERT into inschrijvingen (begindatum,cursist,cursus,evaluatie)
VALUES('2022-09-15',7499,'D&P', NULL )
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]
INSERT into inschrijvingen (begindatum,cursist,cursus,evaluatie)
VALUES('2022-09-15',7521,'D&P', NULL )
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]
INSERT into inschrijvingen (begindatum,cursist,cursus,evaluatie)
VALUES('2022-10-15',7566,'D&P', NULL )
ON CONFLICT DO NOTHING;                                                                                      -- [TEST]
                                                                                      -- [TEST]


-- S2.9. Salarisverhoging
--
-- De medewerkers van de afdeling VERKOOP krijgen een salarisverhoging
-- van 5.5%, behalve de manager van de afdeling, deze krijgt namelijk meer: 7%.
-- Voer deze verhogingen door.
update medewerkers set maandsal = maandsal+((maandsal*5.5) / 100) where functie ='VERKOPER' and mnr != (select chef from medewerkers where functie= 'VERKOPER' LIMIT 1 );

update medewerkers set maandsal = maandsal+( (maandsal*7)/100) where mnr= (select chef from medewerkers where functie= 'VERKOPER' LIMIT 1 );


-- S2.10. Concurrent
--
-- Martens heeft als verkoper succes en wordt door de concurrent
-- weggekocht. Verwijder zijn gegevens.

-- Zijn collega Alders heeft ook plannen om te vertrekken. Verwijder ook zijn gegevens.
-- Waarom lukt dit (niet)?


delete  from medewerkers where  naam= 'MARTENS' and functie= 'VERKOPER';
delete  from medewerkers where  naam= 'ALDERS' and functie= 'VERKOPER';

-- S2.11. Nieuwe afdeling
--
-- Je wordt hoofd van de nieuwe afdeling 'FINANCIEN' te Leerdam,
-- onder de hoede van De Koning. Kies een personeelnummer boven de 8000.
-- Zorg voor de juiste invoer van deze gegevens.
INSERT into afdelingen(anr, naam, locatie, hoofd) values (60,'FINANCIEN','LEERDAM', null )
ON CONFLICT DO NOTHING;                                                                                         -- [TEST]

INSERT into medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm, afd)
values (8800, 'BOSMAN', 'JAJ','MANAGER', (SELECT mnr from medewerkers where naam = 'DE KONING')
       , '1988-09-01', 4000,null, (select  anr from afdelingen where afdelingen.naam ='FINANCIEN' ));

UPDATE afdelingen set hoofd= (select mnr from medewerkers where afd = 60 and functie= 'MANAGER')
where naam= 'FINANCIEN';

ON CONFLICT DO NOTHING;                                                                                         -- [TEST]



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S2.1') AS resultaat
UNION
SELECT 'S2.2 wordt niet getest: geen test mogelijk.' AS resultaat
UNION
SELECT * FROM test_select('S2.3') AS resultaat
UNION
SELECT * FROM test_select('S2.4') AS resultaat
UNION
SELECT * FROM test_exists('S2.5', 1) AS resultaat
UNION
SELECT * FROM test_exists('S2.6', 1) AS resultaat
UNION
SELECT * FROM test_exists('S2.7', 6) AS resultaat
ORDER BY resultaat;


-- Draai alle wijzigingen terug om conflicten in komende opdrachten te voorkomen.
UPDATE medewerkers SET afd = NULL WHERE mnr < 7369 OR mnr > 7934;
UPDATE afdelingen SET hoofd = NULL WHERE anr > 40;
DELETE FROM afdelingen WHERE anr > 40;
DELETE FROM medewerkers WHERE mnr < 7369 OR mnr > 7934;
DELETE FROM inschrijvingen WHERE cursus = 'D&P';
DELETE FROM uitvoeringen WHERE cursus = 'D&P';
DELETE FROM cursussen WHERE code = 'D&P';
DELETE FROM uitvoeringen WHERE locatie = 'LEERDAM';
INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm, afd)
VALUES (7654, 'MARTENS', 'P', 'VERKOPER', 7698, '28-09-1976', 1250, 1400, 30);
UPDATE medewerkers SET maandsal = 1600 WHERE mnr = 7499;
UPDATE medewerkers SET maandsal = 1250 WHERE mnr = 7521;
UPDATE medewerkers SET maandsal = 2850 WHERE mnr = 7698;
UPDATE medewerkers SET maandsal = 1500 WHERE mnr = 7844;
UPDATE medewerkers SET maandsal = 800 WHERE mnr = 7900;







