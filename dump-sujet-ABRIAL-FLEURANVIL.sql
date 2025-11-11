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
    idPersonne serial REFERENCES personne(idPersonne)
);

CREATE TABLE comite(
    idComite serial PRIMARY KEY,
    nom varchar(25)
);

CREATE TABLE revue(
    idRevue serial PRIMARY KEY,
    nom varchar(25),
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
    nom varchar(25) REFERENCES langue(nom)
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
    nom varchar(25),
    adresse varchar(50),
    site_web varchar(50),
    type varchar(50),
    idVille serial REFERENCES ville(idVille)
);

/* Création des tables pour les associations */

CREATE TABLE comite_auteur(
    email varchar(50) REFERENCES auteur(email),
    idComite serial REFERENCES comite(idComite),
    CONSTRAINT Comite_AuteurPK PRIMARY KEY (email, idComite)
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
    CONSTRAINT EcritPK PRIMARY KEY (email, idArticle, idLaboratoire)
);

/* Définition des vues */
CREATE VIEW domaine_populaire (nom, nombre_articles) AS (
    SELECT nom, COUNT(*) AS nombre_articles
    FROM domaine_article NATURAL JOIN domaine NATURAL JOIN article
    GROUP BY annee_pub
    ORDER BY nombre_articles DESC
);


/* Insertion des données dans les tables */

INSERT INTO personne (nom, prenom) VALUES
('FLeuranvil', 'Pharrel'),
('Abrial', 'Tom'),
('Nanthagobal', 'Iraijalagan');

INSERT INTO administrateur (idAdministrateur, mot_de_passe, idPersonne) VALUES
(1, 'adminpass1', 1);

INSERT INTO auteur (email, site_web, idPersonne) VALUES
('fleuranvil@gmail.com', 'www.fleuranvil.com', 1),
('abrial@gmail.com', 'www.abrial.com', 2);

INSERT INTO comite (nom) VALUES
('Comité Scientifique');

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
('Mathématiques');

INSERT INTO pays (nom) VALUES
('France'),
('États-Unis');

INSERT INTO ville (nom, idPays) VALUES
('Paris', 1),
('New York', 2);

INSERT INTO laboratoire (nom, adresse, site_web, type, idVille) VALUES
('Lab Informatique', '123 Rue de Paris', 'www.labinfo.com', 'Public', 1),
('Lab Mathématiques', '456 Avenue de New York', 'www.labmaths.com', 'Privé', 2);

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


