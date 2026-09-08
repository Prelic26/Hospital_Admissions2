Create database General_HospitalAdmissions
---Insert Raw CSV data
---Query the data
Select *
From General_HospitalAdmissions.dbo.HospitalAdmissions;

---Find distinct values
Select distinct * 
From General_HospitalAdmissions.dbo.HospitalAdmissions;

---Find duplicates
Select patient_id,
      admission_status,
      count(*) As Duplicated_Values
From General_HospitalAdmissions.dbo.HospitalAdmissions
Group by patient_id, admission_status
Having count(*) >  1;

Drop table Clean_HospitalAdmissions;

---Creating new table 

Use General_HospitalAdmissions
Create table Clean_HospitalAdmissions
(patient_id VARCHAR(250),
first_name VARCHAR(250),
surname VARCHAR(250),
national_ID VARCHAR(250),
date_of_birth Date,
disease VARCHAR(250),
severity VARCHAR(250),
admission_status VARCHAR(250),
ward VARCHAR(250),
admission_date Date,
discharge_date Date
);
---Removing duplicated values--Creating a CTE 

WITH DuplicateData AS (
    SELECT patient_id,
    first_name,
    surname,
    national_id,
    date_of_birth,
    disease,
    severity,
    admission_status,
    ward,
    admission_date,
    discharge_date
    ,
           ROW_NUMBER() OVER (
               PARTITION BY patient_id,admission_date
               ORDER BY patient_id
           ) AS row_num
    FROM General_HospitalAdmissions.dbo.HospitalAdmissions
)

---Inserting data into a new table
INSERT INTO General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
(
    patient_id,
    first_name,
    surname,
    national_id,
    date_of_birth,
    disease,
    severity,
    admission_status,
    ward,
    admission_date,
    discharge_date
)

SELECT patient_id,
       first_name,
       surname,
       national_id,
       date_of_birth,
       disease,
       severity,
       admission_status,
       ward,
       admission_date,
       discharge_date
FROM DuplicateData
WHERE row_num = 1;

Select * From General_HospitalAdmissions.dbo.Clean_HospitalAdmissions;

---Finding the admission rate
SELECT admission_status,
       severity,
       COUNT(*) AS admission_count
FROM General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
WHERE admission_status IN ('Admitted', 'Not admitted')
GROUP BY admission_status, severity;

---Disease with the hugest number of admission
Select disease,
       admission_status,
       COUNT(*) AS admission_count
FROM General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
WHERE admission_status = 'Admitted'
GROUP BY disease, admission_status
Order by admission_count DESC;

---Ward with the most admissions
Select ward,
       admission_status,
       count(*) as admission_count
From General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
Where admission_status='Admitted'
Group by ward, admission_status
Order by admission_count Desc;

---Average time spent at the hospital)
Select severity,
       AVG(Datediff(DAY,admission_date, discharge_date)) as Average_Days_Spent
From General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
Where admission_status='Admitted'
Group by severity;

---Patients marked not admitted with high severity

Select admission_status,
       severity,
       count(*) AS Not_Admitted
From General_HospitalAdmissions.dbo.Clean_HospitalAdmissions
Where admission_status='Not Admitted'
Group by severity, admission_status;

---Finding the age distribution
Select
      DATEDIFF(year,2026, date_of_birth) as Age
From General_HospitalAdmissions.dbo.Clean_HospitalAdmissions;