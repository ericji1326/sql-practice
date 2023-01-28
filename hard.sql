-- Show all of the patients grouped into weight groups.
-- Show the total amount of patients in each weight group.
-- Order the list by the weight group decending.
-- For example, if they weight 100 to 109 they are placed in the 100 weight group
select COUNT(*) as patients_in_group, FLOOR(weight / 10) * 10 as weight_group from patients
group by weight_group
order by weight_group desc


-- Show patient_id, weight, height, isObese from the patients table.
-- Display isObese as a boolean 0 or 1.
-- Obese is defined as weight(kg)/(height(m)2) >= 30.
-- weight is in units kg.
-- height is in units cm.
select 
patient_id, weight, height,
case 
	When weight/(POWER((height/100.0),2)) >= 30 then 1
    else 0
end as isObese
from patients


-- Show patient_id, first_name, last_name, and attending doctor's specialty.
-- Show only the patients with diagnosis as 'Epilepsy' and doctor first name is 'Lisa'
-- Check patients, admissions, and doctors tables for required information.
select p.patient_id, p.first_name, p.last_name, d.specialty 
from 
patients p
join
admissions a
on 
p.patient_id = a.patient_id
join
doctors d
on 
a.attending_doctor_id = d.doctor_id
where a.diagnosis = 'Epilepsy' and d.first_name = 'Lisa'


-- All patients who have gone through admissions, can see their medical documents on our site. 
-- Those patients are given a temporary password after their first admission. 
-- Show the patient_id and temp_password.
-- The password must be the following, in order:
-- 1. patient_id
-- 2. the numerical length of patient's last_name
-- 3. year of patient's birth_date
select a.patient_id, 
CONCAT(p.patient_id,len(p.last_name),YEAR(p.birth_date)) as temp_password 
from 
patients p
join 
admissions a
on p.patient_id = a.patient_id
group by a.patient_id


-- Each admission costs $50 for patients without insurance, and $10 for patients with insurance. 
-- All patients with an even patient_id have insurance.
-- Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. 
-- Add up the admission_total cost for each has_insurance group.
select 
has_insurance,
sum(admission_cost) as admission_total
from
(
   select patient_id,
   case when patient_id % 2 = 0 then 'Yes' else 'No' end as has_insurance,
   case when patient_id % 2 = 0 then 10 else 50 end as admission_cost
   from admissions
)
group by has_insurance


-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
select province_name from (
  SELECT
  province_name,
  SUM(gender = 'M') AS n_male,
  SUM(gender = 'F') AS n_female
  FROM 
  patients pa
  JOIN 
  province_names pr 
  ON pa.province_id = pr.province_id
  GROUP BY province_name
)
where n_male > n_female


-- We are looking for a specific patient. Pull all columns for the patient who matches:
-- - First_name contains an 'r' after the first two letters.
-- - Identifies their gender as 'F'
-- - Born in February, May, or December
-- - Their weight would be between 60kg and 80kg
-- - Their patient_id is an odd number
-- - They are from the city 'Kingston'
SELECT *
FROM patients
WHERE
  first_name LIKE '__r%'
  AND gender = 'F'
  AND MONTH(birth_date) IN (2, 5, 12)
  AND weight BETWEEN 60 AND 80
  AND patient_id % 2 = 1
  AND city = 'Kingston'


-- Show the percent of patients that have 'M' as their gender. 
-- Round the answer to the nearest hundreth number and in percent form.
SELECT
  round(100 * avg(gender = 'M'), 2) || '%' AS percent_of_male_patients
FROM patients;


-- For each day display the total amount of admissions on that day. 
-- Display the amount changed from the previous date.
select 
admission_date, 
admission_day, 
admission_day-prev_day as admission_count_change
from(
 select 
  admission_date, 
  count(*) as admission_day, 
  lag(count(*), 1) over() as prev_day  
  from admissions
  group by admission_date
)


-- Sort the province names in ascending order in such a way that the province 
-- 'Ontario' is always on top.
select province_name 
from province_names
order by 
	(case when province_name = 'Ontario' then 0 else 1 end),
    province_name












