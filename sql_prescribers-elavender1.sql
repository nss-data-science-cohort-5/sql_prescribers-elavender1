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

--4a)
SELECT drug_name,
		CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
			WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
			ELSE 'neither'
			END AS drug_type
FROM drug
ORDER BY drug_type
--
--4b)
SELECT 
		CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
			WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
			ELSE 'neither'
			END AS drug_type,
			SUM(total_drug_cost)::money AS total_drug_cost
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY drug_type
ORDER BY total_drug_cost DESC
--opioids are more expensive than antibiotics but not as expensive as the neither category.

--5a)
SELECT count(distinct cbsa)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN'
--10 in Tennessee

--5b)
SELECT cbsaname,
	   SUM(population) AS total_population 
FROM cbsa
INNER Join fips_county
USING (fipscounty)
INNER Join population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population 
--"Nashville-Davidson--Murfreesboro--Franklin, TN" has the largest total population at 1830410. "Morristown, TN" has the smallest at 116352.


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
--Sevier has the highest population with no cbsa.

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

--part 2.1)
SELECT COUNT(npi)
FROM prescriber 
WHERE npi NOT IN 
	(SELECT npi
	FROM prescription)
--
--2.2a) Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
--SELECT specialty_description, sum(total_claim_count) AS total_count
SELECT generic_name, SUM(total_claim_count) AS sum_total_ct
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY sum_total_ct DESC
limit 5
--2.2B Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name, SUM(total_claim_count) AS sum_total_ct
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY sum_total_ct DESC
limit 5
--2.2C Which drugs appear in the top five prescribed for both Family Practice prescribers and Cardiologists? 
--Combine what you did for parts a and b into a single query to answer this question.
SELECT generic_name, SUM(total_claim_count) AS sum_tot_ct
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE specialty_description = 'Cardiology' OR specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY sum_tot_ct DESC
limit 5
--2.3a)  First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims 
--(total_claim_count) across all drugs. 
--Report the npi, the total number of claims, and include a column showing the city.
SELECT npi, SUM(total_claim_count) AS total_num_claims, nppes_provider_first_name || ' ' || nppes_provider_last_org_name AS provider, nppes_provider_city 
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, provider, nppes_provider_city
ORDER BY total_num_claims DESC
LIMIT 5
--2.3b) Same for Memphis
SELECT npi, SUM(total_claim_count) AS total_num_claims, nppes_provider_first_name || ' ' || nppes_provider_last_org_name AS provider, nppes_provider_city 
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, provider, nppes_provider_city
ORDER BY total_num_claims DESC
LIMIT 5
--2.3C) Combine above with Knoxville and Chattanooga
SELECT npi, SUM(total_claim_count) AS total_num_claims, nppes_provider_first_name || ' ' || nppes_provider_last_org_name AS provider, nppes_provider_city 
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE nppes_provider_city = 'MEMPHIS' OR nppes_provider_city = 'NASHVILLE' OR nppes_provider_city = 'KNOXVILLE' OR nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi, provider, nppes_provider_city
ORDER BY total_num_claims DESC
LIMIT 20
--2.4 Find all counties which had an above-average (for the state) number of overdose deaths in 2017. 
--Report the county name and number of overdose deaths.
SELECT county, state, overdose_deaths
FROM fips_county
INNER JOIN overdose_deaths
USING (fipscounty)
WHERE year = '2017' AND overdose_deaths >
	(SELECT AVG(overdose_deaths) AS avg_overdose
	FROM overdose_deaths
	INNER JOIN fips_county
	USING (fipscounty)
	WHERE year = '2017' AND state = 'TN')
GROUP BY county, state, overdose_deaths
ORDER BY overdose_deaths
--21 counties 

SELECT *
FROM overdose_deaths
INNER JOIN fips_county
USING (fipscounty)
WHERE year = 2017
OrDER BY overdose_deaths DESC
limit 50
--2.5 find total population of TN
SELECT sum(population) AS tn_total_population
FROM population
INNER JOIN fips_county
USING (fipscounty)
--total population is 6,597,381

--2.5b Build off of the query that you wrote in part a to write a query that returns for each county that county's name, 
--its population, and the percentage of the total population of Tenn
SELECT county, population, round(100 * population / (SELECT sum(population) 
	FROM population
	INNER JOIN fips_county
	USING (fipscounty)), 2) AS percent_population
FROM population
INNER JOIN fips_county
USING (fipscounty)

--Using CTEs
WITH state_pop AS 
(
SELECT SUM(population) AS state_population
FROM population
INNER JOIN fips_county
USING (fipscounty)
),

county_pop AS 
(
SELECT county, SUM(population) AS county_population
FROM population
INNER JOIN fips_county
USING (fipscounty)
GROUP BY county
)

SELECT county, county_population,
	ROUND(county_population * 100.00/ (SELECT state_population FROM state_pop), 2) AS percentage
	FROM county_pop


