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
    mot_de_passe varchar(20),
    idPersonne serial REFERENCES personne(idPersonne)
);

CREATE TABLE auteur(
    email varchar(50) PRIMARY KEY,
    site_web varchar(50),
    idPersonne serial REFERENCES personne(idPersonne),
    CONSTRAINT Verif_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT Verif_site_web CHECK (site_web LIKE 'www.%')
);

CREATE TABLE comite(
    idComite serial PRIMARY KEY,
    nom varchar(50)
);

CREATE TABLE revue(
    idRevue serial PRIMARY KEY,
    nom varchar(50),
    idComite serial REFERENCES comite(idComite)
);

CREATE TABLE langue(
    nom varchar(25) PRIMARY KEY
);

CREATE TABLE article(
    idArticle serial PRIMARY KEY,
    nb_page int,
    annee_pub char(4),
    site_web varchar(50),
    idRevue serial REFERENCES revue(idRevue),
    volume int,
    numero int,
    nom varchar(25) REFERENCES langue(nom),
    CONSTRAINT nb_page_positive CHECK (nb_page > 0),
    CONSTRAINT Verif_site_web_article CHECK (site_web LIKE 'www.%'),
    CONSTRAINT volume_positive CHECK (volume > 0),
    CONSTRAINT numero_positive CHECK (numero > 0)
);

CREATE TABLE domaine(
    idDomaine serial PRIMARY KEY,
    nom varchar(25)
);

CREATE TABLE pays(
    idPays serial PRIMARY KEY,
    nom varchar(50)
);

CREATE TABLE ville(
    idVille serial PRIMARY KEY,
    nom varchar(50),
    idPays serial REFERENCES pays(idPays)
);

CREATE TABLE laboratoire(
    idLaboratoire serial PRIMARY KEY,
    nom varchar(50),
    adresse varchar(50),
    site_web varchar(50),
    type varchar(50),
    idVille serial REFERENCES ville(idVille),
    CONSTRAINT Verif_site_web_laboratoire CHECK (site_web LIKE 'www.%')
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
CREATE VIEW domaine_populaire (annee, nom, nombre_articles) AS
    SELECT a.annee_pub, d.nom, COUNT(*) AS nombre_articles
    FROM domaine_article AS da
    JOIN domaine AS d ON da.idDomaine = d.idDomaine
    JOIN article AS a ON da.idArticle = a.idArticle
    GROUP BY a.annee_pub, d.nom 
    ORDER BY a.annee_pub DESC;


/* Insertion des données dans les tables */

INSERT INTO personne (nom, prenom) VALUES
('FLeuranvil', 'Pharrel'),
('Abrial', 'Tom'),
('Brenchemmacher', 'Alexandre'),
('Sengphrachanh', 'Gabriel'),
('Ben Malek', 'Amine'),
('Nanthagobal', 'Iraijalagan');

INSERT INTO administrateur (idAdministrateur, mot_de_passe, idPersonne) VALUES
(1, 'adminpass1', 1);

INSERT INTO auteur (email, site_web, idPersonne) VALUES
('fleuranvil@gmail.com', 'www.fleuranvil.com', 1),
('abrial@gmail.com', 'www.abrial.com', 2),
('Brenchenmmacher@gmail.com', 'www.brenchenmmacher.com', 3),
('Sengphrachanh@gmail.com', 'www.sengphrachanh.com', 4),
('BenMalek@gmail.com', 'www.benmalek.com', 5),
('Nanthagobal@gmail.com', 'www.nanthagobal.com', 6);

INSERT INTO comite (nom) VALUES
('Comité Scientifique Eiffel');

INSERT INTO revue (nom, idComite) VALUES
('Revue des Sciences', 1);

INSERT INTO langue (nom) VALUES
('Français'),
('Anglais');

INSERT INTO article (nb_page, annee_pub, site_web, idRevue, volume, numero, nom) VALUES
(10, '2020', 'www.bdd.com', 1, 5, 2, 'Français'),
(15, '2021', 'www.algebre.com', 1, 6, 1, 'Anglais');

INSERT INTO domaine (nom) VALUES
('Informatique'),
('Electronique'),
('Mathématiques'),
('Physique'),
('Histoire des Arts');

INSERT INTO pays (nom) VALUES
('France'),
('États-Unis');

INSERT INTO ville (nom, idPays) VALUES
('Paris', 1),
('Champs-sur-Marne', 1),
('Lyon', 1),
('New York', 2),
('San Francisco', 2),
('Chicago', 2),
('Boston', 2),
('Seattle', 2),
('Los Angeles', 2),
('Miami', 2);

INSERT INTO laboratoire (nom, adresse, site_web, type, idVille) VALUES
('Lab Informatique Eiffel', '5 bd Decartes', 'www.labinfo-eiffel.com', 'universite', 1),
('Lab National des Mathématiques', '456 Avenue de Paris', 'www.labmaths-paris.com', 'labo', 2);

INSERT INTO comite_auteur (email, idComite) VALUES
('fleuranvil@gmail.com', 1),
('abrial@gmail.com', 1);

INSERT INTO domaine_article (idDomaine, idArticle) VALUES
(1, 1),
(2, 2);

INSERT INTO cite (idArticle_biblio, idArticle_cite) VALUES
(1, 2),
(2, 1);

INSERT INTO ecrit (email, idArticle, idLaboratoire) VALUES
('fleuranvil@gmail.com', 1, 1),
('abrial@gmail.com', 2, 1);

-- Fin du dump de la base donnée --