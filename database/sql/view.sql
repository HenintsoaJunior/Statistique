CREATE VIEW Mois AS
WITH RECURSIVE MoisRec AS (
    SELECT 1 AS numero, 'Janvier' AS nom
    UNION ALL
    SELECT numero + 1, 
        CASE numero + 1
            WHEN 2 THEN 'Février'
            WHEN 3 THEN 'Mars'
            WHEN 4 THEN 'Avril'
            WHEN 5 THEN 'Mai'
            WHEN 6 THEN 'Juin'
            WHEN 7 THEN 'Juillet'
            WHEN 8 THEN 'Août'
            WHEN 9 THEN 'Septembre'
            WHEN 10 THEN 'Octobre'
            WHEN 11 THEN 'Novembre'
            WHEN 12 THEN 'Décembre'
        END
    FROM MoisRec
    WHERE numero < 12
)
SELECT numero AS mois_num, nom AS mois_nom
FROM MoisRec;


--------------------------------------------Annee et Mois----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_annees_et_mois AS
WITH Years AS (
    SELECT DISTINCT EXTRACT(YEAR FROM date_insertion) AS annee FROM Utilisateur
    UNION
    SELECT DISTINCT EXTRACT(YEAR FROM date_achat) AS annee FROM achat_pack
),
Months AS (
    SELECT Mois.mois_num, Mois.mois_nom FROM Mois
)
SELECT
    y.annee,
    m.mois_num,
    m.mois_nom
FROM
    Years y
CROSS JOIN
    Months m;

--------------------------------------------Nombre de Client par an-------------------------------------------------------------

CREATE OR REPLACE VIEW V_evolution_nombreclients AS
SELECT
    vm.mois_nom AS mois,
    COALESCE(COUNT(u.id_utilisateur), 0) AS nombre_clients,
    vm.annee,
    ARRAY_AGG(vm.mois_num ORDER BY vm.mois_num) AS mois_num_array
FROM
    V_annees_et_mois vm
LEFT JOIN
    Utilisateur u ON vm.mois_num = EXTRACT(MONTH FROM u.date_insertion)
    AND vm.annee = EXTRACT(YEAR FROM u.date_insertion)
GROUP BY
    vm.mois_nom, vm.annee
ORDER BY
    vm.annee, mois_num_array;



SELECT * FROM V_evolution_nombreclients WHERE annee = '2024';

--------------------------------------------Nombre de Client ayant achetes les pack par mois-------------------------------------------------------------

CREATE OR REPLACE VIEW V_evolution_nombreclientsayantachetespack AS
SELECT
    vm.mois_nom AS mois,
    COALESCE(COUNT(DISTINCT ap.id_utilisateur), 0) AS nombre_clients_ayant_achete_pack,
    vm.annee,
    ARRAY_AGG(vm.mois_num ORDER BY vm.mois_num) AS mois_num_array
FROM
    V_annees_et_mois vm
LEFT JOIN
    achat_pack ap ON vm.mois_num = EXTRACT(MONTH FROM ap.date_achat)
    AND vm.annee = EXTRACT(YEAR FROM ap.date_achat)
GROUP BY
    vm.mois_nom, vm.annee
ORDER BY
    vm.annee, mois_num_array;

SELECT * FROM V_evolution_nombreclientsayantachetespack WHERE annee = '2024';

--------------------------------------------Revenue mensuel-------------------------------------------------------------

CREATE OR REPLACE VIEW V_evolution_revenu_mensuel AS
SELECT
    vm.mois_nom AS mois,
    SUM(COALESCE(ec.nombre_clients, 0)) AS nombre_clients,
    SUM(COALESCE(eap.nombre_clients_ayant_achete_pack, 0)) AS nombre_clients_ayant_achete_pack,
    vm.annee,
    ARRAY_AGG(vm.mois_num ORDER BY vm.mois_num) AS mois_num_array,
    COALESCE(SUM(ap.prix), 0) AS revenu_mensuel
FROM
    V_annees_et_mois vm
LEFT JOIN
    V_evolution_nombreclients ec ON vm.mois_nom = ec.mois
    AND vm.annee = ec.annee
LEFT JOIN
    V_evolution_nombreclientsayantachetespack eap ON vm.mois_nom = eap.mois
    AND vm.annee = eap.annee
LEFT JOIN
    achat_pack ap ON vm.mois_num = EXTRACT(MONTH FROM ap.date_achat)
    AND vm.annee = EXTRACT(YEAR FROM ap.date_achat)
GROUP BY
    vm.mois_nom, vm.annee
ORDER BY
    vm.annee, mois_num_array;


---------------------------------------------Total Revenue et Moyenne By Year--------------------------------------------------------------
CREATE OR REPLACE VIEW V_total_moyenne_revenu_mensuel AS
SELECT
    vm.annee,
    COALESCE(SUM(revenu_mensuel), 0) AS total_revenu_mensuel,
    COALESCE(AVG(revenu_mensuel), 0) AS moyenne_revenu_mensuel
FROM
    V_evolution_revenu_mensuel vm
GROUP BY
    vm.annee
ORDER BY
    vm.annee;


---------------------------------------------Total Revenue et Moyenne By Year--------------------------------------------------------------
CREATE OR REPLACE VIEW V_total_moyenne_revenu AS
SELECT
    COALESCE(SUM(revenu_mensuel), 0) AS total_revenu_mensuel,
    COALESCE(AVG(revenu_mensuel), 0) AS moyenne_revenu_mensuel
FROM
    V_evolution_revenu_mensuel;


