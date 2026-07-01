# 📊 Global Workforce Disruption (2020–2023)
A SQL Analysis of Worldwide Layoffs

## Project Overview

This project demonstrates a complete SQL workflow using a global layoffs dataset.  
The objective is to clean raw layoff records, standardize inconsistent fields, remove duplicates,
handle missing values, and perform exploratory data analysis to identify layoff patterns by company,
industry, country, funding stage, and time.

This repository is designed as a portfolio project for data analyst roles.

## Business Questions

The analysis focuses on:

- Which companies had the largest total layoffs?
- Which industries were hit the hardest?
- Which countries recorded the highest layoffs?
- Which company stages were most affected?
- Which companies had 100% layoffs?
- How did layoffs evolve over time?
- What were the top layoff events by year?

## SQL Skills Demonstrated

- SELECT statements
- WHERE filtering
- GROUP BY aggregation
- HAVING vs WHERE
- LIMIT and aliases
- JOINs
- UNIONs
- String functions
- CASE statements
- Subqueries
- Window functions
- CTEs
- Temporary tables
- Stored procedures
- Triggers
- Events
- Data cleaning
- Exploratory data analysis

## Project Files

| File | Description |
|---|---|
| `01_sql_foundations_practice.sql` | Basic SQL syntax practice |
| `02_joins_unions_strings_case_subqueries.sql` | Intermediate SQL concepts |
| `03_windows_ctes_temp_procedures_triggers_events.sql` | Advanced SQL practice |
| `04_data_cleaning_project.sql` | Full data cleaning workflow |
| `05_exploratory_data_analysis.sql` | Full exploratory analysis workflow |

## Data Cleaning Process

The cleaning workflow includes:

1. Creating a staging table to protect the raw dataset.
2. Identifying duplicate records using `ROW_NUMBER()`.
3. Removing duplicate rows.
4. Trimming whitespace from company names.
5. Standardizing inconsistent industry values.
6. Standardizing country values.
7. Converting text dates into SQL `DATE` format.
8. Converting blank values into `NULL`.
9. Filling missing industry values using matching company records.
10. Removing rows that do not contain usable layoff magnitude information.

## Key Analysis Queries

The exploratory analysis includes:

- Layoffs by company
- Layoffs by industry
- Layoffs by country
- Layoffs by company stage
- Layoffs by year
- Layoffs by year-month
- Monthly rolling layoff totals
- Top 5 companies by layoffs per year using `DENSE_RANK()`

## Important Notes

- `percentage_laid_off = 1` is treated as a possible shutdown signal, but it should not be interpreted as
  confirmed closure without external validation.
- Month-only analysis can be misleading because it combines the same month across different years.
- Data type checks are critical before aggregation, especially when numeric columns are stored as text.

## Main Takeaway

This project shows a realistic SQL analyst workflow: preparing messy data, validating assumptions, cleaning inconsistencies, and extracting business insights through structured exploratory analysis.
