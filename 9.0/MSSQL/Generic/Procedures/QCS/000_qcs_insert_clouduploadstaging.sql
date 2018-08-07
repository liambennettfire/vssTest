IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_insert_clouduploadstaging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].qcs_insert_clouduploadstaging
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jason
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE qcs_insert_clouduploadstaging 
	-- Add the parameters for the stored procedure here
	@uploadjobkey int,
	@sendjobkey int,
	@bookkey int,
	@assettypecode int,
	@taqelementkey int,
	@filepath varchar(4000),
	@csdisttemplatekey int,
	@numberofattempts int,
	@jobstartind tinyint,
	@jobendind tinyint,
	@lastuserid varchar(30),
	@lastmaintdate datetime
AS
BEGIN

INSERT INTO clouduploadstaging
           ([uploadjobkey]
           ,[sendjobkey]
           ,[bookkey]
           ,[assettypecode]
           ,[taqelementkey]
           ,[filepath]
           ,[csdisttemplatekey]
           ,[numberofattempts]
           ,[jobstartind]
           ,[jobendind]
           ,[lastuserid]
           ,[lastmaintdate])
     VALUES
           (@uploadjobkey,
            @sendjobkey,
			@bookkey,
			@assettypecode,
			@taqelementkey,
			@filepath,
			@csdisttemplatekey,
			@numberofattempts,
			@jobstartind,
			@jobendind,
			@lastuserid,
			@lastmaintdate  )

END
GO

GRANT EXEC ON qcs_insert_clouduploadstaging TO PUBLIC
GO