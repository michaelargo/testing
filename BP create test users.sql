USE [BluePrism]
GO

declare @i  integer;

set @i = 0;


while (@i <> 20000) 

begin

	begin tran t1;

	INSERT INTO [dbo].[BPAUser]
			   ([userid]
			   ,[username]
			   ,[validfromdate]
			   ,[validtodate]
			   ,[passwordexpirydate]
			   ,[useremail]
			   ,[isdeleted]
			   ,[UseEditSummaries]
			   ,[preferredStatisticsInterval]
			   ,[SaveToolStripPositions]
			   ,[PasswordDurationWeeks]
			   ,[AlertEventTypes]
			   ,[AlertNotificationTypes]
			   ,[LogViewerHiddenColumns]
			   ,[systemusername]
			   ,[loginattempts]
			   ,[lastsignedin])
		 VALUES
			   (NEWID()
			   ,
										   'tmp_upser_' + 
											trim(
												str(
												CAST(rand()*1000000  AS INT) 
												)
												)
			   ,null
			   ,null
			   ,null
			   ,null
			   ,1
			   ,null
			   ,null
			   ,null
			   ,null
			   ,0
			   ,0
			   ,null
			   ,null
			   ,0
			   ,null);

			   commit tran t1;

			   set @i = @i + 1;
	   
	end

	
GO


/*  -- Delete from table users
delete  [dbo].[BPAUser]
where username  like '%tmp%'
*/