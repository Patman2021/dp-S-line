-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S7: Indexen
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------
-- LET OP, zoals in de opdracht op Canvas ook gezegd kun je informatie over
-- het query plan vinden op: https://www.postgresql.org/docs/current/using-explain.html

-- S7.1.
--
-- Je maakt alle opdrachten in de 'sales' database die je hebt aangemaakt en gevuld met
-- de aangeleverde data (zie de opdracht op Canvas).
--
-- Voer het voorbeeld uit wat in de les behandeld is:
-- 1. Voer het volgende EXPLAIN statement uit:
--    EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;
--    Bekijk of je het resultaat begrijpt. Kopieer het explain plan onderaan de opdracht
-- 2. Voeg een index op stock_item_id toe:
--    CREATE INDEX ord_lines_si_id_idx ON order_lines (stock_item_id);
-- 3. Analyseer opnieuw met EXPLAIN hoe de query nu uitgevoerd wordt
--    Kopieer het explain plan onderaan de opdracht
-- 4. Verklaar de verschillen. Schrijf deze hieronder op.


    --Eerste explain
    --"Gather  (cost=1000.00..6151.37 rows=1001 width=96)"
    --"  Workers Planned: 2"
    --"  ->  Parallel Seq Scan on order_lines  (cost=0.00..5051.27 rows=417 width=96)"
    --"        Filter: (stock_item_id = 9)"

    -- Tweede explain
    --"Bitmap Heap Scan on order_lines  (cost=12.05..2292.81 rows=1001 width=96)"
    --"  Recheck Cond: (stock_item_id = 9)"
    --"  ->  Bitmap Index Scan on ord_lines_si_id_idx  (cost=0.00..11.80 rows=1001 width=0)"
    --"        Index Cond: (stock_item_id = 9)"

    -- Omdat de Index gesorteerd staat in een aparte tabel   kan er een binary search gedaan worden, hierdoor gaat het zoeken vele male sneller
    --en kan in dit geval de  id snel gevonden worden en de data uit de normale tabel gehaald worden.
    -- De zonder index search moet door alle data heel lopen om het op te zoeken, omdat het niet gesorteerd staat
    CREATE INDEX ord_lines_si_id_idx ON order_lines (stock_item_id);

    EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;
    EXPLAIN SELECT * FROM ord_lines_si_id_idx WHERE stock_item_id = 9;

-- S7.2.
--
-- 1. Maak de volgende twee query’s:
-- 	  A. Toon uit de order tabel de order met order_id = 73590
-- 	  B. Toon uit de order tabel de order met customer_id = 1028
-- 2. Analyseer met EXPLAIN hoe de query’s uitgevoerd worden en kopieer het explain plan onderaan de opdracht
-- 3. Verklaar de verschillen en schrijf deze op
-- 4. Voeg een index toe, waarmee query B versneld kan worden
-- 5. Analyseer met EXPLAIN en kopieer het explain plan onder de opdracht
-- 6. Verklaar de verschillen en schrijf hieronder op

    EXPLAIN  SELECT  FROM orders WHERE order_id= 73590

    --"Index Scan using pk_sales_orders on orders  (cost=0.29..8.31 rows=1 width=155)"
       -- "  Index Cond: (order_id = 73590)"

    EXPLAIN  SELECT * FROM orders WHERE customer_id= 1028

    --"Seq Scan on orders  (cost=0.00..1819.94 rows=105 width=155)"
        --"  Filter: (customer_id = 1028)"

    --3: order_id is een primary key en hierdoor is er automatisch een index gemaakt en kon er een binary search op gezet worden in de index tabel.

    --4:
    CREATE INDEX orders_customer_id_index
    ON orders (customer_id )
        --
        -- 5.Na een index toevegen op customer_id:
        --"Bitmap Heap Scan on orders  (cost=5.11..306.42 rows=105 width=155)"
          --  "  Recheck Cond: (customer_id = 1028)"
        --"  ->  Bitmap Index Scan on orders_customer_id_index  (cost=0.00..5.08 rows=105 width=0)"
        --"        Index Cond: (customer_id = 1028)"

        -- 6.Er zijn wat extra lijnen bijgekomen die je krijgt als je zelf een index aanmaakt.
        -- je ziet dat de cost  bij  na de index veel sneller is [(cost=0.00..5.08 rows=105 width=0)" en voorheen
        -- --(cost=0.00..1819.94 rows=105 width=155)"  ] Je ziet ook twee keer een "scan on onders" dit komt omdat
        -- we de data eerst uit de index tabel moeten halen en daarna  met de customer_id alle data ophalen  in de normale tabel


-- S7.3.A
--
-- Het blijkt dat customers regelmatig klagen over trage bezorging van hun bestelling.
-- Het idee is dat verkopers misschien te lang wachten met het invoeren van de bestelling in het systeem.
-- Daar willen we meer inzicht in krijgen.
-- We willen alle orders (order_id, order_date, salesperson_person_id (als verkoper),
--    het verschil tussen expected_delivery_date en order_date (als levertijd),  
--    en de bestelde hoeveelheid van een product zien (quantity uit order_lines).
-- Dit willen we alleen zien voor een bestelde hoeveelheid van een product > 250
--   (we zijn nl. als eerste geïnteresseerd in grote aantallen want daar lijkt het vaker mis te gaan)
-- En verder willen we ons focussen op verkopers wiens bestellingen er gemiddeld langer over doen.
-- De meeste bestellingen kunnen binnen een dag bezorgd worden, sommige binnen 2-3 dagen.
-- Het hele bestelproces is er op gericht dat de gemiddelde bestelling binnen 1.45 dagen kan worden bezorgd.
-- We willen in onze query dan ook alleen de verkopers zien wiens gemiddelde levertijd 
--  (expected_delivery_date - order_date) over al zijn/haar bestellingen groter is dan 1.45 dagen.
-- Maak om dit te bereiken een subquery in je WHERE clause.
-- Sorteer het resultaat van de hele geheel op levertijd (desc) en verkoper.
-- 1. Maak hieronder deze query (als je het goed doet zouden er 377 rijen uit moeten komen, en het kan best even duren...)

SELECT o.order_id , o.order_date , salesperson_person_id as verkoper,
       expected_delivery_date - order_date as vertraging, picked_quantity
FROM orders o

         JOIN order_lines ol on o.order_id= ol.order_id
WHERE (SELECT AVG(o2.expected_delivery_date - o2.order_date)
       FROM orders o2
       WHERE o2.salesperson_person_id = o.salesperson_person_id)

    > 1.45

  AND ol.picked_quantity > 250
ORDER BY vertraging DESC, salesperson_person_id

-- S7.3.B
--
-- 1. Vraag het EXPLAIN plan op van je query (kopieer hier, onder de opdracht)
-- 2. Kijk of je met 1 of meer indexen de query zou kunnen versnellen
-- 3. Maak de index(en) aan en run nogmaals het EXPLAIN plan (kopieer weer onder de opdracht) 
-- 4. Wat voor verschillen zie je? Verklaar hieronder.

    --1:    "Sort  (cost=1599532.63..1599533.35 rows=285 width=20)"
    --"  Sort Key: ((o.expected_delivery_date - o.order_date)) DESC, o.salesperson_person_id"
    --"  ->  Nested Loop  (cost=0.29..1599521.01 rows=285 width=20)"
    --"        ->  Seq Scan on order_lines ol  (cost=0.00..6738.65 rows=856 width=8)"
    --"              Filter: (picked_quantity > 250)"
    --"        ->  Index Scan using pk_sales_orders on orders o  (cost=0.29..1860.73 rows=1 width=16)"
    --"              Index Cond: (order_id = ol.order_id)"
    --"              Filter: ((SubPlan 1) > 1.45)"
    --"              SubPlan 1"
    --"                ->  Aggregate  (cost=1856.74..1856.75 rows=1 width=32)"
    --"                      ->  Seq Scan on orders o2  (cost=0.00..1819.94 rows=7360 width=8)"
    --"                            Filter: (salesperson_person_id = o.salesperson_person_id)"

    --3:
    CREATE INDEX orders_salesperson_id_index
        ON orders (salesperson_person_id)

    --        "Sort  (cost=963862.69..963863.41 rows=285 width=20)"
    --"  Sort Key: ((o.expected_delivery_date - o.order_date)) DESC, o.salesperson_person_id"
    --"  ->  Nested Loop  (cost=0.29..963851.07 rows=285 width=20)"
    --"        ->  Seq Scan on order_lines ol  (cost=0.00..6738.65 rows=856 width=8)"
    --"              Filter: (picked_quantity > 250)"
    --"        ->  Index Scan using pk_sales_orders on orders o  (cost=0.29..1118.12 rows=1 width=16)"
    --"              Index Cond: (order_id = ol.order_id)"
    --"              Filter: ((SubPlan 1) > 1.45)"
    --"              SubPlan 1"
    --"                ->  Aggregate  (cost=1114.13..1114.14 rows=1 width=32)"
    ---"                      ->  Bitmap Heap Scan on orders o2  (cost=85.33..1077.33 rows=7360 width=8)"
    --"                            Recheck Cond: (salesperson_person_id = o.salesperson_person_id)"
    --"                            ->  Bitmap Index Scan on orders_salesperson_id_index  (cost=0.00..83.49 rows=7360 width=0)"
    --"                                  Index Cond: (salesperson_person_id = o.salesperson_person_id)"

    --4: Door deze eene index toe te voegen  ging de query complete tijd van 6.978 seconden naar 2.009,
    --hierdoor is het opzoeken ruim 3 keer zo snel.



-- S7.3.C
--
-- Zou je de query ook heel anders kunnen schrijven om hem te versnellen?
   -- in de subqueary werd verwezen naar een alias, toen alias weggehaald had was deze  0,3 seconden  sneller. Toen ik nog extra views ging
   -- toevoegen werd het zelfs slommer.

SELECT o.order_id , o.order_date , salesperson_person_id as verkoper,
       expected_delivery_date - order_date as vertraging, picked_quantity
FROM orders o

         JOIN order_lines ol on o.order_id= ol.order_id
WHERE (SELECT AVG(o2.expected_delivery_date - o2.order_date)
       FROM orders o2
       WHERE salesperson_person_id = o.salesperson_person_id)

    > 1.45

  AND ol.picked_quantity > 250
ORDER BY vertraging DESC, salesperson_person_id


