select spid,
           status,
           login_time,
           loginame=rtrim(loginame),
           hostname,
           blk=convert(char(5),blocked),
           cpu,
           physical_io,
           blocked,
           spid,
           program_name,
           cmd,
           dbname=db_name(dbid)             
     FROM  master.dbo.sysprocesses    
        --- WHERE program_name ='Red Gate Software Ltd SQL Prompt 5.2.0.5'     
     where loginame <> 'sa' AND  loginame <> 'SILVER\TEAPPID' AND  loginame <> 'dpa' AND  loginame <> 'SILVER\TSQLEXEC'
      AND hostname <> 'CIWAPPXD0712' AND  loginame <> 'INTERNAL\RSALGE'