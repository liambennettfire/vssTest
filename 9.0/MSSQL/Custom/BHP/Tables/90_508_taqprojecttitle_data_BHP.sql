-- Creating a backup table
IF OBJECT_ID('dbo.taqprojecttitle_backup', 'U') IS NOT NULL BEGIN
  DROP TABLE dbo.taqprojecttitle_backup
END  
  
SELECT *
INTO taqprojecttitle_backup 
FROM taqprojecttitle

DECLARE   
	@v_taqprojectformatkey INT,
	@v_taqprojectkey INT, 
	@v_bookkey INT,
	@v_count INT
  
  DECLARE crTaqprojectTitle CURSOR FOR
	select taqprojectformatkey, taqprojectkey, bookkey 
	from taqprojecttitle
	where bookkey in (
	  select bookkey from taqprojecttitle
	  where bookkey in (
		select bookkey from taqprojecttitle
		where taqprojectkey in (
		  select taqprojectkey
		  from taqprojecttitle
		  where taqprojectkey IN (Select taqprojectkey FROM taqproject WHERE searchitemcode = 14 and usageclasscode = 1) AND bookkey > 0
		  GROUP BY taqprojectkey
		  having COUNT (taqprojectkey) > 1
		  )
	  )
	  AND taqprojectkey IN (Select taqprojectkey FROM taqproject WHERE searchitemcode = 14 and usageclasscode = 1)
	  GROUP BY bookkey
	  having COUNT (bookkey) > 1
	)
	AND taqprojectkey IN (Select taqprojectkey FROM taqproject WHERE searchitemcode = 14 and usageclasscode = 1)
	order by bookkey, printingkey
	
  OPEN crTaqprojectTitle 

  FETCH NEXT FROM crTaqprojectTitle INTO @v_taqprojectformatkey, @v_taqprojectkey, @v_bookkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    SET @v_count = 0
    
    SELECT TOP(1) @v_count = COUNT(*) 
    FROM taqprojecttitle WHERE taqprojectkey = @v_taqprojectkey AND bookkey <> @v_bookkey AND bookkey > 0
    
    IF @v_count > 0 BEGIN
		DELETE FROM taqprojecttitle 
		WHERE taqprojectformatkey = @v_taqprojectformatkey
    END
	
    FETCH NEXT FROM crTaqprojectTitle INTO @v_taqprojectformatkey, @v_taqprojectkey, @v_bookkey
  END /* WHILE FECTHING */

  CLOSE crTaqprojectTitle 
  DEALLOCATE crTaqprojectTitle	
  
GO   