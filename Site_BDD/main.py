from flask import Flask, render_template, request, redirect, url_for, session
from passlib.context import CryptContext
import db

def creation_titre(chaine):
        titre = ""
        for i in range(4, len(chaine), 1):
            if i == 4:
                titre += chaine[i].upper()
                continue
            if chaine[i] == ".": break
            else:
                if chaine[i] == "-": titre += " "
                else: titre += chaine[i]
        return titre

app = Flask(__name__)

@app.route("/")
def default():
    return redirect(url_for('accueil'))

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
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub from article natural join ecrit natural join auteur natural join personne order by nom desc limit 20")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[1]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, nom_domaine from article natural join ecrit natural join auteur natural join personne natural join domaine_article natural join domaine order by nom_domaine desc limit 20")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[2]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, nom_langue from article natural join ecrit natural join auteur natural join personne order by nom_langue asc limit 20")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[3]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub from article natural join ecrit natural join auteur natural join personne order by annee_pub desc limit 20")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[4]: 
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, idRevue from article natural join ecrit natural join auteur natural join personne order by idRevue asc limit 20")
                res_rec = cur.fetchall()
            elif chosen_crit == crit_rec[5]:
                cur.execute("select idArticle, site_web_article, nom, prenom, annee_pub, idLaboratoire from article natural join ecrit natural join auteur natural join personne order by idLaboratoire desc limit 20")
                res_rec = cur.fetchall()
    if res_rec != None:
        titres = [creation_titre(res_rec[i].site_web_article) for i in range(len(res_rec))]
        res_rec = zip(res_rec, titres)
    return render_template("recherche.html", critere_recherche = crit_rec, resultat_recherche = res_rec)

@app.route("/auteur")
def auteur():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM auteur NATURAL JOIN personne")
            resultat = cur.fetchall()

    return render_template("auteur.html", lst_auteur = resultat)

@app.route("/auteur/<int:idPersonne>")
def info_auteur(idPersonne):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT nom, prenom, email, site_web_auteur FROM auteur NATURAL JOIN personne WHERE idPersonne = {idPersonne}")
            resultat_auteur = cur.fetchone()
    
    if resultat_auteur != None:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idArticle, annee_pub, site_web_article FROM auteur NATURAL JOIN ecrit NATURAL JOIN article WHERE idPersonne = {idPersonne} ORDER BY annee_pub DESC")
                resultat_article = cur.fetchmany(5)
        
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idComite, nom_comite FROM auteur NATURAL JOIN comite_auteur NATURAL JOIN comite WHERE idPersonne = {idPersonne}")
                resultat_comite = cur.fetchmany(5)

        return render_template("info_auteur.html", auteur = resultat_auteur, articles = resultat_article, comites = resultat_comite)
    
    else:
        return render_template("info_introuvable.html")

@app.route("/article/<int:idArticle>")
def info_article(idArticle):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT site_web_article, nb_page, annee_pub, volume, numero, nom_langue, nom_domaine, idRevue, nom_revue FROM article NATURAL JOIN langue NATURAL JOIN domaine_article NATURAL JOIN domaine NATURAL JOIN revue  WHERE idArticle = {idArticle}")
            resultat_article = cur.fetchone()

    if resultat_article != None:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idPersonne, site_web_auteur FROM article NATURAL JOIN ecrit NATURAL JOIN auteur NATURAL JOIN personne WHERE idArticle = {idArticle}") 
                resultat_auteur = cur.fetchmany(5)
        titre = creation_titre(resultat_article.site_web_article)
        return render_template("info_article.html", titre = titre, article = resultat_article, auteurs = resultat_auteur)
    
    else:
        return render_template("info_introuvable.html")

@app.route("/revue")
def revue():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM revue NATURAL JOIN comite")
            resultat_revues = cur.fetchall()
    return render_template("revue.html", lst_revue = resultat_revues)

@app.route("/revue/<int:idRevue>")
def info_revue(idRevue):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT nom_revue, idComite, nom_comite FROM revue NATURAL JOIN comite WHERE idRevue = {idRevue}")
            resultat_revue = cur.fetchone()

    if resultat_revue != None:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idArticle, site_web_article FROM article WHERE idRevue = {idRevue}") 
                resultat_article = cur.fetchall()
        
        return render_template("info_revue.html", revue = resultat_revue, articles = resultat_article)
    
    else:
        return render_template("info_introuvable.html")

@app.route("/comite")
def comite():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM comite")
            resultat_comites = cur.fetchall()
    return render_template("comite.html", lst_comite = resultat_comites)

@app.route("/comite/<int:idComite>")
def info_comite(idComite):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT idComite, nom_comite FROM comite WHERE idComite = {idComite}")
            resultat_comite = cur.fetchone()

    if resultat_comite != None:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idPersonne, nom, prenom FROM comite_auteur NATURAL JOIN auteur NATURAL JOIN personne WHERE idComite = {idComite}") 
                resultat_membre = cur.fetchall()
        
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idRevue, nom_revue FROM comite NATURAL JOIN revue WHERE idComite = {idComite}") 
                resultat_revue = cur.fetchall()
        
        return render_template("info_comite.html", comite = resultat_comite, membres = resultat_membre, revues = resultat_revue)
    
    else:
        return render_template("info_introuvable.html")

@app.route("/labo")
def labo():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM laboratoire NATURAL JOIN ville NATURAL JOIN pays")
            resultat_labos = cur.fetchall()
    return render_template("labo.html", lst_labos = resultat_labos)

@app.route("/labo/<int:idLaboratoire>")
def info_labo(idLaboratoire):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"SELECT * FROM laboratoire NATURAL JOIN ville NATURAL JOIN pays WHERE idLaboratoire = {idLaboratoire}")
            resultat_labo = cur.fetchone()

    if resultat_labo != None:
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT DISTINCT idPersonne, nom, prenom, site_web_auteur FROM ecrit NATURAL JOIN auteur NATURAL JOIN personne WHERE idLaboratoire = {idLaboratoire}") 
                resultat_auteur = cur.fetchall()
        
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT idArticle, site_web_article FROM ecrit NATURAL JOIN article WHERE idLaboratoire = {idLaboratoire}") 
                resultat_article = cur.fetchall()
        
        return render_template("info_labo.html", labo = resultat_labo, auteurs = resultat_auteur, articles = resultat_article)
    
    else:
        return render_template("info_introuvable.html")

@app.route("/admin")
def admin():
    return render_template("admin.html")

@app.route("/page_administrateur", methods = ["POST"])
def page_administrateur():
    from passlib.context import CryptContext
    password_ctx = CryptContext(schemes=["pbkdf2_sha256"])

    mdp = request.form.get("mdp")
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"select mot_de_passe FROM administrateur LIMIT 1")
            hash_pw = cur.fetchone()

    if (password_ctx.verify(mdp, hash_pw.mot_de_passe)):
        return render_template("page_administrateur.html")
    return redirect(url_for('admin'))

@app.route("/admin_action", methods=["POST"])
def admin_action():
    action = request.form.get("action")
    table = request.form.get("table")
    message = ""

    colonnes_possibles = {
        "personne": {"nom", "prenom"},
        "administrateur": {"mot_de_passe", "idPersonne"},
        "auteur": {"email", "site_web_auteur", "idPersonne"},
        "comite": {"nom_comite"},
        "revue": {"nom_revue", "idComite"},
        "langue": {"nom_langue"},
        "article": {"nb_page", "annee_pub", "site_web_article", "idRevue", "volume", "numero", "nom_langue"},
        "domaine": {"nom_domaine"},
        "pays": {"nom_pays"},
        "ville": {"nom_ville", "idPays"},
        "laboratoire": {"nom_laboratoire", "adresse", "site_web_laboratoire", "type", "idVille"}
    }

    prim_keys = {
        "auteur": "idPersonne",
        "article": "idArticle",
        "revue": "idRevue",
        "comite": "idComite",
        "laboratoire": "idLaboratoire",
        "ville": "idVille",
        "pays": "idPays",
        "domaine": "idDomaine",
        "langue": "idLangue",
        "personne": "idPersonne",
        "administrateur": "idAdministrateur"
    }

    try:
        if table not in colonnes_possibles:
            raise Exception()

        with db.connect() as conn, conn.cursor() as cur:
            pk = prim_keys.get(table)

            if action in {"ajouter", "modifier"}:
                donnees = request.form.get("donnees", "").strip()
                pairs = [p.split("=", 1) for p in donnees.split(",")]
                colonnes = [c.strip() for c, _ in pairs if c.strip() in colonnes_possibles[table]]
                valeurs = [v.strip() for c, v in pairs if c.strip() in colonnes_possibles[table]]

                if not colonnes:
                    raise Exception()

            if action == "ajouter":
                tempo = ", ".join(["%s"] * len(valeurs))
                cur.execute(f"INSERT INTO {table} ({', '.join(colonnes)}) VALUES ({tempo})", valeurs)
                conn.commit()
                message = f"✓ Élément ajouté dans la table {table}"

            elif action == "supprimer":
                elem_id = request.form.get("id")
                cur.execute(f"SELECT 1 FROM {table} WHERE {pk} = %s", (elem_id,))
                if cur.fetchone():
                    cur.execute(f"DELETE FROM {table} WHERE {pk} = %s", (elem_id,))
                    conn.commit()
                    message = f"✓ Élément {elem_id} supprimé de la table {table}"
                else:
                    message = f"✗ Élément {elem_id} inexistant"

            elif action == "modifier":
                elem_id = request.form.get("id")
                cur.execute(f"SELECT 1 FROM {table} WHERE {pk} = %s", (elem_id,))
                if cur.fetchone():
                    affectations = ", ".join(f"{c} = %s" for c in colonnes)
                    cur.execute(f"UPDATE {table} SET {affectations} WHERE {pk} = %s", valeurs + [elem_id])
                    conn.commit()
                    message = f"✓ Élément {elem_id} modifié dans la table {table}"
                else:   
                    message = f"✗ Élément inexistant"
    except:
        message = "✗ Erreur: Je sais pas ou mais il y a un probleme quelque part."
    return render_template("page_administrateur.html", message=message)


if __name__ == '__main__':
    app.run()
