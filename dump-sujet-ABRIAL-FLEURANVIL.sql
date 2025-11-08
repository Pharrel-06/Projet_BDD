--------------------- Dump de la base donnée ---------------------


/* Création des tables pour les entités */

CREATE TABLE Administrateur(
    idAdministrateur int PRIMARY KEY,
    mot_de_passe varchar(20),
    idPersonne serial REFERENCES Personne(idPersonne),
);

CREATE TABLE Personne(
    idPersonne serial PRIMARY KEY,
    nom varchar(25),
    prenom varchar(25),
);

CREATE TABLE Auteur(
    email varchar(50) PRIMARY KEY,
    site_web,
    idPersonne serial REFERENCES Personne(idPersonne),
);

CREATE TABLE Comite(
    idComite serial PRIMARY KEY,
);

CREATE TABLE Revue(
    idRevue serial PRIMARY KEY,
    nom varchar(25),
    idComite REFERENCES Comite(idComite),
);

CREATE TABLE Article(
    idArticle serial PRIMARY KEY,
    nb_page int,
    annee_pub char(4),
    site_web varchar(50),
    idRevue REFERENCES Revue(idRevue),
    volume int,
    numero int,
    nom varchar(25) REFERENCES Langue(nom),
);

CREATE TABLE Langue(
    nom varchar(25) PRIMARY KEY,
);

CREATE TABLE Domaine(
    idDomaine serial PRIMARY KEY,
    nom varchar(25),
);

CREATE TABLE Laboratoire(
    idLaboratoire serial PRIMARY KEY,
    nom varchar(25),
    adresse varchar(50),
    site_web varchar(50),
    type varchar(50),
    idVille serial REFERENCES Ville(idVille),
);

CREATE TABLE Ville(
    idVille serial PRIMARY KEY,
    nom varchar(50),
    idPays serial REFERENCES Pays(idPays),
);

CREATE TABLE Pays(
    idPays serial PRIMARY KEY,
    nom varchar(50),
);

/* Création des tables pour les associations */

CREATE TABLE Comite_Auteur(
    email varchar(50) REFERENCES Auteur(email),
    idComite serial REFERENCES Comite(idComite),
    CONSTRAINT Comite_AuteurPK PRIMARY KEY (email, idComite),
);

CREATE TABLE Domaine_Article(
    idDomaine serial REFERENCES Domaine(idDomaine),
    idArticle serial REFERENCES Article(idArticle),
    CONSTRAINT Domaine_ArticlePK PRIMARY KEY (idDomaine, idArticle),
);

CREATE TABLE Cite(
    idArticle_biblio serial REFERENCES Article(idArticle),
    idArticle_cite serial REFERENCES Article(idArticle),
    CONSTRAINT CitePK PRIMARY KEY (idArticle_biblio, idArticle_cite),
);

CREATE TABLE Ecrit(
    email varchar(50) REFERENCES Auteur(email),
    idArticle serial REFERENCES Article(idArticle),
    idLaboratoire serial REFERENCES Laboratoire(idLaboratoire),
    CONSTRAINT EcritPK PRIMARY KEY (email, idArticle, idLaboratoire),
);