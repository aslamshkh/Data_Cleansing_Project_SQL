-- Creating a databse

CREATE DATABASE world_layoffs;

-- Entering to the databse

USE world_layoffs;


-- Checkign all the avaialble tables and their contents

SHOW TABLES;

SELECT * FROM layoffs;


-- Data Cleaning Process

-- 1. Removing Duplicats
-- 2. Standerdization (empty spaces, special charecters etc).
-- 3. Dealing with Null/Empty values
-- 4. Dealing with Unwanted Columns/Rows
 
 
-- Creating a duplicate table for the modifications

CREATE TABLE layoffs_staging
LIKE layoffs;


-- Copying the table content from the raw table 

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- Using the ROW_Number function to find out the duplicate entires in the table as we do not have the Unique Row ID Column in the table

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Creating CTE to find the duplicate entries

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT * 
from duplicate_cte
WHERE row_num > 1;

-- Checkign the duplicate entries with Company names eg. Oda

SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

-- Found some duplicate and non duplicate entries. Hence, partitioning on all the columns to remove all the non duplicate entries. 

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

-- Checkign the duplicate entries with company name again

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Deleting duplicate rows with the DELETE function

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
from duplicate_cte
WHERE row_num > 1;

-- Creating stating2 table due to an error while deleting rows from the CTE 

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

-- Checkign the table after its execution sucessfully
SELECT * 
FROM layoffs_staging2;

-- Copied the data from staging1 table with the row_num column

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Checkign the table after importing the data

SELECT * 
FROM layoffs_staging2;

-- Filtering the duplicate enteries with the help of row_num column

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;


-- Deleting the duplicate rows

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Checkign the table after deleting the duplicate rows

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standerdizing Data : Finding ussuse in the data and fixing it

-- Checkign the first column for issues

SELECT DISTINCT(company)
FROM layoffs_staging2;

-- Found a company name with extra spaces. Hence, checking and removing them with the TRIM function

SELECT company, trim(company)
FROM layoffs_staging2;

-- Now updating the trimed company column to the table. 

UPDATE layoffs_staging2
SET company = trim(company);

-- Checkign the table after the first column updation

SELECT * 
FROM layoffs_staging2;

-- Checkign the 2nd column Industry

SELECT DISTINCT(industry)
FROM layoffs_staging2;

-- No spaces found but found industry name mentioned differently. Hence, ordering them by Order By function

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- Checkign all the enteries for Crypto to check if they are same or different

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- Updating industry Crypto, Crypto Currency, and CryptoCurrency to Crypto as they all are the same but mentioned differently

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Checking the industry column again after updating the Crypto to make sure they are corrected

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- Checkign the next column location

SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

-- Checkign the next column country as everything seems fine with the previous column

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

-- Removed a fullstop from United State

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- Checkign the Trim function and comparing them

SELECT DISTINCT country, TRIM(TRAILING '.' FROM Country)
FROM layoffs_staging2
ORDER BY 1;

-- Updating the changes to the table

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM Country)
WHERE country LIKE 'United States%';

-- Checking if the changes are updated correctly

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

-- The date column was kept as text to change later. Now changing string to date and changing the format as well

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


-- Updating the new formated date column

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Checkign if the date column has been upated correctly

SELECT `date`
FROM layoffs_staging2;

-- Updating the date column data type

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- We are goign to work on Null and Empty values in the table

-- Checkign the entire table column wise for null and empty values

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE company IS NULL
OR company = '';

-- Checking the second column location for null/empty values as none found in the 1st

SELECT	*
FROM layoffs_staging2
WHERE location IS NULL
OR location = '';

-- Checking the 3rd column industry for null/empty values as none found in the previous columns

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Found entries with null and empty values. 
-- Checkign all of the companies to see if we could populate values from other rows.

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Found Airbnb with industry values, will update all other with self join function

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Updating with the industry values from the matching column values

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Its been updated but 0 row affected. Hence, making some changes like converting all empty values to NULL

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

-- Checking if the empty values have been replaced with NULL values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- Updating the inductry column after replacing all the empty values with NULL

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Checking if all the entries are updated 

SELECT company, industry
FROM layoffs_staging2
WHERE industry IS NULL;

-- Checking company Bally's for possible industry null value as all other are updated

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Found only 1 entry with no infomation to populate. Hence, leaving it

-- Checking Total Laid Off and Percentage Laid Off columns for null/empty values

SELECT * 
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');


-- Deleting null/empty values as no way to populate the them 

DELETE
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');

-- Check if there is any null/empty values remains

SELECT * 
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');

SELECT *
FROM layoffs_staging2;

--  Drpping the Row Number columns as almost all the data has been standerdized and remainign null values that has no specific instructions remain

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Checkign if the Row Number column has been deleted

SELECT * 
FROM layoffs_staging2;
