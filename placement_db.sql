CREATE DATABASE IF NOT EXISTS placement_db;
USE placement_db;

CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL,
    cgpa DECIMAL(3,2) NOT NULL,
    graduation_year INT NOT NULL
);

CREATE TABLE Companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    industry VARCHAR(60)
);

CREATE TABLE Job_Drives (
    drive_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    job_role VARCHAR(100) NOT NULL,
    package_lpa DECIMAL(6,2) NOT NULL,
    minimum_cgpa DECIMAL(3,2) NOT NULL,
    drive_date DATE NOT NULL,
    FOREIGN KEY (company_id) REFERENCES Companies(company_id)
);

CREATE TABLE Applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    drive_id INT NOT NULL,
    application_date DATE NOT NULL,
    UNIQUE (student_id, drive_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (drive_id) REFERENCES Job_Drives(drive_id)
);

CREATE TABLE Results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,
    result_status ENUM('Selected','Rejected','Pending') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (application_id) REFERENCES Applications(application_id)
);


INSERT INTO Students
(student_name, email, department, cgpa, graduation_year)
VALUES
('Aarav Sharma', 'aarav@example.com', 'B.Tech CSE', 8.50, 2026),
('Priya Das', 'priya@example.com', 'MCA', 9.10, 2026),
('Rahul Roy', 'rahul@example.com', 'B.Sc Computer Science', 7.80, 2026),
('Sneha Paul', 'sneha@example.com', 'B.Tech IT', 8.90, 2026),
('Ankit Sen', 'ankit@example.com', 'BCA', 7.50, 2026),
('Riya Ghosh', 'riya@example.com', 'MCA', 9.30, 2026),
('Sayan Dutta', 'sayan@example.com', 'B.Sc IT', 8.20, 2026),
('Ananya Bose', 'ananya@example.com', 'BCA', 8.60, 2026),
('Arjun Roy', 'arjun@example.com', 'B.Tech ECE', 8.75, 2026),
('Ishita Dey', 'ishita@example.com', 'B.Sc Mathematics', 8.40, 2026),
('Kunal Das', 'kunal@example.com', 'MCA', 9.00, 2026),
('Megha Sen', 'megha@example.com', 'B.Tech CSE', 7.90, 2026),
('Sourav Paul', 'sourav@example.com', 'BCA', 8.10, 2026),
('Tanya Ghosh', 'tanya@example.com', 'B.Sc Computer Science', 9.20, 2026),
('Rohan Bose', 'rohan@example.com', 'MCA', 8.65, 2026);


INSERT INTO Companies (company_name,location,industry) VALUES
('TCS','Kolkata','IT Services'),
('Infosys','Bangalore','IT Services'),
('Wipro','Hyderabad','IT Services'),
('Accenture','Pune','Consulting'),
('IBM','Bangalore','Technology');

INSERT INTO Job_Drives (company_id,job_role,package_lpa,minimum_cgpa,drive_date) VALUES
(1,'Software Developer',4.50,7.00,'2026-11-25'),
(2,'Python Developer',5.50,8.00,'2026-11-26'),
(3,'Data Analyst',4.00,7.50,'2026-11-27'),
(4,'Associate Software Engineer',6.00,8.00,'2026-11-28'),
(5,'AI Engineer',8.00,8.50,'2026-11-29');

INSERT INTO Applications (student_id,drive_id,application_date) VALUES
(1,1,'2026-11-18'),(2,1,'2026-11-18'),(2,2,'2026-11-19'),
(3,3,'2026-11-19'),(4,2,'2026-11-19'),(4,4,'2026-11-20'),
(5,3,'2026-11-20'),(6,5,'2026-11-20'),(7,1,'2026-11-20'),
(8,4,'2026-11-20');

INSERT INTO Results (application_id,result_status) VALUES
(1,'Selected'),(2,'Rejected'),(3,'Selected'),(4,'Rejected'),
(5,'Selected'),(6,'Pending'),(7,'Rejected'),(8,'Selected'),
(9,'Pending'),(10,'Selected');

-- Presentation queries
SELECT * FROM Students;
SELECT student_name,cgpa FROM Students WHERE cgpa > 8.5 ORDER BY cgpa DESC;

SELECT s.student_name,c.company_name,j.job_role,a.application_date
FROM Applications a
JOIN Students s ON a.student_id=s.student_id
JOIN Job_Drives j ON a.drive_id=j.drive_id
JOIN Companies c ON j.company_id=c.company_id;

SELECT c.company_name,COUNT(a.application_id) AS total_applications
FROM Companies c
LEFT JOIN Job_Drives j ON c.company_id=j.company_id
LEFT JOIN Applications a ON j.drive_id=a.drive_id
GROUP BY c.company_id,c.company_name;

SELECT s.student_name,c.company_name,j.job_role,j.package_lpa
FROM Results r
JOIN Applications a ON r.application_id=a.application_id
JOIN Students s ON a.student_id=s.student_id
JOIN Job_Drives j ON a.drive_id=j.drive_id
JOIN Companies c ON j.company_id=c.company_id
WHERE r.result_status='Selected';

SELECT student_name,cgpa
FROM Students
WHERE cgpa >= (SELECT MIN(minimum_cgpa) FROM Job_Drives);

CREATE INDEX idx_student_department ON Students(department);
