-- This a Data Cleaning Project using the Layoffs Dataset layoffs
-- The Data was imported into SQL after the DATABASE was created


-- This is a summary of all the tasks that will performed to clean the Data:
-- 1. Remove Duplicates
-- 2. Standarize the Data 
-- 3. NULL and BLANK values
-- 4. Remove Unnecessary Columns

-- We verify if the Data was imported successfully 
SELECT *
FROM layoffs;


-- We create a copy of the Data that we will put into a second table 

CREATE TABLE layoffs_copy
LIKE layoffs;

-- We verify if the new table was created successfully 
SELECT *
FROM layoffs_copy;

-- We insert the Data into the new table
INSERT INTO layoffs_copy
SELECT *
FROM layoffs;

-- We verify if the Data was copied successfully
SELECT *
FROM layoffs_copy;


-- Remove Duplicates

SELECT *
FROM layoffs_copy;

-- We identify the rows that are duplicates
WITH duplicate_cte AS
(
SELECT *, 
       ROW_NUMBER() OVER( 
       PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Delete the Duplicate rows
-- Since we can't delete these rows using the CTE we will create a new table with all the DATA and then we will detele the Duplicate rows
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_copy2
SELECT *, 
       ROW_NUMBER() OVER( 
       PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy; 

DELETE
FROM layoffs_copy2
WHERE row_num > 1;


-- Standarize the Data 

-- We remove the White spaces
SELECT company, TRIM(company)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company = TRIM(company);

-- The column industry has different values to represent Crypto, it must be corrected
SELECT DISTINCT industry
FROM layoffs_copy2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

-- The column country also has values that are not written consistently
SELECT DISTINCT country
FROM layoffs_copy2
WHERE country LIKE '%United States%';

UPDATE layoffs_copy2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%United States%';

-- The 'date' column was imported in text format alter
UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;


-- Dealing with NULL and BLANK values

-- For the missing values in industry we will try to populate based on the name of the company
SELECT *
FROM layoffs_copy2
WHERE industry IS NULL
OR industry ='';

UPDATE layoffs_copy2
SET industry = NULL
WHERE industry ='';

SELECT DISTINCT tb1.company, tb1.industry, tb2.industry
FROM layoffs_copy2 tb1
JOIN layoffs_copy2 tb2
     ON tb1.company = tb2.company
     AND tb1.location = tb2.location
WHERE tb1.industry IS NULL
AND tb2.industry IS NOT NULL;

UPDATE layoffs_copy2 tb1
JOIN layoffs_copy2 tb2
     ON tb1.company = tb2.company
     AND tb1.location = tb2.location
SET tb1.industry = tb2.industry
WHERE tb1.industry IS NULL
AND tb2.industry IS NOT NULL;

-- The rows where the columns total_laid_off and percentage_laid_off are Null will be removed since they won't help in our analysis
SELECT *
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_copy2
DROP COLUMN row_num;