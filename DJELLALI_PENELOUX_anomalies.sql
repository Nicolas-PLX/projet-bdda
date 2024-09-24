-- Requête 1 : Evenement sans contact
\prompt '\n Recherche des Evenements sans contact possible \:'
SELECT id
FROM Evenement
WHERE telephone_contact IS NULL OR telephone_contact = ''
AND email_contact IS NULL OR email_contact = ''
AND url_contact IS NULL OR url_contact = '';

-- Requête 2 : Recherche des événements sans adresse liée
\prompt '\nRecherche des événements sans adresse liée \:'
SELECT id, e.nom_du_lieu
FROM Evenement e
LEFT JOIN Adresse a ON e.nom_du_lieu = a.nom_du_lieu
WHERE a.nom_du_lieu IS NULL;

-- Requête 3 : Recherche des événements avec des problèmes de dates
\prompt '\n Recherche des occurences d\'événements avec des dates de début supérieur ou égale à celle de fin :'
SELECT id
FROM Evenement
WHERE date_debut >= date_fin;

-- Requête 4 : Recherche des événements sans mots clés
\prompt 'Evenement sans aucun mot clés \:'
SELECT e.id, e.titre
FROM Evenement e
LEFT JOIN EvenementMotCles emc ON e.id = emc.evenement_id
WHERE emc.tag IS NULL;

-- Requête 5 : Recherche des événements sans description
\prompt 'Evenement sans description \:'
SELECT id, titre
FROM Evenement
WHERE description IS NULL OR description = '';

-- Requête 6 : Recherche des lieux sans transport associé
\prompt 'Lieux sans transport associé :'
SELECT a.nom_du_lieu
FROM Adresse a
LEFT JOIN Connecte c ON a.nom_du_lieu = c.adresse_id
WHERE c.adresse_id IS NULL;

-- Requête 7 : Evenement sans crédit image
\prompt 'Les Evenements sans crédits d\'images :'
SELECT e.id, e.titre
FROM Evenement e
LEFT JOIN EvenementImageCredits eic ON e.id = eic.evenement_id
WHERE eic.evenement_id IS NULL;

-- Requête 8 : Evenement sans programme

\prompt 'Les Evenements sans programme'
SELECT e.id, e.titre
FROM Evenement e
LEFT JOIN Programmes p ON e.id = p.evenement_id
WHERE p.evenement_id IS NULL;

-- Requête 9 : LEs Evenements sans occurence 
\prompt 'Les evenements sans occurrences'
SELECT e.id, e.titre
FROM Evenement e
LEFT JOIN Occurences o ON e.id = o.evenement_id
WHERE o.evenement_id IS NULL;

--Requête 10 : Les Evenemnts sans childrens
\prompt 'Les evenements sans childrens'
SELECT e.id, e.titre
FROM Evenement e
LEFT JOIN Childrens c ON e.id = c.evenement_id
WHERE c.evenement_id IS NULL;

