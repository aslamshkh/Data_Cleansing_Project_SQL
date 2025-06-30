# 📉 Global Layoff Analaysis


## 📑 The Table Of Contents

- [Purpose](#purpose)
- [Performance Indicators](#performance-indicators)
- [Data Overview](#data-overview)
- [Initial Data Observations](#initial-data-observations)
- [Data Loading](#data-loading)
- [Data Cleaning And Transformation](#data-cleaning-and-transformation)
- [Data Exploration And Key Insights](#data-exploration-and-key-insights)

## 🎯 Purpose

During the global disruption caused by COVID-19, mass layoffs reshaped industries, economies, and livelihoods. This project uses SQL to clean and analyze real-world layoff data from the pandemic period—resolving inconsistencies, standardizing formats, and preparing the dataset for meaningful exploration.

Through structured SQL queries, the project uncovers key trends in layoff volume, industry impact, and geographic distribution—offering a data-driven lens into how different sectors and regions were affected. Built entirely in MySQL, the workflow emphasizes clarity, reproducibility, and readiness for downstream visualization or reporting.

---

## 📊 Performance Indicators

This project explores the global layoff landscape during the COVID-19 pandemic through a structured SQL-based analysis. The following performance indicators were used to uncover key patterns, outliers, and trends in the dataset.

### Primary Indicators

These metrics highlight the most significant layoff events and entities impacted:

- **Peak Layoff Day**: The single day with the highest number of reported layoffs.
- **Most Affected Company**: The organization with the largest total layoffs.
- **Most Impacted Industry**: The industry that experienced the highest cumulative layoffs.
- **Country with Peak Layoff Day**: The country that recorded the highest layoffs on a single day.

### Secondary Indicators

These provide supporting insights into the broader layoff distribution:

- **Minimum Layoff Event**: The lowest number of layoffs recorded in a single event.
- **Least Affected Company**: The company with the smallest layoff count (excluding zero).
- **Least Impacted Industry**: The industry with the lowest total layoffs.
- **Country with Lowest Layoffs**: The country with the smallest cumulative layoffs.

### Structural & Temporal Insights

These indicators help contextualize the layoffs across time and organizational structure:

- **100% Layoff Companies**: List of companies that reported complete workforce layoffs.
- **Layoff Date Range**: Start and end dates of the recorded layoff events.
- **Annual Layoff Totals**: Year-wise aggregation of total layoffs.
- **Monthly Layoff Totals**: Month-wise breakdown of layoffs across the timeline.
- **Layoff Progression**: Temporal trend showing how layoffs evolved over time.

---

## 📁 Data Overview

This project is based on a publicly available dataset that captures global layoff events during the COVID-19 pandemic. The dataset includes detailed records of layoffs across various companies, industries, and countries—highlighting the economic impact of the pandemic on the global workforce.

The data was sourced from a raw CSV file and processed using SQL for cleansing, transformation, and exploratory analysis. It serves as the foundation for uncovering patterns in layoff frequency, industry vulnerability, and geographic distribution.

### 🧾 Dataset Summary

- **Source**: Raw CSV file (uploaded locally)
- **Format**: CSV (Comma-Separated Values)
- **Rows**: 9,217 (including header)
- **Columns**: 11
- **Time Period Covered**: January 2020 to March 2023 (based on layoff dates)
- **Key Fields**: Copany, Industry, Total Layoffs, and Country
 
---

## 🔍 Initial Data Observations

A preliminary review of the raw layoff dataset revealed several structural and quality issues that required attention before analysis:

- **Duplicate Records**: Multiple identical entries were present across key fields such as company, location, industry, and layoff date, indicating potential redundancy.

- **Inconsistent Text Formatting**:
  - Company and country names included trailing spaces and punctuation (e.g., "United States.").
  - Industry names appeared with inconsistent labels (e.g., "Crypto Currency", "Crypto.com", etc.), requiring standardization.

- **Improper Date Format**: The `date` column was stored as plain text in `MM/DD/YYYY` format, which limited its usability for time-based analysis.

- **Missing and Empty Values**:
  - Several rows had missing or empty values in critical fields like `industry`, `total_laid_off`, and `percentage_laid_off`.
  - Some companies had partial data that could potentially be inferred from other entries.

- **Mixed Data Types**: Numeric fields such as `funds_raised_millions` and `total_laid_off` were inconsistently populated, and some text fields contained numeric-like values.

These observations highlighted the need for a structured data cleaning process to ensure consistency, accuracy, and analytical readiness.

---

## 📥 Data Loading

- The dataset was imported into MySQL using the following workflow:
  - Opened MySQL Workbench and created a new database schema for the project.
  - Used the `Table Data Import Wizard` to load the CSV file into a staging table (`layoffs_staging`).
  - Verified column mappings and data types during the import process to ensure alignment with the CSV structure.
  - Confirmed successful import by previewing the first few rows and checking for nulls or misaligned fields.

- A duplicate of the staging table was created to preserve the raw data and enable safe transformation during the cleaning phase.

---


## 🧹 Data Cleaning and Transformation

The dataset underwent a structured SQL-based cleaning process in MySQL to ensure consistency, accuracy, and readiness for analysis. Key transformations are outlined below:

<details>
<summary><strong>1. Duplicate Table Creation</strong></summary>

Created a staging table to preserve the original dataset and imported all records for safe transformation:  

```sql
CREATE TABLE layoffs_staging LIKE layoffs;  
INSERT layoffs_staging SELECT * FROM layoffs;
```
	
</details>

<details>
<summary><strong>2. Row Number Generation</strong></summary>


Added a row_num column using ROW_NUMBER() to identify potential duplicate entries based on key fields:  

```sql
SELECT *,  
ROW_NUMBER() OVER(  
  PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`  
) AS row_num  
FROM layoffs_staging;
```

</details>

<details>
<summary><strong>3. Duplicate Detection via CTE</strong></summary>

Used a Common Table Expression (CTE) to isolate duplicate records for review:  

```sql
WITH duplicate_cte AS (  
  SELECT *,  
  ROW_NUMBER() OVER(  
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions  
  ) AS row_num  
  FROM layoffs_staging  
)  
SELECT * FROM duplicate_cte  
WHERE row_num > 1;
```

</details>

<details>
<summary><strong>4. New Table with Row Number</strong></summary>


Created layoffs_staging2 to include the row_num column, as MySQL does not allow column deletion in CTEs:  

```sql
CREATE TABLE layoffs_staging2 (  
  company TEXT,  
  location TEXT,  
  industry TEXT,  
  total_laid_off INT DEFAULT NULL,  
  percentage_laid_off TEXT,  
  date TEXT,  
  stage TEXT,  
  country TEXT,  
  funds_raised_millions INT DEFAULT NULL,  
  row_num INT  
);  
INSERT INTO layoffs_staging2  
SELECT *,  
ROW_NUMBER() OVER(  
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions  
) AS row_num  
FROM layoffs_staging;
```

</details>

<details>
<summary><strong>5. Duplicate Removal</strong></summary>

Identified and removed duplicate rows based on the row_num column:  

```sql
SELECT * FROM layoffs_staging2 WHERE row_num > 1;  
DELETE FROM layoffs_staging2 WHERE row_num > 1;
```

</details>

<details>
<summary><strong>6. Standardizing Text Fields</strong></summary>

Trimmed whitespace, corrected inconsistent labels, and removed punctuation:  

```sql
UPDATE layoffs_staging2 SET company = TRIM(company);  
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';  
UPDATE layoffs_staging2  
SET country = TRIM(TRAILING '.' FROM country)  
WHERE country LIKE 'United States%';
```

</details>

<details>
<summary><strong>7. Date Formatting</strong></summary>

Converted the date column from text to proper DATE format:  

```sql
UPDATE layoffs_staging2  
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');  
ALTER TABLE layoffs_staging2  
MODIFY COLUMN `date` DATE;
```

</details>

<details>
<summary><strong>8. Handling Null and Empty Values</strong></summary>

Identified missing values and used self-joins to fill in missing industry data:  

```sql
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';  
UPDATE layoffs_staging2 t1  
JOIN layoffs_staging2 t2 ON t1.company = t2.company  
SET t1.industry = t2.industry  
WHERE (t1.industry IS NULL OR t1.industry = '')  
AND t2.industry IS NOT NULL;
```

</details>

<details>
<summary><strong>9. Cleanup</strong></summary>

Dropped the temporary row_num column after all transformations were complete:  

```sql
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
```

</details>

---

## 💡 Data Exploration and Key Insights

After cleaning and transforming the dataset in MySQL, I used SQL queries to explore patterns in layoff volume, industry impact, geographic distribution, and temporal trends. These insights helped shape the analytical narrative and guided the design of performance indicators.

<details>
<summary><strong>1. What was the highest layoff in a single day?</strong></summary>

```sql
SELECT MAX(total_laid_off) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/dd262210-fdaf-4bdf-9d87-1f21f140669d)

</details>

<details>
<summary><strong>2. Which company had the most layoffs?</strong></summary>

```sql
SELECT MAX(company), MAX(total_laid_off) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/efbe02d1-8fbc-4d99-a0b1-a3cb5b20002e)

</details>

<details>
<summary><strong>3. Which industry was most impacted?</strong></summary>

```sql
SELECT MAX(total_laid_off), MAX(industry) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/893ecaa3-9791-48e9-810e-98c7474a3270)

</details>

<details>
<summary><strong>4. Which country had the highest layoff in a day?</strong></summary>

```sql
SELECT MAX(total_laid_off), MAX(country) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/3e896dbd-00c8-41d1-af2e-f06139f313e5)

</details>

<details>
<summary><strong>5. What was the lowest number of layoffs?</strong></summary>

```sql
SELECT MIN(total_laid_off) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/226fb991-eaac-45d6-8082-9106f435999e)

</details>

<details>
<summary><strong>6. Which company had the lowest layoffs?</strong></summary>

```sql
SELECT MIN(company), MIN(total_laid_off) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/5b4b3306-66d4-4364-86fd-93f2f0ac60d1)

</details>

<details>
<summary><strong>7. Which industry was least impacted?</strong></summary>

```sql
SELECT MIN(industry), MIN(total_laid_off) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/ecef8370-962d-47d6-83ea-644e5ecf0a77)

</details>

<details>
<summary><strong>8. Which country had the lowest number of layoffs?</strong></summary>

```sql
SELECT MIN(total_laid_off), MIN(country) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/32eabea7-9f39-4fa0-81dd-efec9154f29a)

</details>

<details>
<summary><strong>9. Which companies had 100% layoffs?</strong></summary>

```sql
SELECT company, total_laid_off, percentage_laid_off  
FROM layoffs_staging2  
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL  
ORDER BY 2 DESC  
```
![image](https://github.com/user-attachments/assets/eef6d5b4-b62c-414e-8243-78b59f31775b)

</details>

<details>
<summary><strong>10. What was the date range for these layoffs?</strong></summary>

```sql
SELECT MIN(`date`), MAX(`date`) FROM layoffs_staging2  
```
![image](https://github.com/user-attachments/assets/4ded54f3-b49c-4951-8101-1863ff581cf1)

</details>

<details>
<summary><strong>11. What was the total layoff per year?</strong></summary>

```sql
SELECT YEAR(`date`), SUM(total_laid_off)  
FROM layoffs_staging2  
GROUP BY YEAR(`date`)  
ORDER BY 1 DESC  
```
![image](https://github.com/user-attachments/assets/1492fd81-5cf1-4ee8-9025-6c3792e43550)

</details>

<details>
<summary><strong>12. What was the total layoff per month?</strong></summary>

```sql
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)  
FROM layoffs_staging2  
WHERE SUBSTRING(`date`,1,7) IS NOT NULL  
GROUP BY `MONTH`  
ORDER BY 1  
```
![image](https://github.com/user-attachments/assets/9a3dde58-3bc0-4f0c-81f7-690663e3b8a6)

</details>

<details>
<summary><strong>13. What was the progression of layoffs over time?</strong></summary>

```sql
WITH Rolling_Total AS (  
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laidoff  
FROM layoffs_staging2  
WHERE SUBSTRING(`date`,1,7) IS NOT NULL  
GROUP BY `MONTH`  
ORDER BY 1  
)  
SELECT `MONTH`, total_laidoff, SUM(total_laidoff) OVER(ORDER BY `MONTH`) AS rolling_total  
FROM Rolling_Total  
```
![image](https://github.com/user-attachments/assets/37e16502-43c4-48f2-9d84-36f0cfb81e5d)

</details>

---

> [!NOTE]
> The full coding details can be found on the SQL file attached to the repositry. Some of null values not been removed from certain columns as the other information in the row found to be usfull for EDA.
