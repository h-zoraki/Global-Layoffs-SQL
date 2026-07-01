-- =====================================================================
-- PROJECT: Workforce Shockwaves: Global Layoffs SQL Analysis
-- Focus: SQL foundations, data cleaning, exploratory data analysis, and
-- advanced SQL techniques using employee practice tables and a global
-- layoffs dataset.
--
-- SQL Dialect: MySQL
-- Main dataset tables:
--   - layofff_raw          : raw layoffs table
--   - layofff_raw2         : staging copy of raw data
--   - layoffs_staging2     : cleaned layoffs table
--
-- Practice dataset tables:
--   - employee_demographics
--   - employee_salary
--   - parks_departments
-- =====================================================================


-- =====================================================================
-- SECTION 1: SQL FOUNDATIONS PRACTICE
-- Concepts: SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT, aliases
-- Dataset: employee_demographics, employee_salary
-- =====================================================================

-- 1.1 SELECT all columns
SELECT *
FROM employee_demographics;

-- 1.2 SELECT specific columns
SELECT first_name,
       last_name,
       age,
       gender
FROM employee_demographics;

-- 1.3 WHERE filters
SELECT *
FROM employee_salary
WHERE salary > 50000;

SELECT *
FROM employee_demographics
WHERE age >= 40;

-- 1.4 GROUP BY aggregation
SELECT gender,
       AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender;

SELECT dept_id,
       AVG(salary) AS avg_salary
FROM employee_salary
GROUP BY dept_id;

-- 1.5 WHERE vs HAVING
-- WHERE filters rows before aggregation.
SELECT dept_id,
       salary
FROM employee_salary
WHERE salary > 50000;

-- HAVING filters grouped results after aggregation.
SELECT dept_id,
       AVG(salary) AS avg_salary
FROM employee_salary
GROUP BY dept_id
HAVING AVG(salary) > 60000;

-- 1.6 ORDER BY, LIMIT, and aliases
SELECT first_name AS employee_first_name,
       last_name AS employee_last_name,
       salary AS annual_salary
FROM employee_salary
ORDER BY salary DESC
LIMIT 5;


-- =====================================================================
-- SECTION 2: JOINS, UNIONS, STRING FUNCTIONS, CASE, SUBQUERIES
-- Concepts: INNER JOIN, multi-table joins, UNION, string functions,
-- CASE expressions, subqueries
-- Dataset: employee_demographics, employee_salary, parks_departments
-- =====================================================================

-- 2.1 INNER JOIN
SELECT dem.first_name,
       dem.last_name,
       sal.occupation,
       sal.salary
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
    ON dem.employee_id = sal.employee_id;

-- 2.2 Joining multiple tables with CASE segmentation
SELECT dem.first_name,
       dem.last_name,
       sal.salary,
       dept.department_name,
       CASE
           WHEN sal.salary > 70000 AND dept.department_name = 'Public Works' THEN 'Top Tier'
           WHEN sal.salary > 50000 THEN 'Mid Tier'
           ELSE 'Low Tier'
       END AS salary_category
FROM employee_demographics AS dem
JOIN employee_salary AS sal
    ON dem.employee_id = sal.employee_id
JOIN parks_departments AS dept
    ON sal.dept_id = dept.department_id;

-- 2.3 UNION removes duplicates by default
SELECT first_name,
       last_name
FROM employee_demographics
UNION
SELECT first_name,
       last_name
FROM employee_salary;

-- 2.4 String functions
SELECT first_name,
       last_name,
       CONCAT(first_name, ' ', last_name) AS full_name,
       LENGTH(first_name) AS first_name_length,
       UPPER(first_name) AS upper_first_name,
       LOWER(last_name) AS lower_last_name
FROM employee_demographics;

-- 2.5 CASE statement: salary bands
SELECT first_name,
       last_name,
       salary,
       CASE
           WHEN salary BETWEEN 50000 AND 70000 THEN 'Standard Salary Band'
           WHEN salary BETWEEN 70001 AND 80000 THEN 'High Salary Band'
           ELSE 'Executive or Outlier Band'
       END AS salary_band
FROM employee_salary;

-- 2.6 CASE statement: bonus calculation
SELECT first_name,
       last_name,
       salary,
       CASE
           WHEN salary < 50000 THEN salary * 1.05
           WHEN salary > 50000 THEN salary * 1.07
           ELSE salary
       END AS adjusted_salary,
       CASE
           WHEN dept_id = 6 THEN salary * 1.10
       END AS department_bonus
FROM employee_salary;

-- 2.7 Subquery
SELECT *
FROM employee_demographics
WHERE employee_id IN (
    SELECT employee_id
    FROM employee_salary
    WHERE dept_id = 1
);


-- =====================================================================
-- SECTION 3: ADVANCED SQL PRACTICE
-- Concepts: window functions, CTEs, temporary tables, stored procedures,
-- triggers, and events
-- Dataset: employee_demographics, employee_salary
-- =====================================================================

-- 3.1 Window function: ROW_NUMBER
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY gender
           ORDER BY age DESC
       ) AS row_num
FROM employee_demographics;

-- 3.2 Common Table Expression (CTE)
WITH high_salary_employees AS (
    SELECT employee_id,
           first_name,
           last_name,
           salary
    FROM employee_salary
    WHERE salary >= 50000
)
SELECT *
FROM high_salary_employees
ORDER BY salary DESC;

-- 3.3 Temporary table
CREATE TEMPORARY TABLE temp_table (
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    favorite_movie VARCHAR(100)
);

INSERT INTO temp_table
VALUES ('Alex', 'Freberg', 'Lord of the Rings: The Twin Towers');

SELECT *
FROM temp_table;

-- 3.4 Temporary table from SELECT
CREATE TEMPORARY TABLE salary_over_50k AS
SELECT *
FROM employee_salary
WHERE salary > 50000;

SELECT *
FROM salary_over_50k;

-- 3.5 Stored procedure
DELIMITER $$

CREATE PROCEDURE large_salaries2()
BEGIN
    SELECT *
    FROM employee_salary
    WHERE salary >= 50000;

    SELECT *
    FROM employee_salary
    WHERE salary >= 10000;
END $$

DELIMITER ;

-- To run:
-- CALL large_salaries2();

-- 3.6 Trigger
-- Automatically inserts basic employee information into
-- employee_demographics when a new employee is inserted into employee_salary.
DELIMITER $$

CREATE TRIGGER employee_insert
AFTER INSERT ON employee_salary
FOR EACH ROW
BEGIN
    INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$

DELIMITER ;

-- Test trigger
INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (15, 'Super', 'Mario', 'Toy Designer', 90000, 0);

-- 3.7 Event scheduler check
SHOW VARIABLES LIKE 'event%';

-- 3.8 Event
-- Requires event_scheduler = ON.
DELIMITER $$

CREATE EVENT remove_senior_records_event
ON SCHEDULE EVERY 10 SECOND
DO
BEGIN
    DELETE
    FROM employee_demographics
    WHERE age > 60;
END $$

DELIMITER ;


-- =====================================================================
-- SECTION 4: DATA CLEANING PROJECT
-- Dataset: Global layoffs
-- Raw table: layofff_raw
-- Cleaned table: layoffs_staging2
-- Concepts: staging tables, duplicate removal, standardization,
-- date conversion, NULL handling, and irrelevant row deletion
-- =====================================================================

-- 4.1 Inspect raw data
SELECT *
FROM layofff_raw;

-- 4.2 Create staging table
-- Best practice: never clean directly on raw data.
CREATE TABLE layofff_raw2
LIKE layofff_raw;

INSERT INTO layofff_raw2
SELECT *
FROM layofff_raw;

SELECT *
FROM layofff_raw2;

-- 4.3 Identify duplicates using ROW_NUMBER()
-- Rows with row_num > 1 are duplicate candidates.
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country,
                        funds_raised_millions
       ) AS row_num
FROM layofff_raw2;

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage, country,
                            funds_raised_millions
           ) AS row_num
    FROM layofff_raw2
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 4.4 Create duplicate-removal staging table
-- MySQL does not always allow direct DELETE from a CTE.
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country,
                        funds_raised_millions
       ) AS row_num
FROM layofff_raw2;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- 4.5 Standardize text fields

-- Trim company names
SELECT company,
       TRIM(company) AS trimmed_company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country values
SELECT DISTINCT country,
       TRIM(TRAILING '.' FROM country) AS standardized_country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 4.6 Convert date text into DATE type
-- Original format assumed: m/d/Y
SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS new_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 4.7 Handle blank and NULL industry values

-- Convert blanks to NULL for consistency
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industry values using known company values
SELECT t1.company,
       t1.industry AS missing_industry,
       t2.industry AS known_industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- 4.8 Remove rows that do not support analysis
-- If both total_laid_off and percentage_laid_off are NULL,
-- the row does not contain useful layoff magnitude information.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 4.9 Final cleaned table
SELECT *
FROM layoffs_staging2;


-- =====================================================================
-- SECTION 5: EXPLORATORY DATA ANALYSIS
-- Dataset: Global layoffs
-- Cleaned table: layoffs_staging2
-- Concepts: aggregations, time series, rolling totals, CTEs, rankings
-- =====================================================================

-- 5.1 Country-level checks
SELECT country,
       MAX(total_laid_off) AS max_total_laid_off,
       MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY country ASC;

-- Important: always verify column data types before aggregation.
-- Text columns can create wrong sorting or aggregation behavior.
-- Example:
-- ALTER TABLE layoffs_staging2
-- MODIFY funds_raised_millions INT;

-- 5.2 Companies with 100% layoffs
-- This is a strong shutdown / closure signal, but not guaranteed.
-- Validate with company context before making final claims.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- 5.3 Companies hit the most
SELECT company,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- 5.4 Industries hit the most
SELECT industry,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- 5.5 Countries hit the most
SELECT country,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- 5.6 Company stages hit the most
SELECT stage,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- 5.7 Dataset time range
SELECT MIN(`date`) AS first_layoff_date,
       MAX(`date`) AS last_layoff_date
FROM layoffs_staging2;

-- 5.8 Layoffs by exact date
SELECT `date`,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `date`
ORDER BY `date` ASC;

-- 5.9 Layoffs by year
SELECT YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;

-- 5.10 Layoffs by month number only
-- Warning: this mixes different years together.
-- January 2020 and January 2023 are grouped together.
-- Useful for seasonality only, not timeline analysis.
SELECT MONTH(`date`) AS month_number,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month_number
HAVING month_number IS NOT NULL
ORDER BY month_number ASC;

-- 5.11 Layoffs by year-month
-- Better timeline view than month number alone.
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `year_month`,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `year_month`
ORDER BY `year_month` ASC;

-- 5.12 Rolling total of layoffs by month
WITH rolling_total AS (
    SELECT DATE_FORMAT(`date`, '%Y-%m') AS `year_month`,
           SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY `year_month`
)
SELECT `year_month`,
       monthly_layoffs,
       SUM(monthly_layoffs) OVER (ORDER BY `year_month`) AS rolling_total_layoffs
FROM rolling_total
ORDER BY `year_month` ASC;

-- 5.13 Layoffs by company and year
SELECT company,
       YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

-- 5.14 Highest company layoffs by year
SELECT company,
       YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- 5.15 Example CTE filter
WITH company_year AS (
    SELECT company,
           YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
)
SELECT *
FROM company_year
WHERE company = 'Dell';

-- 5.16 Rank companies by layoffs within each year
WITH company_year AS (
    SELECT company,
           YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
)
SELECT *,
       DENSE_RANK() OVER (
           PARTITION BY year
           ORDER BY total_laid_off DESC
       ) AS ranking
FROM company_year
WHERE year IS NOT NULL
ORDER BY year ASC, ranking ASC;

-- 5.17 Top 5 companies by layoffs each year
WITH company_year AS (
    SELECT company,
           YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
company_year_rank AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY year
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
    WHERE year IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5
ORDER BY year ASC, ranking ASC;
