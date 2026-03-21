# ================= IMPORTS =================
from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
import random
import re

app = Flask(__name__)
app.secret_key = "bus_booking_2026"

otp_store = {}

def generate_otp():
    return str(random.randint(100000, 999999))

from flask_mail import Mail, Message

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'adithyaaravind020@gmail.com'
app.config['MAIL_PASSWORD'] = 'hefk xljb lnzd rehm'
app.config['MAIL_DEBUG'] = True

mail = Mail(app)

# ================= DB =================
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Adi@thyaa06",
        database="bus_booking"
    )

# ================= PASSWORD CHECK =================
def is_strong_password(password):
    return (
        len(password) >= 8 and
        re.search(r"[A-Z]", password) and
        re.search(r"[a-z]", password) and
        re.search(r"\d", password)
    )

# ================= HOME =================
@app.route("/")
def index():
    if "user_id" in session:
        return redirect(url_for("search"))
    return render_template("index.html")

# ================= REGISTER =================
@app.route("/register", methods=["GET","POST"])
def register():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        username = request.form["username"]
        password = request.form["password"]

        if not is_strong_password(password):
            return "Weak password!"

        # 🔐 Generate OTP
        otp = generate_otp()
        otp_store[email] = otp

        # 📧 Send OTP email
        msg = Message("OTP Verification",
                      sender=app.config['MAIL_USERNAME'],
                      recipients=[email])
        msg.body = f"Your OTP is {otp}"
        mail.send(msg)

        # 🧠 Store temp data
        session["temp_user"] = {
            "name": name,
            "email": email,
            "username": username,
            "password": password
        }   
        return redirect("/verify_register_otp")

    return render_template("register.html")

# ================= VERIFY REGISTER OTP =================
@app.route("/verify_register_otp", methods=["GET","POST"])
def verify_register_otp():
    if request.method == "POST":
        otp = request.form["otp"]
        email = session["temp_user"]["email"]

        if otp_store.get(email) == otp:
            user = session["temp_user"]

            db = get_db_connection()
            cursor = db.cursor()

            cursor.execute("""
                INSERT INTO users(name,email,username,password)
                VALUES(%s,%s,%s,%s)
            """,(user["name"], user["email"], user["username"],
                 generate_password_hash(user["password"])))

            db.commit()

            return redirect("/login")

        flash("Invalid OTP")
        return redirect("/verify_register_otp")

    return render_template("verify_register_otp.html")


# ================= LOGIN =================
@app.route("/login", methods=["GET","POST"])
def login():
    if request.method=="POST":
        db=get_db_connection()
        cursor=db.cursor(dictionary=True)

        cursor.execute("SELECT * FROM users WHERE username=%s",(request.form["username"],))
        user=cursor.fetchone()

        if user and check_password_hash(user["password"],request.form["password"]):
            session["user_id"]=user["id"]
            return redirect(url_for("search"))

        return render_template("login.html", error="Invalid login")

    return render_template("login.html")

# ================= FORGOT PASSWORD =================
@app.route("/forgot_password", methods=["GET","POST"])
def forgot_password():
    if request.method == "POST":
        email = request.form["email"]
        new_password = request.form["password"]

        if not is_strong_password(new_password):
            return "Weak password"

        db = get_db_connection()
        cursor = db.cursor()

        cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
        user = cursor.fetchone()

        if not user:
            return "Email not found"

        hashed = generate_password_hash(new_password)

        cursor.execute(
            "UPDATE users SET password=%s WHERE email=%s",
            (hashed, email)
        )

        db.commit()
        return redirect("/login")

    return render_template("forgot_password.html")

# ================= LOGOUT =================
@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

# ================= SEARCH =================

@app.route("/search", methods=["GET", "POST"])
def search():
    # 🔒 Ensure user is logged in
    if "user_id" not in session:
        return redirect(url_for("login"))

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    if request.method == "POST":
        source = request.form.get("from")
        destination = request.form.get("to")

        # 🔍 Improved search (more flexible matching)
        cursor.execute("""
            SELECT DISTINCT b.*
            FROM buses b
            JOIN routes r1 ON b.id = r1.bus_id
            JOIN routes r2 ON b.id = r2.bus_id
            WHERE r1.stop_name = %s
            AND r2.stop_name = %s
            AND r1.stop_order < r2.stop_order
        """, (source, destination))


        buses = cursor.fetchall()

        # 🧠 If no buses found, show message instead of empty page
        if not buses:
            flash("No buses found for the selected route!")

        return render_template("buslist.html", buses=buses)

    # 👉 If GET request, just show search page
    return render_template("search.html")

# ================= SEARCH BUSES =================
@app.route("/search_buses", methods=["POST"])
def search_buses():
    if "user_id" not in session:
        return redirect(url_for("login"))

    from_city=request.form["from"]
    to_city=request.form["to"]
    date=request.form["date"]

    db=get_db_connection()
    cursor=db.cursor(dictionary=True)

   
    cursor.execute("""
        SELECT DISTINCT b.*
        FROM buses b
        JOIN routes r1 ON b.id = r1.bus_id
        JOIN routes r2 ON b.id = r2.bus_id
        WHERE r1.stop_name = %s
        AND r2.stop_name = %s
        AND r1.stop_order < r2.stop_order
    """, (source, destination))

    buses=cursor.fetchall()

    for bus in buses:
        cursor.execute("SELECT seats FROM bookings WHERE bus_id=%s",(bus["id"],))
        rows=cursor.fetchall()

        booked=[]
        for r in rows:
            if r["seats"]:
                booked+=r["seats"].split(",")

        bus["available_seats"]=40-len(booked)

    return render_template("buslist.html",buses=buses)

# ================= SELECT SEATS =================
@app.route("/select_seats/<int:bus_id>")
def select_seats(bus_id):
    if "user_id" not in session:
        return redirect(url_for("login"))

    db=get_db_connection()
    cursor=db.cursor(dictionary=True)

    cursor.execute("SELECT * FROM buses WHERE id=%s",(bus_id,))
    bus=cursor.fetchone()

    if not bus:
        return "Bus not found"

    cursor.execute("SELECT seats FROM bookings WHERE bus_id=%s",(bus_id,))
    rows=cursor.fetchall()

    booked=[]
    for r in rows:
        if r["seats"]:
            booked+=r["seats"].split(",")

    return render_template("select_seats.html",bus=bus,booked_seats=booked)

# ================= BOOK =================
@app.route("/book_seats/<int:bus_id>", methods=["POST"])
def book_seats(bus_id):
    if "user_id" not in session:
        return redirect(url_for("login"))

    seats=request.form.getlist("seats")
    name=request.form["passenger_name"]

    if not seats:
        return "No seats selected"

    db=get_db_connection()
    cursor=db.cursor()

    cursor.execute("""
        INSERT INTO bookings(user_id,bus_id,seats,passenger_name)
        VALUES(%s,%s,%s,%s)
    """,(session["user_id"],bus_id,",".join(seats),name))

    db.commit()
    booking_id=cursor.lastrowid

    return redirect(url_for("booking_confirmation",booking_id=booking_id))

# ================= CONFIRM =================
@app.route("/booking_confirmation/<int:booking_id>")
def booking_confirmation(booking_id):
    if "user_id" not in session:
        return redirect(url_for("login"))

    db=get_db_connection()
    cursor=db.cursor(dictionary=True)

    cursor.execute("""
        SELECT b.id, b.seats, b.passenger_name,
               buses.bus_name, buses.source, buses.destination,
               buses.travel_date, buses.price
        FROM bookings b
        JOIN buses ON b.bus_id=buses.id
        WHERE b.id=%s
    """,(booking_id,))

    booking=cursor.fetchone()

    if not booking:
        return "Booking not found"

    seats_list = booking["seats"].split(",") if booking["seats"] else []
    booking["total_amount"]=len(seats_list)*booking["price"]

    return render_template("confirmation.html",booking=booking)

# ================= HISTORY =================
@app.route("/booking_history")
def booking_history():
    if "user_id" not in session:
        return redirect(url_for("login"))

    db=get_db_connection()
    cursor=db.cursor(dictionary=True)

    cursor.execute("""
        SELECT b.id, b.seats, buses.bus_name,
               buses.source, buses.destination,
               buses.travel_date, buses.price
        FROM bookings b
        JOIN buses ON b.bus_id=buses.id
        WHERE b.user_id=%s
    """,(session["user_id"],))

    bookings=cursor.fetchall()
    return render_template("booking_history.html",bookings=bookings)

# ================= RUN =================
if __name__=="__main__":
    app.run(debug=True)