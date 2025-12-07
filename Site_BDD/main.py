import random
from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)

@app.route("/acceuil")
def acceuil():
    return render_template("acceuil.html")


if __name__ == '__main__':
    app.run()
