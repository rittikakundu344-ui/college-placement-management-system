# 🎓 College Placement Management System

## 📌 About the Project

The **College Placement Management System** is a web-based project
designed to organize student placement information in one place. It
helps an administrator view student records, company details, job
drives, applications, and placement results through a simple dashboard.

The project focuses on **MySQL database design and SQL operations**,
with a lightweight Flask website as the user interface.

## ✨ Features

-   **Dashboard overview** -- view counts for students, companies, job
    drives, applications, and selected candidates.
-   **Student management** -- view student details such as department,
    CGPA, and graduation year.
-   **Company management** -- maintain company names, locations, and
    industries.
-   **Job drive management** -- view job roles, package details,
    eligibility CGPA, and drive dates.
-   **Application tracking** -- connect students with the job drives
    they apply for.
-   **Result tracking** -- maintain Selected, Rejected, and Pending
    statuses.
-   **Relational database** -- use primary keys, foreign keys, unique
    constraints, and an index.

## 🧰 Technology Stack

  Layer                Technology
  -------------------- --------------------------
  Database             MySQL
  Backend              Python, Flask
  Frontend             HTML, CSS
  Database connector   `mysql-connector-python`
  Database client      MySQL Workbench
  Code editor          Visual Studio Code

## 🗂️ Project Structure

``` text
College_Placement_System_Flask/
├── app.py
├── db.py
├── requirements.txt
├── README.md
├── .gitignore
├── database/
│   └── placement_db.sql
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── students.html
│   ├── companies.html
│   ├── drives.html
│   ├── applications.html
│   └── results.html
└── static/
    └── style.css
```

## 🧩 Database Design

The database is named `placement_db` and contains five related tables.

  -----------------------------------------------------------------------
  Table                               Purpose
  ----------------------------------- -----------------------------------
  `Students`                          Stores student name, email,
                                      department, CGPA, and graduation
                                      year.

  `Companies`                         Stores company name, location, and
                                      industry.

  `Job_Drives`                        Stores job role, package, minimum
                                      CGPA, drive date, and its company.

  `Applications`                      Connects a student to a job drive
                                      and stores the application date.

  `Results`                           Stores the outcome of an
                                      application: Selected, Rejected, or
                                      Pending.
  -----------------------------------------------------------------------

### Entity Relationship Diagram (ER Diagram)

``` mermaid
erDiagram
    Students ||--o{ Applications : submits
    Job_Drives ||--o{ Applications : receives
    Companies ||--o{ Job_Drives : announces
    Applications ||--o| Results : has

    Students {
        INT student_id PK
        VARCHAR student_name
        VARCHAR email UK
        VARCHAR department
        DECIMAL cgpa
        INT graduation_year
    }

    Companies {
        INT company_id PK
        VARCHAR company_name
        VARCHAR location
        VARCHAR industry
    }

    Job_Drives {
        INT drive_id PK
        INT company_id FK
        VARCHAR job_role
        DECIMAL package_lpa
        DECIMAL minimum_cgpa
        DATE drive_date
    }

    Applications {
        INT application_id PK
        INT student_id FK
        INT drive_id FK
        DATE application_date
        VARCHAR student_drive_unique
    }

    Results {
        INT result_id PK
        INT application_id FK, UK
        VARCHAR result_status
    }
```

### Relationship Explanation

-   One **company** can announce many **job drives**.
-   One **student** can submit many **applications**.
-   One **job drive** can receive applications from many **students**.
-   Each application can have at most one result record.
-   The pair `(student_id, drive_id)` is unique in `Applications`, so
    the same student cannot apply to the same drive more than once.

## ⚙️ Database Concepts Demonstrated

-   Primary keys and foreign keys
-   `NOT NULL` and `UNIQUE` constraints
-   `ENUM` for application result status
-   `AUTO_INCREMENT`
-   `JOIN` operations across related tables
-   Aggregate functions such as `COUNT()`
-   `GROUP BY` and `ORDER BY`
-   Subqueries
-   Indexing with `idx_student_department`

## 🚀 Run the Project Locally

### 1. Clone the repository

``` bash
git clone https://github.com/YOUR-USERNAME/college-placement-management-system.git
cd college-placement-management-system
```

Replace `YOUR-USERNAME` with your GitHub username.

### 2. Create the MySQL database

1.  Open MySQL Workbench and connect to your local MySQL server.
2.  Open `database/placement_db.sql`.
3.  Execute the SQL script to create the database, tables, sample
    records, and demonstration queries.

> **Important:** The script inserts sample records. Do not execute the
> full script repeatedly on an existing populated database because
> unique email and other constraints can cause duplicate-entry errors.

### 3. Install Python dependencies

``` bash
python -m pip install -r requirements.txt
```

### 4. Configure database environment variables

Set these variables in your terminal. Use the credentials for your own
MySQL installation.

**PowerShell:**

``` powershell
$env:DB_HOST="localhost"
$env:DB_USER="root"
$env:DB_PASSWORD="YOUR_LOCAL_MYSQL_PASSWORD"
$env:DB_NAME="placement_db"
$env:DB_PORT="3306"
```

Do not commit real passwords, API keys, or `.env` files to GitHub. For
deployment, configure the corresponding environment variables in your
hosting provider.

### 5. Start the Flask application

``` bash
python app.py
```

Open the local address shown by Flask, normally:

``` text
http://127.0.0.1:5000
```

## 🔍 Example SQL Queries

**1. Find students with CGPA above 8.5**

``` sql
SELECT student_name, cgpa
FROM Students
WHERE cgpa > 8.5
ORDER BY cgpa DESC;
```

**2. Display student applications with company and role**

``` sql
SELECT s.student_name, c.company_name, j.job_role, a.application_date
FROM Applications a
JOIN Students s ON a.student_id = s.student_id
JOIN Job_Drives j ON a.drive_id = j.drive_id
JOIN Companies c ON j.company_id = c.company_id;
```

**3. Count applications received by each company**

``` sql
SELECT c.company_name, COUNT(a.application_id) AS total_applications
FROM Companies c
LEFT JOIN Job_Drives j ON c.company_id = j.company_id
LEFT JOIN Applications a ON j.drive_id = a.drive_id
GROUP BY c.company_id, c.company_name;
```

## 🔐 Security Notes

-   Database credentials are read from environment variables in `db.py`.
-   Never upload real database passwords, API keys, or `.env` files to
    GitHub.
-   Use a dedicated database account with only the permissions the
    application needs when deploying.
-   The Flask development server is intended for local development, not
    production hosting.

## 🎯 Project Objective

The objective is to demonstrate how a relational database can support a
practical college placement workflow, and how a Python Flask application
can present that data through a web interface.

------------------------------------------------------------------------



## Made with 🐍 Python, ⚡ Flask, and 🐬 MySQL


