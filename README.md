# Data Cleansing

### The Table Of Contents

- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Data Preparation](#data-preparation)
- [Codes](#codes)


### Project Overview

This data cleaning and preparation project aims to demonstrate the step by step data cleaning process before making it available for **Exploratory Data Analysis**. The aim is to provide a clean data set to gain the accurate answers making buisness dicisions easy. The data sheds light on how companies laied off their empoyees at the time of Pandemic. 

### Data Source

The dataset used for the project has been taken from a GitHub repositry showcasing the drasting layoff duering the Pandemic. The raw data consited 2361 rows in total which came down to 1995 rows after cleanign the data. The data has details on Companies, Industries, Location, and Countires mass layoff.

### Data Preparation

The raw data (CSV) file was uploaded directly to the workbench without making any changes at the innitial stage. All the changes were done at the later stage (cleaning).
A duplicate data set was created to do all the cleaning without changing the raw data as a precaution.
The data did not have any "Primary Key" column, making it difficult to process. Hence, created a new column with the help of Row_Number function.


### Codes

**1. Duplicate table creation and data importing**

```sql
CREATE TABLE layoffs_staging
LIKE layoffs;
```
```sql
INSERT layoffs_staging
SELECT * FROM layoffs;
```

**2. New column creation (Row_Number)**

```sql
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
```

**3. CTE creation to analyse the duplicate entries**

```sql
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
from duplicate_cte
WHERE row_num > 1;
```

**4. A new table creation with the row_number column as MySQL doesn't allow column deletion in CTE**

```sql
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```
```sql
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
```

**5. Finding, Analysing and Deleting the duplicate entries**

```sql
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;
```
```sql
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
```

**6. Standerdizing Data : removed spaces/fullstops, words correction, data type change and formatting**

 - Space removal

```sql
SELECT company, trim(company)
FROM layoffs_staging2;
```
```sql
UPDATE layoffs_staging2
SET company = trim(company);
```

- Word correction

```sql
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
```
```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```

- Full stop removal

```sql
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';
```
```sql
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM Country)
WHERE country LIKE 'United States%';
```

- Date column formatting and data type change

```sql
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
```
```sql
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
```
```sql
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

**7. Null and Empty values check**

```sql
SELECT *
FROM layoffs_staging2
WHERE company IS NULL
OR company = '';
```

- Compared the columns for possible matching values through self join

```sql
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
```

- Replaced all the empty values with the NULL to update them together

```sql
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';
```
```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
```

**8. Droped row_number columns after all the possible changes**

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

> [!NOTE]
> The full coding details can be found on the SQL file attached to the repositry.
> Some of null values not been removed from certain columns as the other information in the row found to be usfull for EDA.

