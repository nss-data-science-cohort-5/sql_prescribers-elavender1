--1)
SELECT max(total_claim_count)
FROM prescription

SELECT nppes_provider_last_org_name, nppes_provider_first_name, total_claim_count
FROM prescriber
INNER JOIN prescription
USING (npi)
ORDER BY total_claim_count DESC
--David Coffey 4538

--2a)
SELECT specialty_description, SUM(total_claim_count) AS total_claim_count_sum
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_count_sum DESC
--2A) FAMILY PRACTICE had the highest total_claim_count_sum at 9752347

--2B)
SELECT specialty_description, sum(total_claim_count) AS sum_total_claim_count
FROM PRESCRIPTION
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY sum_total_claim_count DESC
--2b) Nurse Practitioner's have the highest total_claim_count for opiods at 900845. 

--3a)
SELECT drug_name, total_drug_cost_ge65 
FROM prescription
WHERE total_drug_cost_ge65 IS NOT NULL
ORDER BY  total_drug_cost_ge65 desc
--3A) the most expensive drug is ESBRIET at $2680332.75 (? on dollars)

--3B)
SELECT drug_name, total_day_supply_ge65 / total_drug_cost_ge65 AS daily_cost_per_unit_drug
FROM prescription
WHERE 
(total_drug_cost_ge65 IS NOT NULL
AND total_drug_cost_ge65 <> 0)
GROUP BY drug_name
ORDER BY daily_cost_per_unit_drug DESC, drug_name
LIMIT 10





