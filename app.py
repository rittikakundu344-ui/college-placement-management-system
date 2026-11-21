from flask import Flask, render_template, request, redirect, url_for, flash
from db import get_connection

app = Flask(__name__)
app.secret_key = "change-this-for-your-local-project"

def fetch_all(query, values=None):
    con = get_connection()
    cur = con.cursor(dictionary=True)
    cur.execute(query, values or ())
    rows = cur.fetchall()
    cur.close()
    con.close()
    return rows

def execute(query, values):
    con = get_connection()
    cur = con.cursor()
    cur.execute(query, values)
    con.commit()
    cur.close()
    con.close()

@app.route("/")
def dashboard():
    stats = fetch_all("""
        SELECT
          (SELECT COUNT(*) FROM Students) AS students,
          (SELECT COUNT(*) FROM Companies) AS companies,
          (SELECT COUNT(*) FROM Job_Drives) AS drives,
          (SELECT COUNT(*) FROM Applications) AS applications,
          (SELECT COUNT(*) FROM Results WHERE result_status='Selected') AS selected
    """)[0]
    recent = fetch_all("""
        SELECT s.student_name,c.company_name,j.job_role,
               COALESCE(r.result_status,'Pending') AS status
        FROM Applications a
        JOIN Students s ON a.student_id=s.student_id
        JOIN Job_Drives j ON a.drive_id=j.drive_id
        JOIN Companies c ON j.company_id=c.company_id
        LEFT JOIN Results r ON a.application_id=r.application_id
        ORDER BY a.application_id DESC
    """)
    return render_template("index.html", stats=stats, recent=recent)

@app.route("/students", methods=["GET","POST"])
def students():
    if request.method == "POST":
        try:
            execute("""INSERT INTO Students
                (student_name,email,department,cgpa,graduation_year)
                VALUES (%s,%s,%s,%s,%s)""",
                (request.form["student_name"], request.form["email"],
                 request.form["department"], request.form["cgpa"],
                 request.form["graduation_year"]))
            flash("Student added successfully.")
        except Exception as e:
            flash(f"Could not add student: {e}")
        return redirect(url_for("students"))
    rows = fetch_all("SELECT * FROM Students ORDER BY student_id DESC")
    return render_template("students.html", rows=rows)

@app.route("/companies", methods=["GET","POST"])
def companies():
    if request.method == "POST":
        execute("INSERT INTO Companies (company_name,location,industry) VALUES (%s,%s,%s)",
                (request.form["company_name"], request.form["location"], request.form["industry"]))
        flash("Company added successfully.")
        return redirect(url_for("companies"))
    rows = fetch_all("SELECT * FROM Companies ORDER BY company_id DESC")
    return render_template("companies.html", rows=rows)

@app.route("/drives", methods=["GET","POST"])
def drives():
    if request.method == "POST":
        execute("""INSERT INTO Job_Drives
            (company_id,job_role,package_lpa,minimum_cgpa,drive_date)
            VALUES (%s,%s,%s,%s,%s)""",
            (request.form["company_id"], request.form["job_role"],
             request.form["package_lpa"], request.form["minimum_cgpa"],
             request.form["drive_date"]))
        flash("Job drive added successfully.")
        return redirect(url_for("drives"))
    companies = fetch_all("SELECT * FROM Companies ORDER BY company_name")
    rows = fetch_all("""SELECT j.*,c.company_name FROM Job_Drives j
                        JOIN Companies c ON j.company_id=c.company_id
                        ORDER BY j.drive_date""")
    return render_template("drives.html", rows=rows, companies=companies)

@app.route("/applications", methods=["GET","POST"])
def applications():
    if request.method == "POST":
        try:
            execute("""INSERT INTO Applications (student_id,drive_id,application_date)
                       VALUES (%s,%s,%s)""",
                    (request.form["student_id"],request.form["drive_id"],
                     request.form["application_date"]))
            flash("Application recorded successfully.")
        except Exception as e:
            flash(f"Could not record application: {e}")
        return redirect(url_for("applications"))
    students = fetch_all("SELECT student_id,student_name FROM Students ORDER BY student_name")
    drives = fetch_all("""SELECT j.drive_id,CONCAT(c.company_name,' - ',j.job_role) AS label
                          FROM Job_Drives j JOIN Companies c ON j.company_id=c.company_id""")
    rows = fetch_all("""SELECT a.application_id,s.student_name,c.company_name,j.job_role,
                               a.application_date
                        FROM Applications a JOIN Students s ON a.student_id=s.student_id
                        JOIN Job_Drives j ON a.drive_id=j.drive_id
                        JOIN Companies c ON j.company_id=c.company_id
                        ORDER BY a.application_id DESC""")
    return render_template("applications.html", rows=rows, students=students, drives=drives)

@app.route("/results", methods=["GET","POST"])
def results():
    if request.method == "POST":
        execute("""INSERT INTO Results (application_id,result_status)
                   VALUES (%s,%s)
                   ON DUPLICATE KEY UPDATE result_status=VALUES(result_status)""",
                (request.form["application_id"],request.form["result_status"]))
        flash("Placement result saved.")
        return redirect(url_for("results"))
    pending = fetch_all("""SELECT a.application_id,
                           CONCAT(s.student_name,' / ',c.company_name,' / ',j.job_role) AS label
                           FROM Applications a
                           JOIN Students s ON a.student_id=s.student_id
                           JOIN Job_Drives j ON a.drive_id=j.drive_id
                           JOIN Companies c ON j.company_id=c.company_id""")
    rows = fetch_all("""SELECT r.result_id,s.student_name,c.company_name,j.job_role,
                               r.result_status,j.package_lpa
                        FROM Results r JOIN Applications a ON r.application_id=a.application_id
                        JOIN Students s ON a.student_id=s.student_id
                        JOIN Job_Drives j ON a.drive_id=j.drive_id
                        JOIN Companies c ON j.company_id=c.company_id
                        ORDER BY r.result_id DESC""")
    return render_template("results.html", rows=rows, applications=pending)

if __name__ == "__main__":
    app.run(debug=True)
