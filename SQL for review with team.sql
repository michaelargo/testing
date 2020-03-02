USE [BluePrism]
GO

-- -------------------------------------------------------------
-- Basics
-- Exercise 1
-- -------------------------------------------------------------

SELECT 
*
  FROM [dbo].[BPASession]

-- proper way to count
SELECT 
count(0)
  FROM [dbo].[BPASession]

-- concat example and data conversion example
SELECT 
'the session number ' +  cast(sessionnumber as varchar(7)) + ' completed at ' + cast(enddatetime as varchar(15)) + ' with the last stage being ' + laststage
  FROM [dbo].[BPASession]

  --where sessionnumber = 2

-- -------------------------------------------------------------
-- Excercise 2 
-- Agregate functions
-- -------------------------------------------------------------

SELECT statusid, count(0)
  FROM [dbo].[BPASession]
  group by statusid
  -- having count(0) > 2

-- -------------------------------------------------------------
-- Excersise 3
-- Joining Tables
-- -------------------------------------------------------------


select * FROM [dbo].[BPASession]

select * from [dbo].[BPASessionLog_NonUnicode]

-- join - demonstrate redundant data
select * from [dbo].[BPASession] S,
	[dbo].[BPASessionLog_NonUnicode] L
	where s.sessionnumber = l.sessionnumber
	and s.sessionnumber = 2

-- -------------------------------------------------------------
-- Excercise 4
-- Using System tables
-- -------------------------------------------------------------

-- Identify all tables with a userid column

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME like '%userid%'


-- -------------------------------------------------------------
-- Excercise 5
-- Using System tables
-- -------------------------------------------------------------


SELECT 'select * from ' + TABLE_NAME + ' where userid in (select userid from bpauser where isdeleted = 1)'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'userid'
