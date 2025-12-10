import random
from flask import Flask, render_template, request, redirect, url_for, session
import db
import psycopg2

app = Flask(__name__)

@app.route("/accueil")
def accueil():
    return render_template("accueil.html")

@app.route("/recherche")
def recherche():
    critere_recherche = ["auteur", "domaine", "langue", "année publication", "revue", "laboratoire"]
    return render_template("recherche.html", critere_recherche = critere_recherche)


# Exemple simple d'affichage des auteurs
@app.route("/auteur")
def auteur():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM auteur NATURAL JOIN personne")
            resultat = cur.fetchall()

    return render_template("auteur.html", lst_auteur = resultat)

@app.route("/auteur/<int:idPerso>")
def info_auteur(idPerso):
    # Vérification de l'idPersonne
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT nom, prenom, email, site_web_auteur FROM auteur NATURAL JOIN personne WHERE idPersonne = {idPerso}")
            resultat_auteur = cur.fetchone()
    
    if resultat_auteur != ():
        # Recherche d'info sur les articles de l'auteur
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idArticle, annee_pub, site_web_article FROM auteur NATURAL JOIN ecrit NATURAL JOIN article WHERE idPersonne = {idPerso} ORDER BY annee_pub DESC")
                resultat_article = cur.fetchmany(5)
        return render_template("info_auteur.html", auteur = resultat_auteur, articles = resultat_article)
    
    else:
        return # Template pour information introuvable


if __name__ == '__main__':
    app.run()
