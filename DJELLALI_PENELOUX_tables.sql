DROP TABLE IF EXISTS evenement, motCles, Adresse, Transport, 
 EvenementMotCles, EvenementAudiences, Connecte,
ImageCredits, EvenementImageCredits, Childrens, Programmes, Audiences, Occurences,
 temp_evenements CASCADE;

-- Creation of 'MotCles' table
CREATE TABLE MotCles (
  tag TEXT PRIMARY KEY
);

-- Creation of 'Adresse' table
CREATE TABLE Adresse (
  nom_du_lieu TEXT PRIMARY KEY,
  numero_du_lieu TEXT NULL,
  adresse_du_lieu TEXT NULL,
  code_postal TEXT NULL,
  ville TEXT NULL,
  latitude FLOAT NULL,
  longitude FLOAT NULL
);

-- Creation of 'Transport' table
CREATE TABLE Transport (
  numero_ligne TEXT,
  nom_arret TEXT,
  distance FLOAT,
  type_ligne TEXT,
  PRIMARY KEY(distance, type_ligne)
);

-- Création de la table 'Connecte' pour lier 'Adresse' et 'Transport'
CREATE TABLE Connecte (
  adresse_id TEXT,
  distance FLOAT,
  type_ligne TEXT,
  PRIMARY KEY (adresse_id, distance, type_ligne),
  FOREIGN KEY (adresse_id) REFERENCES Adresse(nom_du_lieu),
  FOREIGN KEY (distance, type_ligne) REFERENCES Transport(distance, type_ligne)
);

-- Creation of 'Evenement' table
CREATE TABLE Evenement (
  id SERIAL PRIMARY KEY,
  url TEXT NULL,
  titre TEXT,
  chapeau TEXT NULL,
  description TEXT,
  date_debut TIMESTAMP NULL,
  date_fin TIMESTAMP NULL,
  url_image TEXT NULL,
  type_prix TEXT NULL,
  detail_prix TEXT NULL,
  url_reservation TEXT NULL,
  url_text_reservation TEXT NULL,
  date_mise_a_jour TIMESTAMP NULL,
  image_couverture TEXT NULL,
  en_ligne_address_url TEXT NULL,
  en_ligne_address_text TEXT NULL,
  acces_pmr BOOLEAN NULL,
  acces_mal_voyant BOOLEAN NULL,
  acces_mal_entendant BOOLEAN NULL,
  url_contact TEXT NULL,
  telephone_contact TEXT NULL,
  email_contact TEXT NULL,
  url_facebook TEXT NULL,
  url_twitter TEXT NULL,
  typeacces TEXT NULL,
  groupe TEXT NULL,
  nom_du_lieu TEXT REFERENCES Adresse(nom_du_lieu)
);

-- 'Audiences' table
CREATE TABLE Audiences (
  audience TEXT PRIMARY KEY
);

-- Association table for 'Evenement' and 'Audiences'
CREATE TABLE EvenementAudiences (
  evenement_id INT NOT NULL,
  audience TEXT NOT NULL,
  PRIMARY KEY (evenement_id, audience),
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id),
  FOREIGN KEY (audience) REFERENCES Audiences(audience)
);

-- Association table for 'Evenement' and 'MotCles'
CREATE TABLE EvenementMotCles (
  evenement_id INT NOT NULL,
  tag TEXT NOT NULL,
  PRIMARY KEY (evenement_id, tag),
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id),
  FOREIGN KEY (tag) REFERENCES MotCles(tag)
);

-- 'ImageCredits' table
CREATE TABLE ImageCredits (
  credit TEXT PRIMARY KEY
);

-- Association table for 'Evenement' and 'ImageCredits'
CREATE TABLE EvenementImageCredits (
  evenement_id INT NOT NULL,
  credit TEXT NOT NULL,
  PRIMARY KEY (evenement_id, credit),
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id),
  FOREIGN KEY (credit) REFERENCES ImageCredits(credit)
);

-- 'Childrens' table
CREATE TABLE Childrens (
  description TEXT PRIMARY KEY,
  lien TEXT NULL,
  evenement_id INT NOT NULL,
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id)
);

-- 'Occurences' table
CREATE TABLE Occurences (
  date_debut TIMESTAMP NULL,
  date_fin TIMESTAMP NULL,
  evenement_id INT NOT NULL,
  PRIMARY KEY (date_debut, evenement_id),
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id)
);

-- 'Programmes' table
CREATE TABLE Programmes (
  description TEXT PRIMARY KEY,
  lien TEXT NULL,
  evenement_id INT NOT NULL,
  FOREIGN KEY (evenement_id) REFERENCES Evenement(id)
);



-- Indexes for performance improvement
CREATE INDEX idx_evenement_titre ON Evenement(titre);
CREATE INDEX idx_evenement_date_debut ON Evenement(date_debut);
CREATE INDEX idx_adresse_ville ON Adresse(ville);
CREATE INDEX idx_transport_numero_ligne ON Transport(numero_ligne);
CREATE INDEX idx_childrens_description ON Childrens(description);



CREATE TEMPORARY TABLE temp_evenements (
    id SERIAL PRIMARY KEY,
    url TEXT,
    titre VARCHAR(255),
    chapeau TEXT,
    description TEXT,
    date_de_debut TIMESTAMP WITH TIME ZONE,
    date_de_fin TIMESTAMP WITH TIME ZONE,
    occurrences TEXT,
    description_de_la_date TEXT,
    url_de_l_image TEXT,
    texte_alternatif_de_l_image TEXT,
    credit_de_l_image TEXT,
    mots_cles TEXT,
    nom_du_lieu VARCHAR(255),
    adresse_du_lieu TEXT,
    code_postal VARCHAR(20) ,
    ville VARCHAR(100),
    coordonnees_geographiques TEXT,
    acces_pmr BOOLEAN,
    acces_mal_voyant BOOLEAN,
    acces_mal_entendant BOOLEAN,
    transport TEXT,
    url_contact TEXT,
    telephone_contact VARCHAR(20),
    email_contact VARCHAR(255),
    url_facebook TEXT,
    url_twitter TEXT,
    type_de_prix VARCHAR(50),
    detail_du_prix TEXT,
    typeacces VARCHAR(50),
    url_reservation TEXT,
    url_text_reservation TEXT,
    date_mise_a_jour TIMESTAMP WITH TIME ZONE,
    image_couverture TEXT,
    programmes TEXT,
    en_ligne_address_url TEXT,
    en_ligne_address_url_text TEXT,
    en_ligne_address_text TEXT,
    title_event TEXT,
    audience TEXT,
    childrens TEXT,
    groupe TEXT
);


\copy temp_evenements FROM 'que-faire-a-paris-.csv' WITH DELIMITER ';' CSV HEADER;


INSERT INTO Adresse (nom_du_lieu, numero_du_lieu,
adresse_du_lieu,code_postal,ville, latitude, longitude)
SELECT nom_du_lieu, --Comme il y a plusieurs espace, on ne peut pas simplement faire un split_part
-- De plus, On vérifie que le lieu de l'adresse n'est pas vide, car le substring à tendancce à créer des strings vide dans notre cas
CASE
        WHEN STRPOS(adresse_du_lieu, ' ') > 0 THEN SUBSTRING(adresse_du_lieu FROM 1 FOR STRPOS(adresse_du_lieu, ' ') - 1)
        ELSE NULL
    END,
    TRIM(CASE
            WHEN STRPOS(adresse_du_lieu, ' ') > 0 THEN SUBSTRING(adresse_du_lieu FROM STRPOS(adresse_du_lieu, ' ') + 1)
            ELSE adresse_du_lieu
        END),
code_postal, ville, 
cast(split_part(coordonnees_geographiques,', ', 1) as FLOAT),
cast(split_part(coordonnees_geographiques,', ', 2) as FLOAT)
FROM temp_evenements 
WHERE nom_du_lieu IS NOT NULL
ON CONFLICT (nom_du_lieu) DO NOTHING;


-- Insertion des données dans la table 'Evenement'
INSERT INTO Evenement (url, titre, chapeau, description, date_debut, date_fin, 
url_image, type_prix, detail_prix, url_reservation, url_text_reservation, 
date_mise_a_jour, image_couverture, en_ligne_address_url, en_ligne_address_text, 
acces_pmr, acces_mal_voyant, acces_mal_entendant, url_contact, telephone_contact, 
email_contact, url_facebook, url_twitter, typeacces, groupe, nom_du_lieu)

SELECT url, titre, chapeau, description, date_de_debut, date_de_fin, url_de_l_image, 
type_de_prix, detail_du_prix, url_reservation, url_text_reservation, date_mise_a_jour,
 image_couverture, en_ligne_address_url, en_ligne_address_text, acces_pmr, 
 acces_mal_voyant, acces_mal_entendant, url_contact, telephone_contact, email_contact,
  url_facebook, url_twitter, typeacces, groupe, nom_du_lieu
FROM temp_evenements;

-- On s'occupe ensuite des audiences : on insert d'abord les audiences, puis on s'occupe de la
-- liaison evenement et audiences

INSERT INTO Audiences (audience)
SELECT TRIM(UNNEST(STRING_TO_ARRAY(regexp_replace(audience, '\.$', ''), '.'))) AS audience
FROM temp_evenements
ON CONFLICT (audience) DO NOTHING;


INSERT INTO EvenementAudiences (evenement_id, audience)
SELECT e.id, TRIM(UNNEST(STRING_TO_ARRAY(regexp_replace(audience, '\.$', ''), '.'))) AS audience
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url 
ON CONFLICT (evenement_id, audience) DO NOTHING;




INSERT INTO MotCles (tag)
SELECT TRIM(UNNEST(STRING_TO_ARRAY(mots_cles, ','))) AS tag
FROM temp_evenements
ON CONFLICT (tag) DO NOTHING;

-- Insertion des données dans la table 'EvenementMotCles'
INSERT INTO EvenementMotCles (evenement_id, tag)
SELECT e.id, TRIM(UNNEST(STRING_TO_ARRAY(mots_cles, ','))) AS tag
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url
ON CONFLICT (evenement_id, tag) DO NOTHING;




INSERT INTO ImageCredits (credit)
SELECT TRIM(UNNEST(STRING_TO_ARRAY(credit_de_l_image, '/'))) as credit_de_l_image
FROM temp_evenements
ON CONFLICT (credit) DO NOTHING;
-- Insertion des données dans la table 'ImageCredits'


-- Insertion des données dans la table 'EvenementImageCredits'
INSERT INTO EvenementImageCredits (evenement_id, credit)
SELECT e.id, TRIM(UNNEST(STRING_TO_ARRAY(credit_de_l_image, '/'))) as credit_de_l_image
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url
ON CONFLICT (evenement_id, credit) DO NOTHING;





-- Insertion des données dans la table 'Childrens'
INSERT INTO Childrens (lien, description, evenement_id)
SELECT 
    regexp_replace(childrens, ' \([^)]+\)', '', 'gi'),
    regexp_replace(childrens, '^.*\((https?://[^\s]+)\).*$', '\1'),


    e.id
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url
WHERE childrens ~ '\([^)]+\)'
ON CONFLICT (description) DO NOTHING;



-- Insertion des données dans la table 'Occurences'
INSERT INTO Occurences (date_debut, date_fin, evenement_id)
SELECT to_timestamp(split_part(occurrences, '_', 1),'YYYY-MM-DDTHH24:MI:SS+TZH:TZM') AS date_debut, 
to_timestamp(split_part(occurrences, '_', 2),'YYYY-MM-DDTHH24:MI:SS+TZH:TZM') AS date_fin,
 e.id AS evenement_id
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url
WHERE occurrences IS NOT NULL
ON CONFLICT(date_debut, evenement_id) DO NOTHING;



-- Insertion des données dans la table 'Programmes'
INSERT INTO Programmes (description, lien, evenement_id)
SELECT 
    regexp_replace(programmes, ' \([^)]+\)', '', 'gi'),
    regexp_replace(programmes, '^.*\((https?://[^\s]+)\).*$', '\1'),

    e.id
FROM temp_evenements t
JOIN Evenement e ON t.url = e.url
WHERE programmes ~ '\([^)]+\)'
ON CONFLICT (description) DO NOTHING;

INSERT INTO Transport (numero_ligne, type_ligne, nom_arret, distance)
SELECT
  CASE
    WHEN transport LIKE 'M%' THEN SUBSTRING(transport FROM 'Métro -> (\d+)')
    WHEN transport LIKE 'B%' THEN SUBSTRING(transport FROM 'Bus -> (\d+)')
    WHEN transport LIKE 'V%' THEN NULL
  END,
  CASE
    WHEN transport LIKE 'M%' THEN 'Métro'
    WHEN transport LIKE 'B%' THEN 'Bus'
    WHEN transport LIKE 'V%' THEN 'Vélib'
  END,
  CASE
    WHEN transport LIKE 'M%' THEN TRIM(SPLIT_PART(transport, ':', 2))
    WHEN transport LIKE 'B%' THEN TRIM(SPLIT_PART(transport, ':', 2))
    WHEN transport LIKE 'V%' THEN TRIM(SPLIT_PART(transport, ':', 1))
  END,
    cast((regexp_matches(transport, '(\d+(\.\d+)?)m'))[1] AS FLOAT)
  FROM temp_evenements 
  WHERE transport IS NOT NULL
  ON CONFLICT (distance, type_ligne) DO NOTHING;



  INSERT INTO Connecte (adresse_id, distance, type_ligne)
  SELECT a.nom_du_lieu,
  cast((regexp_matches(transport, '(\d+(\.\d+)?)m'))[1] AS FLOAT) as distance,
  CASE
    WHEN t.transport LIKE 'M%' THEN 'Métro'
    WHEN t.transport LIKE 'B%' THEN 'Bus'
    WHEN t.transport LIKE 'V%' THEN 'Vélib'
  END
  FROM temp_evenements t
  JOIN Adresse a ON t.nom_du_lieu = a.nom_du_lieu
  WHERE t.Transport IS NOT NULL
  ON CONFLICT (adresse_id, distance, type_ligne) DO NOTHING;


DROP TABLE IF EXISTS temp_evenements;