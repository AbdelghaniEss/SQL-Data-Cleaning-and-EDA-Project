-- Exploratory Data Analysis

-- Looking at the Max percentage of laid offs and the Max number of laid offs 
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_copy2; 
-- In this case 1 means 100%

-- Looking at the names of companies that had 100% laid offs along with their total number 
SELECT company, total_laid_off
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- We see that the companies are small to medium when it comes to those that had a 100% laid off

-- Let's have a look at the funds some of these companies raised
SELECT DISTINCT company, funds_raised_millions, `date`
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- That's really surprising we see some companies that recorded funds in Billions and still closed
-- I added the date after to see if maybe Covid was the reason for this, well Britishvolt closed in 2023 which is 3 years after Covid so we can't tell
-- On the other hand Guibi shut down in 2020 so it's fair to say it's one of many victims of Covid
-- For the other companies the date vary from to another but personally I believe that most of them closed due to Covid, now we are in 2024 and there still some repercussions cause by Covid

-- Now let's look at the sum of laids but including all companies
SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company
ORDER BY 2 DESC;
-- Well here we see some big names and the number of laid offs confirms it

-- Let's look at the date period where all these laid offs took place
SELECT MAX(`date`), MIN(`date`)
FROM layoffs_copy2;
-- Like what I said earlier, the Covid was the main culprit

-- What about the industry to was hit the most because of this, let's have a look
SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 2 DESC;
-- Retail makes a lot of sense since the shops were closed due to quarantine, same for transportation and consumer 
-- On the hand we see Fin-Tech was one of the lowest wich also makes very sense since this was the moment the shit to remote work started and it depended heavely on Technologies in general

-- Let's the countries now but it's pretty obvious wich one will be on Top
SELECT country, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY country
ORDER BY 2 DESC;
-- Yep, no surprise in there, the United States is the number one and India being second also makes sense

-- Let's have a look at the year that had the most laid offs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- That's actually surprising I expected 2020 to record the most laid offs but maybe because the pendemic started a few months into it, but then 2021 have a very small number compared to 2022 and 2023
-- Btw the data for 2023 is only up to March so the number will be a lot higher by the end of the year

-- What about the Stage, in case you wonder what stage think of it as ranking system for companies Stage A being the lowest or more accuratly the smallest till we get to the large firms like Google, Amazon and so on
-- The large firms are represented by Post-IPO
SELECT stage, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;
-- No surprise here, we saw Google and Amazon's numbers earlier so this makes perfect sense

-- Rolling Total of Layoffs Per Month and Year
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_copy2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total
FROM layoffs_copy2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, SUM(total) OVER(ORDER BY(`month`)) AS Rolling_per_Month, total
FROM Rolling_Total;
-- As we can see there is a pattern here, 2020 obviously had a high number of laid offs, then it subsided in 2021 and the numbers started increasing in 2022 and it's still the case even 2023

-- Now what we will try to do is find the wich companies rank in the top 5 in laid offs and partition it by year (2020,2021 and so on)
WITH Company_laid_per_year (company, `year`, total) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC
),
Company_rank AS
(
SELECT *, 
       DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total DESC) AS ranking
FROM Company_laid_per_year
WHERE `year` IS NOT NULL)
SELECT *
FROM Company_rank
WHERE ranking <= 5;
-- Most of what can be deduced from the resutls were already discovered before this was more of a challenge to test my SQL skills