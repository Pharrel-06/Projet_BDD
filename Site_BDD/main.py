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


if __name__ == '__main__':
    app.run()
