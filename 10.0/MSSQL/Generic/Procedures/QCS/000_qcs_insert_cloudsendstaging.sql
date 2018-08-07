IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_insert_cloudsendstaging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_insert_cloudsendstaging]
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
CREATE PROCEDURE [qcs_insert_cloudsendstaging] 
	@jobkey int,
    @bookkey int,
    @elementkey int,
    @csdisttemplatekey int,
    @partnercontactkey int,
    @processstatuscode int,
    @jobstartind tinyint,
    @jobendind tinyint,
    @lastuserid varchar(30),
    @lastmaintdate datetime
AS
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
			@jobkey,
			@bookkey,
			@elementkey,
			@csdisttemplatekey,
			@partnercontactkey,
			@processstatuscode,
			@jobstartind,
			@jobendind,
			@lastuserid,
			@lastmaintdate
    )



END

GO

GRANT EXEC ON qcs_insert_cloudsendstaging TO PUBLIC
GO