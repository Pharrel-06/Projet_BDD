import random
from flask import Flask, render_template, request, redirect, url_for, session
import db
import psycopg2

app = Flask(__name__)

@app.route("/accueil")
def accueil():
    return render_template("accueil.html")

@app.route("/recherche", methods=['GET', 'POST'])
def recherche():
    crit_rec = ["auteur", "domaine", "langue", "année publication", "revue", "laboratoire"]
    chosen_crit = request.form.get("critere") or request.args.get("critere")
    res_rec = None
    with db.connect() as conn:
        with conn.cursor() as cur:
            if chosen_crit == crit_rec[0]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub from article natural join ecrit natural join auteur natural join personne order by nom desc")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[1]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, nom_domaine from article natural join ecrit natural join auteur natural join personne natural join domaine_article natural join domaine order by nom_domaine desc")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[2]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, nom_langue from article natural join ecrit natural join auteur natural join personne order by nom_langue asc")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[3]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub from article natural join ecrit natural join auteur natural join personne order by annee_pub desc")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[4]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, idRevue from article natural join ecrit natural join auteur natural join personne order by idRevue asc")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[5]:
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, idLaboratoire from article natural join ecrit natural join auteur natural join personne order by idLaboratoire desc")
                res_rec = cur.fetchall()
    return render_template("recherche.html", critere_recherche = crit_rec, resultat_recherche = res_rec)


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
