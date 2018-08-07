IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_insert_cloudsendstaging_by_assettype]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_insert_cloudsendstaging_by_assettype]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Dustin Miller
-- Create date: July 1, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_insert_cloudsendstaging_by_assettype] 
		@i_jobkey int,
    @i_bookkey int,
    @i_assettype int,
    @i_csdisttemplatekey int,
    @i_partnercontactkey int,
    @i_processstatuscode int,
    @i_jobstartind tinyint,
    @i_jobendind tinyint,
    @i_lastuserid varchar(30),
    @o_error_code integer output,
		@o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_elementkey int,
				@v_metadatacode int,
				@v_error int

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT TOP 1 @v_elementkey = e.taqelementkey
FROM taqprojectelement AS e
WHERE e.bookkey = @i_bookkey
	AND e.taqelementtypecode = @i_assettype
	
IF @v_elementkey IS NULL
BEGIN
	SELECT @v_metadatacode = datacode
	FROM gentables
	WHERE tableid = 287
		AND qsicode = 3
		
	IF @i_assettype = @v_metadatacode
	BEGIN
		SET @v_elementkey = 0
	END
END

IF @v_elementkey IS NOT NULL
BEGIN
	INSERT INTO cloudsendstaging
						 ([jobkey]
						 ,[bookkey]
						 ,[elementkey]
						 ,[csdisttemplatekey]
						 ,[partnercontactkey]
						 ,[processstatuscode]
						 ,[jobstartind]
						 ,[jobendind]
						 ,[lastuserid]
						 ,[lastmaintdate])
			 VALUES (
				@i_jobkey,
				@i_bookkey,
				@v_elementkey,
				@i_csdisttemplatekey,
				@i_partnercontactkey,
				@i_processstatuscode,
				@i_jobstartind,
				@i_jobendind,
				@i_lastuserid,
				GETDATE()
			)

	SELECT @v_error = @@ERROR
	IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'Error inserting to cloudsendstaging (qcs_insert_cloudsendstaging_by_assettype)'
	END
END

END

GO

GRANT EXEC ON qcs_insert_cloudsendstaging_by_assettype TO PUBLIC
GO