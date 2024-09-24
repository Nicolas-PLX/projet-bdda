-- Sélection d'un événement par son titre
PREPARE selected_event AS
SELECT * FROM Evenement WHERE titre = $1;


\prompt 'Entrez le titre de l\'événement que vous recherchez : ' titl
EXECUTE selected_event(:'titl');

-- Sélection des événements dans une ville donnée
PREPARE events_in_city (TEXT) AS
SELECT * FROM Evenement
JOIN Adresse ON Evenement.nom_du_lieu = Adresse.nom_du_lieu
WHERE ville = $1;

\prompt 'Entrez le nom de la ville : ' city
EXECUTE events_in_city(:'city');

-- Sélection des événements par audience
PREPARE events_by_audience AS
SELECT * FROM Evenement
JOIN EvenementAudiences ON Evenement.id = EvenementAudiences.evenement_id
JOIN Audiences ON EvenementAudiences.audience = Audiences.audience
WHERE Audiences.audience = $1;

\prompt 'Entrez l\'audience cible (ex : "enfants") : ' aud
EXECUTE events_by_audience(:'aud');

-- Sélection des événements par mot-clé
PREPARE events_by_tag AS
SELECT * FROM Evenement
JOIN EvenementMotCles ON Evenement.id = EvenementMotCles.evenement_id
JOIN MotCles ON EvenementMotCles.tag = MotCles.tag
WHERE MotCles.tag = $1;

\prompt 'Entrez un mot-clé (ex : "musique") : ' tg
EXECUTE events_by_tag(:'tg');

-- Sélection des événements par date de début
PREPARE events_by_start_date AS
SELECT * FROM Evenement
WHERE date_debut >= $1;

\prompt 'Entrez une date de début au format "YYYY-MM-DD HH:MI:SS" : ' sd
EXECUTE events_by_start_date(:'sd'::timestamp);

PREPARE tag_count AS
SELECT MotCles.tag, COUNT(*) FROM EvenementMotCles
JOIN MotCles ON EvenementMotCles.tag = MotCles.tag
WHERE EvenementMotCles.tag = $1
GROUP BY MotCles.tag;

\prompt 'Entrez le tag : ' MotCle
EXECUTE tag_count(:'MotCle');


-- Information général des lieux d'une ville
PREPARE ville_details AS
SELECT nom_du_lieu, numero_du_lieu, adresse_du_lieu, code_postal, ville FROM Adresse WHERE ville = $1;

\prompt 'Entrez le nom de la ville : ' CityAll
EXECUTE ville_details(:'CityAll');


-- Ne marche pas tout le temps car la table Transport n'est pas bien remplis
-- Vous pouvez essayer avec le titre 'Capou x Lucci'
PREPARE event_transport AS
SELECT e.titre, e.date_debut, a.nom_du_lieu, t.numero_ligne, c.distance
FROM Evenement e
JOIN Adresse a ON e.nom_du_lieu = a.nom_du_lieu
JOIN Connecte c ON a.nom_du_lieu = c.adresse_id
JOIN Transport t ON c.distance = t.distance AND c.type_ligne = t.type_ligne
WHERE e.titre = $1
ORDER BY c.distance ASC
LIMIT 1;

\prompt 'Entrez le titre de l''événement : ' eventTitre
EXECUTE event_transport(:'eventTitre');


-- Nombre de fois qu'un lieu acceuille un event
PREPARE event_count_by_venue AS
SELECT a.nom_du_lieu, COUNT(e.id) AS event_count
FROM Evenement e
JOIN Adresse a ON e.nom_du_lieu = a.nom_du_lieu
WHERE a.nom_du_lieu = $1
GROUP BY a.nom_du_lieu;

\prompt 'Entrez le nom du lieu : ' venue
EXECUTE event_count_by_venue(:'venue');

-- Requête non paramétrée
PREPARE event_count_by_audience AS
SELECT a.audience, COUNT(e.id) AS event_count
FROM Evenement e
JOIN EvenementAudiences ea ON e.id = ea.evenement_id
JOIN Audiences a ON ea.audience = a.audience
GROUP BY a.audience;

EXECUTE event_count_by_audience;

-- Contact de l'évènement souhaité
PREPARE event_contact_by_title AS
SELECT telephone_contact, url_contact, email_contact
FROM Evenement
WHERE titre = $1;

\prompt 'Entrez le titre de l''événement : ' event_title
EXECUTE event_contact_by_title(:'event_title');

DEALLOCATE event_count_by_venue;
DEALLOCATE event_count_by_audience;
DEALLOCATE ville_details;
DEALLOCATE selected_event;
DEALLOCATE event_transport;
DEALLOCATE events_in_city;
DEALLOCATE events_by_tag;
DEALLOCATE events_by_start_date;
DEALLOCATE event_contact_by_title;
DEALLOCATE events_by_audience;