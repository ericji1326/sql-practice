-- Show unique birth years from patients and order them by ascending.
select distinct year(birth_date) as birth_year from patients
order by birth_year


-- Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column 
-- then don't include their name in the output list. 
-- If only 1 person is named 'Leo' then include them in the output.
select first_name
from (
  select
  	first_name,
  	count(first_name) as occ
  From patients
  group by first_name
)
where occ = 1


-- Show patient_id and first_name from patients where their first_name start 
-- and ends with 's' and is at least 6 characters long.
select patient_id, first_name from patients
where first_name like 'S%S' and len(first_name) > 5

-- Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
-- Primary diagnosis is stored in the admissions table.
select p.patient_id, p.first_name, p.last_name 
from
patients p join admissions a on p.patient_id = a.patient_id
where a.diagnosis = 'Dementia'

-- Display every patient's first_name.
-- Order the list by the length of each name and then by alphbetically
select first_name 
from patients
order by len(first_name) asc, first_name

-- Show the total amount of male patients and the total amount of female patients 
-- in the patients table.
-- Display the two results in the same row.
SELECT
    COUNT(CASE gender WHEN 'M' THEN 1 ELSE NULL END) AS male_count,
    COUNT(CASE gender WHEN 'F' THEN 1 ELSE NULL END) AS female_count
FROM patients

SELECT 
  SUM(Gender = 'M') as male_count, 
  SUM(Gender = 'F') AS female_count
FROM patients

-- Show first and last name, allergies from patients which have allergies 
-- to either 'Penicillin' or 'Morphine'. 
-- Show results ordered ascending by allergies then by first_name then by last_name.
select first_name, last_name, allergies from patients
where allergies = 'Penicillin' or allergies = 'Morphine'
order by allergies, first_name, last_name

-- Show patient_id, diagnosis from admissions. 
-- Find patients admitted multiple times for the same diagnosis.
select
  patient_id,
  diagnosis
from admissions
group by
  patient_id,
  diagnosis
having COUNT(*) > 1

-- Show the city and the total number of patients in the city.
-- Order from most to least patients and then by city name ascending.
select city, COUNT(distinct patient_id) AS num_patients
from patients
group By city
order by num_patients desc, city

-- Show first name, last name and role of every person that is either patient or doctor.
-- The roles are either "Patient" or "Doctor"
select first_name, last_name, 'Patient' as role from patients
union All
select first_name, last_name, 'Doctor' AS role from doctors

-- Show all allergies ordered by popularity. Remove NULL values from query.
select allergies, count(allergies) as total_diagnosis from patients
where allergies is not null
group by allergies
order by total_diagnosis desc

-- Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. 
-- Sort the list starting from the earliest birth_date.
select first_name, last_name, birth_date from patients
where year(birth_date) between 1970 and 1979
order by birth_date

-- We want to display each patient's full name in a single column. 
-- Their last_name in all upper letters must appear first, then first_name in all lower case letters. 
-- Separate the last_name and first_name with a comma. 
-- Order the list by the first_name in decending order
-- EX: SMITH,jane
select concat(upper(last_name),',',lower(first_name)) as new_name_format 
from patients
order by first_name desc

-- Show the province_id(s), sum of height; 
-- where the total sum of its patient's height is greater than or equal to 7,000.
select province_id, Sum(height) as sum_height from patients
group by province_id
having sum_height >= 7000

-- Show the difference between the largest weight and smallest weight for 
-- patients with the last name 'Maroni'
select (max(weight) - Min(weight)) from patients
where last_name = 'Maroni'

-- Show all of the days of the month (1-31) and 
-- how many admission_dates occurred on that day. 
-- Sort by the day with most admissions to least admissions.
select day(admission_date) as day_number, count(*) as number_of_admissions 
from admissions
group by day_number
order by number_of_admissions desc

-- Show all columns for patient_id 542's most recent admission_date.
SELECT *
FROM admissions
WHERE
  patient_id = '542'
  AND admission_date = (
    SELECT MAX(admission_date)
    FROM admissions
    WHERE patient_id = '542'
  )

SELECT *
FROM admissions
WHERE patient_id = 542
ORDER BY admission_date DESC
LIMIT 1

-- Show patient_id, attending_doctor_id, and diagnosis for admissions that 
-- match one of the two criteria:
-- 1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
-- 2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
select patient_id, attending_doctor_id, diagnosis 
from admissions
where 
patient_id % 2 = 1 and attending_doctor_id in (1,5,19) 
or
len(patient_id) = 3 and attending_doctor_id like '%2%'

-- Show first_name, last_name, and the total number of admissions attended for each doctor.
-- Every admission has been attended by a doctor.
select first_name, last_name, count(admission_date) from 
admissions join doctors where admissions.attending_doctor_id = doctors.doctor_id
group by first_name, last_name

-- For each doctor, display their id, full name, 
-- and the first and last admission date they attended.
select doctor_id, concat(first_name, ' ', last_name) as full_name, MIN(admission_date), max(admission_date)
from 
admissions join doctors where attending_doctor_id = doctor_id
group by full_name

-- Display the total amount of patients for each province. Order by descending.
select province_name, count(patient_id) as patient_count from
patients join province_names where patients.province_id = province_names.province_id
group by province_name
order by patient_count desc

-- For every admission, display the patient's full name, their admission diagnosis, 
-- and their doctor's full name who diagnosed their problem.
select 
CONCAT(p.first_name,' ',p.last_name) as patient_name, 
a.diagnosis, 
concat(d.first_name,' ',d.last_name) as doctor_name
from 
admissions a
join
patients p 
ON
a.patient_id = p.patient_id
join
doctors d
ON d.doctor_id = a.attending_doctor_id

-- display the number of duplicate patients based on their first_name and last_name.
select first_name, last_name, count(*) as num_of_duplicates from patients
group By first_name, last_name
having num_of_duplicates > 1

-- Display patient's full name,
-- height in the units feet rounded to 1 decimal,
-- weight in the unit pounds rounded to 0 decimals,
-- birth_date,
-- gender non abbreviated.

-- Convert CM to feet by dividing by 30.48.
-- Convert KG to pounds by multiplying by 2.205.
select 
(concat(first_name, ' ', last_name)) as patients_name, 
round(height/30.48,1) as 'height "Feet"',
ROUND(weight*2.205,0) as 'weight "Pounds"',
birth_date,
CASE
      WHEN gender = 'M' THEN 'MALE'
      WHEN gender = 'F' THEN 'FEMALE'
 END AS gender_type
from
patients



