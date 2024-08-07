-- ALTER TABLE retour_client
--     ADD PRIMARY KEY (cle_retour_client),
--     ADD CONSTRAINT retour_client_produit_FK FOREIGN KEY (cle_produit) REFERENCES produit(cle_produit),
--     ADD CONSTRAINT retour_client_magasin_FK FOREIGN KEY (ref_magasin) REFERENCES magasin(ref_magasin);
-- ALTER TABLE produit
--     ADD PRIMARY KEY (cle_produit),
--     ADD CONSTRAINT produit_retour_client_FK FOREIGN KEY (cle_produit) REFERENCES retour_client(cle_produit);
-- ALTER TABLE magasin
--     ADD PRIMARY KEY (ref_magasin),
--     ADD CONSTRAINT magasin_retour_client_FK FOREIGN KEY (ref_magasin) REFERENCES retour_client(ref_magasin);
-- Step 1: Define primary keys for 'produit' and 'magasin'
-- ALTER TABLE produit
--     ADD PRIMARY KEY (cle_produit);
-- ALTER TABLE magasin
--     ADD PRIMARY KEY (ref_magasin);
-- 
-- Step 2: Define 'retour_client' with foreign keys referencing 'produit' and 'magasin'
-- ALTER TABLE retour_clients
--     ADD PRIMARY KEY (cle_retour_client),
--     ADD CONSTRAINT retour_client_produit_FK FOREIGN KEY (cle_produit) REFERENCES produit(cle_produit),
--     ADD CONSTRAINT retour_client_magasin_FK FOREIGN KEY (ref_magasin) REFERENCES magasin(ref_magasin);
-- 
 -- 1--Quel est le nombre de retour clients sur la livraison ?
 select libelle_categorie, count(*) as livraison
 From  retour_clients
 where retour_clients.libelle_categorie = 'livraison';
 -- 2-- Quelle est la liste des notes des clients sur les réseaux sociaux sur les TV ?
 -- select p.note
 -- from retour_clients
 -- where p.note like '%TV%';
SELECT retour_clients.note
FROM retour_clients
JOIN produit ON retour_clients.cle_produit = produit.cle_produit
WHERE retour_clients.libelle_source = 'réseaux sociaux' AND produit.titre_produit = 'TV';
 -- 3--Quelle est la note moyenne pour chaque typologie de produit (Classé de la meilleure à la moins bonne) ?
select p.typologie_produit ,round(avg(note),2) as moyenne_note 
from retour_clients as rc left join produit p on rc.cle_produit=p.cle_produit
group by p.typologie_produit
order by moyenne_note desc;
-- 4) - Quels sont les 5 magasins avec les meilleures notes moyennes ?
select magasin.ref_magasin, avg(retour_clients.note) as "note_moyenne" from magasin
join retour_clients on retour_clients.ref_magasin = magasin.ref_magasin
group by 1
order by 2 desc
limit 5; 
-- 5) Quels sont les magasins qui ont plus de 12 feedbacks sur le drive ?
select retour_clients.ref_magasin, count(retour_clients.libelle_categorie) from retour_clients
where retour_clients.libelle_categorie = "drive"
group by 1
having count(retour_clients.libelle_categorie)> 5
order by 2 desc;
-- 6)
select magasin.departement, avg(retour_client.note) from magasin
join retour_client on retour_client.ref_magasin = magasin.ref_magasin
group by 1 
order by 2 desc;
-- 7)
select produit.typologie_produit, round(avg(retour_client.note),2) from retour_client
join produit on produit.cle_produit = retour_client.cle_produit
where retour_client.libelle_categorie = "service après-vente"
group by 1
order by 2 desc
limit 1;
-- 8 "Quelle est la note moyenne sur l’ensemble des boissons?"retour_clientscle_retour_clientdate_achat 
select p.titre_produit ,round(avg(note),2) as moyenne_note_boisson 
from retour_clients as rc
left join produit p on rc.cle_produit=p.cle_produit
where p.titre_produit like '%Boisson%';
-- 9-- Quel est le classement des les jours de la semaine selon la meilleure expérienceen magasin ?
select dayname(date_achat) as jour, avg(note) as note_moyenne FROM retour_clients
where libelle_categorie='expérience en magasin'
group by jour
order by note_moyenne asc;
select (case WEEKDAY(retour_clients.date_achat)
    when 0  then 'Sunday'
    when 1  then 'Monday'
    when 2  then 'Tuesday'
    when 3  then 'Wednesday'
    when 4  then 'Thusday'
    when 5  then 'Friday'
    when 6  then 'Saturday'
end) as "Day", avg(retour_clients.note) as "Note_moyenne" from retour_clients
where libelle_categorie = "expérience en magasin"
group by 1
order by 2 desc;
SELECT DATE_FORMAT(date_achat, '%W') AS jour_semaine, ROUND(AVG(note),2) AS note_moyenne_jour
FROM retour_clients
WHERE libelle_categorie = 'expérience en magasin'
GROUP BY jour_semaine
ORDER BY note_moyenne_jour DESC;
-- 10-- Sur quel mois a-t-on le plus de retour sur le service après-vente ?
SELECT monthname(date_achat) as mois ,libelle_categorie , count(cle_retour_client) as nb_retour 
FROM retour_clients where libelle_categorie = 'service après-vente'
group by mois ,libelle_categorie
having libelle_categorie = 'service après-vente'
order by nb_retour desc limit 1;
SELECT DATE_FORMAT(date_achat, '%M') AS mois, COUNT(*) AS nombre_retours
FROM retour_clients
WHERE libelle_categorie = 'service après-vente'
GROUP BY mois
ORDER BY nombre_retours DESC
LIMIT 1;
-- 11-- Quel est le pourcentage de recommandation client ?
SELECT (SUM(recommandation)/count(cle_retour_client))*100 as moyenne FROM retour_clients;
SELECT round((reco_positive100/total_retour),2) as pourcentage_recommandation%, total_retour 
from(
SELECT
    SUM(CASE WHEN recommandation = TRUE THEN 1 ELSE 0 END) as reco_positive,
    SUM(CASE WHEN recommandation in (TRUE,FALSE) THEN 1 ELSE 0 END) as total_retour -- count() aussi
    FROM retour_clients )as recommandation_clients;
SELECT ROUND((COUNT(CASE WHEN recommandation THEN 1 END) / COUNT()) 100, 2) AS pourcentage_recommandation_arrondi
FROM retour_clients;
-- 12-- Quels sont les magasins qui ont une note inférieure à la moyenne ?

-- 13-- Quelles sont les typologies produits qui ont amélioré leur moyenne entre le1er et le 2eme trimestre 2021 ?
Select produit.typologie_produit as typologie, quarter(retour_client.date_achat) as trimestre, avg(retour_client.note) as moyenne 
from retour_client
join produit on produit.cle_produit = retour_client.cle_produit 
where quarter(retour_client.date_achat) in (1, 2) and year(retour_client.date_achat) = 2021
group by trimestre, typologie
having trimestre = 2 and 
       (moyenne > (select avg(note) from retour_client
                    join produit on produit.cle_produit = retour_client.cle_produit
                    where quarter(retour_client.date_achat) = 1 and year(retour_client.date_achat) = 2021));
-- 14-- Calculer le NPS. Le NPS ou Net Promoter Score sert à mesurer la propension et la probabilité derecommandation d’une marque X, d’un produit Y ou d’un service Z par ses clients. Il permet par un simple calcul d’évaluer la satisfaction et la fidélité d’un client à un moment T et desuivre l’évolution du rapport client/marque. Le Net Promoter Score est une note donnée par la clientèle en réponse à une unique question : Quelle est la probabilité que vous recommandiez la marque X/le produit Y à un de vos proches ? Calculer le NPS en se référant à cet article: https://www.qualtrics.com/fr/gestion-de-l-experience/client/nps
-- 15-- le NPS par source
-- 16-- Quel est le nombre de retour clients par source ?
-- 17-- Quels sont les 5 magasins avec le plus de feedbacks ?

-- 18-- Proposer 3 autres axes d’analyse de votre choix.
-- viandes
-- pommes de terre
-- salads, tomates
-- verdures
-- sauces
-- ognons marinées
-- haricots verts
