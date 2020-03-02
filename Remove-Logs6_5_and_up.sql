	-- Author: Phil Cornelissen
	-- Date: 2019/08/07
	-- Version: 1.2
	-- Description: Script for cleaning Sessions and Sessions Logs in the Blue Prism database.
	--				Please change @daystokeep as is appropriate for your data retention policies.
	-- DBA Approval initial and date: VT 2019/08/07
	-- CS Approval initial and date:

	-- Check to see if previously created temporary tables exist, drop if so
	IF OBJECT_ID('tempdb..#BPASessionLog') IS NOT NULL DROP TABLE #BPASessionLog;
	IF OBJECT_ID('tempdb..#BPASessionLog_Unicode') IS NOT NULL DROP TABLE #BPASessionLog_Unicode;
	IF OBJECT_ID('tempdb..#BPASessionLog_NonUnicode') IS NOT NULL DROP TABLE #BPASessionLog_NonUnicode;
	IF OBJECT_ID('tempdb..#Sessions') IS NOT NULL DROP TABLE #Sessions;
	IF OBJECT_ID('tempdb..#ProcessedRows') IS NOT NULL DROP TABLE #ProcessedRows;
	GO

	-- Check to see if old constraints exist and drop if so
	IF OBJECT_ID('FK_BPASessionLog_NonUnicode_BPASession_pre65','F') IS NOT NULL
		ALTER TABLE [BPASessionLog_NonUnicode_pre65] DROP CONSTRAINT [FK_BPASessionLog_NonUnicode_BPASession_pre65];
	IF OBJECT_ID('FK_BPASessionLog_Unicode_BPASession_pre65','F') IS NOT NULL
		ALTER TABLE [BPASessionLog_Unicode_pre65] DROP CONSTRAINT [FK_BPASessionLog_Unicode_BPASession_pre65];

	-- ##############################################################
	-- Variables;
	DECLARE	@daystokeep INT = 7; -- Number of days to keep from midnight
	DECLARE @numberofrowsperbatch INT= 1000; -- The number of rows to be processed per batch iteration. Default is 1000.
											-- Optimal number will be entirely down to environment and the amount of data per row.
	-- ##############################################################
	
	-- Set the value to midnight based on the number of days to keep
	DECLARE @threshold DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, GETUTCDATE()), - @daystokeep);

	-- Create a temporary table to store the Sessions that are being kept
	CREATE TABLE #Sessions (
		sessionnumber INT NOT NULL
		);

	-- Get all the unstarted or unfinished sessions as well as those
	-- which have finished, but were started before the threshold date
	INSERT INTO #Sessions (sessionnumber)
	SELECT S.sessionnumber
	FROM BPASession S
	WHERE S.startdatetime IS NULL
		OR S.enddatetime IS NULL
		OR S.startdatetime >= @threshold;

	BEGIN TRAN RemoveOldData;

		-- Store the Session Logs that are to be kept, then truncate tables
		IF OBJECT_ID(N'BPASessionLog_Unicode', N'U') IS NOT NULL
		BEGIN

			SELECT SLU.*
				, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownumber
				, CAST(0 AS BIT) AS isprocessed
			INTO #BPASessionLog_Unicode
			FROM BPASessionLog_Unicode SLU
			INNER JOIN #Sessions S ON SLU.sessionnumber = S.sessionnumber;

			SELECT SLNU.*
				, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownumber
				, CAST(0 AS BIT) AS isprocessed
			INTO #BPASessionLog_NonUnicode
			FROM BPASessionLog_NonUnicode SLNU
			INNER JOIN #Sessions S ON SLNU.sessionnumber = S.sessionnumber;

			-- Empty the tables
			TRUNCATE TABLE BPASessionLog_Unicode;
			TRUNCATE TABLE BPASessionLog_NonUnicode;
		END
		ELSE BEGIN
			-- For previous versions
			SELECT SL.*
				, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownumber
				, CAST(0 AS BIT) AS isprocessed
			INTO #BPASessionLog
			FROM BPAsessionlog SL
			JOIN #Sessions S ON SL.sessionnumber = S.sessionnumber;

			TRUNCATE TABLE BPASessionLog;
		END

		-- Delete Sessions which are not to be kept
		DELETE S FROM BPASession S
		LEFT JOIN #Sessions ts ON S.sessionnumber = ts.sessionnumber
		WHERE TS.sessionnumber IS NULL;

		-- Create table to store processed rows 
		CREATE TABLE #ProcessedRows (
			sessionnumber INT NOT NULL
			, stageid UNIQUEIDENTIFIER
			, startdatetime DATETIME
			);

		IF OBJECT_ID(N'BPASessionLog_Unicode', N'U') IS NOT NULL
		BEGIN
			-- Begin batches
			WHILE EXISTS (
				SELECT 1
				FROM #BPASessionLog_Unicode SLU
				WHERE SLU.isprocessed = 0
				)
			BEGIN
				-- Empty the table for this iteration
				TRUNCATE TABLE #ProcessedRows
			
				INSERT INTO [BPASessionLog_Unicode] (
					[sessionnumber]
					, [stageid]
					, [stagename]
					, [stagetype]
					, [processname]
					, [pagename]
					, [objectname]
					, [actionname]
					, [result]
					, [resulttype]
					, [startdatetime]
					, [enddatetime]
					, [attributexml]
					, [automateworkingset]
					, [targetappname]
					, [targetappworkingset]
					, [starttimezoneoffset]
					, [endtimezoneoffset]
					)
				-- Store the results of this iteration
				OUTPUT inserted.sessionnumber
					, inserted.stageid
					, inserted.startdatetime
				INTO #ProcessedRows
				SELECT TOP (@numberofrowsperbatch) SLU.[sessionnumber]
					, SLU.[stageid]
					, SLU.[stagename]
					, SLU.[stagetype]
					, SLU.[processname]
					, SLU.[pagename]
					, SLU.[objectname]
					, SLU.[actionname]
					, SLU.[result]
					, SLU.[resulttype]
					, SLU.[startdatetime]
					, SLU.[enddatetime]
					, SLU.[attributexml]
					, SLU.[automateworkingset]
					, SLU.[targetappname]
					, SLU.[targetappworkingset]
					, SLU.[starttimezoneoffset]
					, SLU.[endtimezoneoffset]
				FROM #BPASessionLog_Unicode SLU
				WHERE SLU.isprocessed = 0;

				-- Mark the rows as processed
				UPDATE #BPASessionLog_Unicode
				SET isprocessed = 1
				FROM #BPASessionLog_Unicode SLU
				INNER JOIN #ProcessedRows PR ON SLU.sessionnumber = PR.sessionnumber
					AND SLU.stageid = PR.stageid
					AND SLU.startdatetime = PR.startdatetime
				WHERE SLU.isprocessed = 0;

				-- Exit if no rows are processed, safety catch
				IF NOT EXISTS (
					SELECT 1
					FROM #ProcessedRows PR
					)
				BREAK;
			END;
		END;

		IF OBJECT_ID(N'BPASessionLog_NonUnicode', N'U') IS NOT NULL
		BEGIN
	
			-- Begin batches
			WHILE EXISTS (
				SELECT 1
				FROM #BPASessionLog_NonUnicode SLNU
				WHERE SLNU.isprocessed = 0
				)
			BEGIN		
			
				-- Empty the table for this iteration
				TRUNCATE TABLE #ProcessedRows;
	
				INSERT INTO [BPASessionLog_NonUnicode] (
					[sessionnumber]
					, [stageid]
					, [stagename]
					, [stagetype]
					, [processname]
					, [pagename]
					, [objectname]
					, [actionname]
					, [result]
					, [resulttype]
					, [startdatetime]
					, [enddatetime]
					, [attributexml]
					, [automateworkingset]
					, [targetappname]
					, [targetappworkingset]
					, [starttimezoneoffset]
					, [endtimezoneoffset]
					)
				-- Store the results of this iteration
				OUTPUT inserted.sessionnumber
					, inserted.stageid
					, inserted.startdatetime
				INTO #ProcessedRows
				SELECT TOP (@numberofrowsperbatch)
				SLNU.[sessionnumber]
					, SLNU.[stageid]
					, SLNU.[stagename]
					, SLNU.[stagetype]
					, SLNU.[processname]
					, SLNU.[pagename]
					, SLNU.[objectname]
					, SLNU.[actionname]
					, SLNU.[result]
					, SLNU.[resulttype]
					, SLNU.[startdatetime]
					, SLNU.[enddatetime]
					, SLNU.[attributexml]
					, SLNU.[automateworkingset]
					, SLNU.[targetappname]
					, SLNU.[targetappworkingset]
					, SLNU.[starttimezoneoffset]
					, SLNU.[endtimezoneoffset]
				FROM #BPASessionLog_NonUnicode SLNU
				WHERE SLNU.isprocessed = 0;
				
				UPDATE #BPASessionLog_NonUnicode
				SET isprocessed = 1
				FROM #BPASessionLog_NonUnicode SLNU
				INNER JOIN #ProcessedRows PR ON SLNU.sessionnumber = PR.sessionnumber
					AND SLNU.stageid = PR.stageid
					AND SLNU.startdatetime = PR.startdatetime
				WHERE SLNU.isprocessed = 0;

				IF NOT EXISTS (
					SELECT 1
					FROM #ProcessedRows PR
					)
				-- Exit if no rows are processed, safety catch
				BREAK;

			END;		
		END; 

		IF OBJECT_ID(N'BPASessionLog', N'U') IS NOT NULL
		BEGIN
			-- Begin batches
			WHILE EXISTS (
				SELECT 1
				FROM #BPASessionLog SL
				WHERE SLNU.isprocessed = 0
				)
			BEGIN
				-- Clear the table
				TRUNCATE TABLE #ProcessedRows;

				INSERT INTO BPASessionLog
				-- Store the results of this iteration
				OUTPUT inserted.logid
				INTO #ProcessedRows
				SELECT SL.*
				FROM #BPASessionLog SL
				WHERE SL.isprocessed = 0

				-- Marked data as processed
				UPDATE #BPASessionLog
				SET isprocessed = 1
				FROM #BPASessionLog SL
				INNER JOIN #ProcessedRows PR ON SL.sessionnumber = PR.sessionnumber
					AND SL.stageid = PR.stageid
					AND SL.startdatetime = PR.startdatetime
				WHERE SL.isprocessed = 0;

				-- Exit if no rows are processed
				IF NOT EXISTS (
					SELECT 1
					FROM #ProcessedRows PR
					)
				BREAK;
			END;
		END;

	COMMIT TRAN RemoveOldData;

	-- Finished with the table, now drop
	IF OBJECT_ID('tempdb..#BPASessionLog') IS NOT NULL DROP TABLE #BPASessionLog
	IF OBJECT_ID('tempdb..#BPASessionLog_Unicode') IS NOT NULL DROP TABLE #BPASessionLog_Unicode
	IF OBJECT_ID('tempdb..#BPASessionLog_NonUnicode') IS NOT NULL DROP TABLE #BPASessionLog_NonUnicode
	IF OBJECT_ID('tempdb..#Sessions') IS NOT NULL DROP TABLE #Sessions
	IF OBJECT_ID('tempdb..#ProcessedRows') IS NOT NULL DROP TABLE #ProcessedRows