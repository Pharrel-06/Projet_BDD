--------------------- Dump de la base donnée ---------------------

DROP TABLE IF EXISTS administrateur CASCADE;
DROP TABLE IF EXISTS personne CASCADE;
DROP TABLE IF EXISTS auteur CASCADE;
DROP TABLE IF EXISTS comite CASCADE;
DROP TABLE IF EXISTS revue CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS langue CASCADE;
DROP TABLE IF EXISTS domaine CASCADE;
DROP TABLE IF EXISTS laboratoire CASCADE;
DROP TABLE IF EXISTS ville CASCADE;
DROP TABLE IF EXISTS pays CASCADE;
DROP TABLE IF EXISTS comite_Auteur CASCADE;
DROP TABLE IF EXISTS domaine_Article CASCADE;
DROP TABLE IF EXISTS cite CASCADE;
DROP TABLE IF EXISTS ecrit CASCADE; 

/* Création des tables pour les entités */

CREATE TABLE personne(
    idPersonne serial PRIMARY KEY,
    nom varchar(25),
    prenom varchar(25)
);

CREATE TABLE administrateur(
    idAdministrateur int PRIMARY KEY,
    mot_de_passe varchar(20) NOT NULL,
    idPersonne serial REFERENCES personne(idPersonne)
);

CREATE TABLE auteur(
    email varchar(50) PRIMARY KEY,
    site_web_auteur varchar(50),
    idPersonne serial REFERENCES personne(idPersonne),
    CONSTRAINT Verif_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT Verif_site_web CHECK (site_web_auteur LIKE 'www.%')
);

CREATE TABLE comite(
    idComite serial PRIMARY KEY,
    nom_comite varchar(50)
);

CREATE TABLE revue(
    idRevue serial PRIMARY KEY,
    nom_revue varchar(50),
    idComite serial REFERENCES comite(idComite)
);

CREATE TABLE langue(
    nom_langue varchar(25) PRIMARY KEY
);

CREATE TABLE article(
    idArticle serial PRIMARY KEY,
    nb_page int default 1 NOT NULL,
    annee_pub char(4) NOT NULL,
    site_web_article varchar(50),
    idRevue serial REFERENCES revue(idRevue),
    volume int default 1,
    numero int default 1,
    nom_langue varchar(25) REFERENCES langue(nom_langue),
    CONSTRAINT nb_page_positive CHECK (nb_page > 0),
    CONSTRAINT Verif_site_web_article CHECK (site_web_article LIKE 'www.%'),
    CONSTRAINT volume_positive CHECK (volume > 0),
    CONSTRAINT numero_positive CHECK (numero > 0)
);

CREATE TABLE domaine(
    idDomaine serial PRIMARY KEY,
    nom_domaine varchar(25)
);

CREATE TABLE pays(
    idPays serial PRIMARY KEY,
    nom_pays varchar(50)
);

CREATE TABLE ville(
    idVille serial PRIMARY KEY,
    nom_ville varchar(50),
    idPays serial REFERENCES pays(idPays)
);

CREATE TABLE laboratoire(
    idLaboratoire serial PRIMARY KEY,
    nom_laboratoire varchar(50),
    adresse varchar(50),
    site_web_laboratoire varchar(50),
    type varchar(50),
    idVille serial REFERENCES ville(idVille),
    CONSTRAINT Verif_site_web_laboratoire CHECK (site_web_laboratoire LIKE 'www.%')
);

/* Création des tables pour les associations */

CREATE TABLE comite_auteur(
    email varchar(50) REFERENCES auteur(email),
    idComite serial REFERENCES comite(idComite),
    CONSTRAINT Comite_AuteurPK PRIMARY KEY (email, idComite),
    CONSTRAINT Verif_email_comite_auteur CHECK (email LIKE '%@%.%')
);

CREATE TABLE domaine_article(
    idDomaine serial REFERENCES domaine(idDomaine),
    idArticle serial REFERENCES article(idArticle),
    CONSTRAINT Domaine_ArticlePK PRIMARY KEY (idDomaine, idArticle)
);

CREATE TABLE cite(
    idArticle_biblio serial REFERENCES article(idArticle),
    idArticle_cite serial REFERENCES article(idArticle),
    CONSTRAINT CitePK PRIMARY KEY (idArticle_biblio, idArticle_cite)
);

CREATE TABLE ecrit(
    email varchar(50) REFERENCES auteur(email),
    idArticle serial REFERENCES article(idArticle),
    idLaboratoire serial REFERENCES laboratoire(idLaboratoire),
    CONSTRAINT EcritPK PRIMARY KEY (email, idArticle, idLaboratoire),
    CONSTRAINT Verif_email_ecrit CHECK (email LIKE '%@%.%')
);

/* Définition des vues */
CREATE VIEW domaine_populaire AS
    WITH domaine_par_annee AS (
        SELECT a.annee_pub AS annee, d.nom_domaine AS domaine, COUNT(*) AS nombre_articles
        FROM domaine_article da
        JOIN domaine d ON da.idDomaine = d.idDomaine
        JOIN article a ON da.idArticle = a.idArticle
        WHERE a.annee_pub >= '2015'
        GROUP BY a.annee_pub, d.nom_domaine
    ), 
    domaine_max_par_annee AS (
        SELECT annee, MAX(nombre_articles) AS max_articles
        FROM domaine_par_annee
        GROUP BY annee
    )
    SELECT dpa.annee, dpa.domaine, dpa.nombre_articles
    FROM domaine_par_annee AS dpa 
    JOIN domaine_max_par_annee AS dma ON dma.annee = dpa.annee AND dpa.nombre_articles = dma.max_articles
    ORDER BY dpa.annee DESC;

CREATE VIEW auteur_affluant AS
    WITH nb_ref_auteur AS (        
        SELECT email, idLaboratoire, COUNT(email) AS nb_articles FROM ecrit GROUP BY email, idLaboratoire
    ),
    nb_max_ref AS (
        SELECT idLaboratoire, MAX(nb_articles) AS max_articles FROM nb_ref_auteur GROUP BY idLaboratoire
    )
    SELECT email, nra.idLaboratoire, nb_articles
    FROM nb_ref_auteur AS nra
    JOIN nb_max_ref AS nmr ON nmr.idLaboratoire = nra.idLaboratoire AND nra.nb_articles = nmr.max_articles
    ORDER BY nmr.idLaboratoire;


/* Insertion des données dans les tables */
INSERT INTO personne (nom, prenom) VALUES
('FLeuranvil', 'Pharrel'),
('Abrial', 'Tom'),
('Francis', 'Nadime'),
('Brenchemmacher', 'Alexandre'),
('Sengphrachanh', 'Gabriel'),
('Ben Malek', 'Amine'),
('Larivière', 'Mathéo'),
('Nanthagobal', 'Iraijalagan');

INSERT INTO administrateur (idAdministrateur, mot_de_passe, idPersonne) VALUES
(1, 'adminpass1', 1);

INSERT INTO auteur (email, site_web_auteur, idPersonne) VALUES
('Fleuranvil@gmail.com', 'www.fleuranvil.com', 1),
('Abrial@gmail.com', 'www.abrial.com', 2),
('Francis@gmail.com', 'www.francis.com', 3),
('Brenchenmmacher@gmail.com', 'www.brenchenmmacher.com', 4),
('Sengphrachanh@gmail.com', 'www.sengphrachanh.com', 5),
('BenMalek@gmail.com', 'www.benmalek.com', 6),
('Lariviere@gmail.com', 'www.lariviere.com', 7),
('Nanthagobal@gmail.com', 'www.nanthagobal.com', 8);

INSERT INTO comite (nom_comite) VALUES
('Comité Scientifique Eiffel'),
('Comité Scientifique Paris'),
('Comité Scientifique USA'),
('Comité Scientifique International');

INSERT INTO revue (nom_revue, idComite) VALUES
('Revue des Sciences Eiffel', 1),
('Revue des Sciences Françaises', 2),
('Revue JO', 2),
('Revue des Sciences Américaines', 3),
('Revue Internationale des Sciences', 4),
('Revue Médicale', 2);

INSERT INTO langue (nom_langue) VALUES
('Français'),
('Anglais');

INSERT INTO article (nb_page, annee_pub, site_web_article, idRevue, volume, numero, nom_langue) VALUES
(10, '2020', 'www.bdd-l2.com', 1, 5, 2, 'Français'), --1
(5, '2020', 'www.bdd-l3.com', 1, 5, 2, 'Français'), 
(12, '2015', 'www.systeme-embarque.com', 4, 4, 3, 'Anglais'),
(15, '2020', 'www.algebre-l2.com', 1, 6, 1, 'Français'),
(8, '2015', 'www.physique.com', 4, 3, 4, 'Anglais'), --5
(3, '2025', 'www.physique-quantique.com', 4, 7, 1, 'Anglais'),
(20, '2014', 'www.algebre-complexe.com', 2, 2, 1, 'Français'),
(7, '2013', 'www.sport-sante.com', 3, 1, 1, 'Français'),
(9, '2021', 'www.electronique-avancee.com', 4, 5, 2, 'Anglais'),
(11, '2024', 'www.JO2024-paris.com', 3, 4, 3, 'Français'), --10
(6, '2024', 'www.JO2028-los-angeles.com', 3, 3, 2, 'Anglais'),
(14, '2017', 'www.maths-appliquees.com', 1, 2, 1, 'Français'),
(4, '2016', 'www.physique-spatiale.com', 5, 1, 1, 'Anglais'),
(13, '2022', 'www.informatique-quantique.com', 2, 6, 2, 'Anglais'),
(16, '2023', 'www.data-science.com', 4, 7, 3, 'Anglais'), --15
(18, '2024', 'www.machine-learning.com', 5, 8, 1, 'Anglais'),
(22, '2010', 'www.sport-automobile.com', 4, 5, 4, 'Français'),
(19, '2024', 'www.sport-et-santé.com', 6, 4, 2, 'Français'),
(21, '2018', 'www.santé-alimentation.com', 6, 3, 3, 'Français'),
(17, '2017', 'www.satellite.com', 5, 2, 2, 'Anglais'); --20


INSERT INTO domaine (nom_domaine) VALUES
('Informatique'),
('Electronique'),
('Mathématiques'),
('Physique'),
('Sport'),
('Médecine');

INSERT INTO pays (nom_pays) VALUES
('France'),
('États-Unis');

INSERT INTO ville (nom_ville, idPays) VALUES
('Paris', 1),
('Champs-sur-Marne', 1),
('Lyon', 1),
('New York', 2),
('San Francisco', 2), --5
('Chicago', 2),
('Boston', 2),
('Seattle', 2),
('Los Angeles', 2), --10
('Miami', 2);

INSERT INTO laboratoire (nom_laboratoire, adresse, site_web_laboratoire, type, idVille) VALUES
('Lab Eiffel', '5 bd Decartes', 'www.lab-eiffel.com', 'universite', 2),
('Lab National des Mathématiques', '456 Avenue de Paris', 'www.labmaths-paris.com', 'labo', 1),
('Lab Electronique Avancée', '789 Rue de la Science', 'www.labelectronique.com', 'centre de recherche', 4),
('Lab Recherche médical', '321 Boulevard Sorbonne', 'www.lab-recherche-medical.com', 'universite', 3),
('Lab Sport et Santé', '654 Avenue des Athlètes', 'www.lab-sport-sante.com', 'centre de recherche', 1),
('Lab Science International', '987 Rue des Ordinateurs', 'www.lab-science-international.com', 'labo', 10);

INSERT INTO comite_auteur (email, idComite) VALUES
('Fleuranvil@gmail.com', 1),
('Abrial@gmail.com', 1);

INSERT INTO domaine_article (idDomaine, idArticle) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 3),
(4, 3),
(3, 4),
(4, 5),
(4, 6),
(3, 7),
(5, 8),
(2, 9),
(5, 10),
(5, 11),
(1, 12),
(3, 12),
(4, 13),
(1, 14),
(4, 14),
(1, 15),
(3, 15),
(1, 16),
(2, 16),
(2, 17),
(5, 17),
(5, 18),
(6, 18),
(6, 19),
(1, 20),
(2, 20),
(4, 20);

INSERT INTO cite (idArticle_biblio, idArticle_cite) VALUES
(2, 1),
(4, 7),
(3, 5);

INSERT INTO ecrit (email, idArticle, idLaboratoire) VALUES
('Francis@gmail.com',         1, 1),
('Fleuranvil@gmail.com',      1, 2),
('Francis@gmail.com',         2, 1),
('BenMalek@gmail.com',        3, 3),
('Nanthagobal@gmail.com',     4, 1), 
('Fleuranvil@gmail.com',      5, 2),
('Lariviere@gmail.com',       6, 4),
('Nanthagobal@gmail.com',     7, 2),
('Brenchenmmacher@gmail.com', 8, 5),
('BenMalek@gmail.com',        9, 3), 
('Brenchenmmacher@gmail.com', 10, 4),
('Brenchenmmacher@gmail.com', 11, 4),
('Nanthagobal@gmail.com',     12, 2),
('Fleuranvil@gmail.com',      13, 6),
('Lariviere@gmail.com',       14, 6),
('Abrial@gmail.com',          15, 6),
('Nanthagobal@gmail.com',     15, 6),
('Abrial@gmail.com',          16, 6),
('Sengphrachanh@gmail.com',   17, 5),
('Sengphrachanh@gmail.com',   18, 5),
('Sengphrachanh@gmail.com',   19, 5),
('Abrial@gmail.com',       20, 6);



-- Fin du dump de la base donnée --

-- SELECT * FROM ecrit WHERE email = 'Nanthagobal@gmail.com';
