IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.season_update_project_HMH') AND type = 'TR')
	DROP TRIGGER dbo.season_update_project_HMH
GO

CREATE TRIGGER season_update_project_HMH ON printing
FOR INSERT, UPDATE AS
IF UPDATE (seasonkey) OR 
	 UPDATE (estseasonkey)

DECLARE @v_bookkey INT,
        @v_printingkey INT,
        @v_seasonkey INT,
        @v_estseasonkey INT,
        @v_bestseasonkey INT,
        @v_userid VARCHAR(30),
        @v_projectkey INT,
        @v_usageclass_marketing INT,
        @v_usageclass_publicity INT,
        @o_errorcode INT,
        @o_errordesc VARCHAR(1000)
	
SELECT @v_bookkey = i.bookkey, @v_seasonkey = i.seasonkey,	@v_estseasonkey = i.estseasonkey, @v_userid = i.lastuserid
FROM inserted i

SELECT @v_usageclass_marketing = datasubcode FROM subgentables WHERE qsicode = 9
SELECT @v_usageclass_publicity = datasubcode FROM subgentables WHERE qsicode = 54

SET @v_bestseasonkey = @v_seasonkey
IF @v_bestseasonkey IS NULL OR @v_bestseasonkey = 0 
  SET @v_bestseasonkey = @v_estseasonkey

-- Update related Marketing/Publicity Campaigns if season or estimated season has a non-zero value
IF @v_bestseasonkey IS NOT NULL AND @v_bestseasonkey <> 0
BEGIN
  DECLARE campaign_cur CURSOR FOR
  SELECT pt.taqprojectkey FROM taqprojecttitle pt 
  INNER JOIN taqproject p ON p.taqprojectkey = pt.taqprojectkey AND p.searchitemcode = 3 AND p.usageclasscode IN (@v_usageclass_marketing, @v_usageclass_publicity)
  INNER JOIN gentables g ON tableid = 521 AND p.taqprojecttype = g.datacode AND g.datadesc <> 'Multi Book'
  WHERE pt.bookkey = @v_bookkey

  OPEN campaign_cur
  FETCH NEXT FROM campaign_cur INTO @v_projectkey 

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    UPDATE taqproject SET seasoncode = @v_bestseasonkey WHERE taqprojectkey = @v_projectkey
    
    FETCH NEXT FROM campaign_cur INTO @v_projectkey 
  END

  CLOSE campaign_cur 			
  DEALLOCATE campaign_cur
END

GO
