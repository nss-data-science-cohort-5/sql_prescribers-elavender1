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
SELECT drug_name, AVG(total_drug_cost_ge65) / AVG(total_day_supply_ge65) AS daily_unit_drug_cost
FROM prescription
WHERE total_drug_cost_ge65 IS NOT NULL AND total_drug_cost_ge65 <> 0
GROUP BY drug_name
ORDER BY daily_unit_drug_cost DESC
LIMIT 10
--3b) Carimune NF Nanofiltered cost $3188.16 per daily dose cost.

--5a)
SELECT count(distinct cbsa)


--5c)
SELECT population, county
FROM population
FULL JOIN cbsa
USING (fipscounty)
FULL JOIN fips_county
USING (fipscounty)
WHERE cbsa IS NULL
AND population IS NOT NULL
ORDER BY population DESC
--Sevier is the smallest

--6a) Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC
LIMIT 10
--6b) For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, 
	total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'not_opioid'
	END AS is_opioid
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC
LIMIT 10
--6C) Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, 
	total_claim_count,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'not_opioid'
	END AS is_opioid
FROM prescription
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC
LIMIT 10

--7a)
SELECT npi, drug_name
FROM prescriber
FULL JOIN prescription
USING (npi)
FULL JOIN drug
USING (drug_name)
WHERE specialty_description='Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
LIMIT 10

--7B)  Next, report the number of claims per drug per prescriber. 
--Be sure to include all combinations, whether or not the prescriber had any claims. 
--You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT npi, drug_name, sum(total_claim_count) AS sum_claim_count
FROM prescriber
FULL JOIN prescription
USING (npi)
FULL JOIN drug
USING (drug_name)
WHERE specialty_description='Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY npi, drug_name
LIMIT 10

--7c) Finally, if you have not done so already, fill in any 
--missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT npi, drug_name, COALESCE(total_claim_count, 0) AS sum_claim_count
FROM prescriber
FULL JOIN prescription
USING (npi)
FULL JOIN drug
USING (drug_name)
WHERE specialty_description='Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY npi, drug_name, sum_claim_count
ORDER BY sum_claim_count DESC








