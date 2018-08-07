IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_distribution_partners]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_distribution_partners]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 3, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_get_distribution_partners] 
	@i_jobkey int,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT DISTINCT cp.partnercontactkey, gc.displayname as partnername,
	(SELECT COUNT(DISTINCT bookkey) FROM cloudsendpublish WHERE jobkey = @i_jobkey AND partnercontactkey = cp.partnercontactkey) as titlecount,
	(SELECT COUNT(elementkey) FROM cloudsendpublish WHERE jobkey = @i_jobkey AND partnercontactkey = cp.partnercontactkey) as distributioncount
FROM cloudsendpublish cp
JOIN globalcontact gc
ON (cp.partnercontactkey = gc.globalcontactkey)
WHERE jobkey = @i_jobkey
	AND COALESCE(jobendind, 0) = 0
ORDER BY partnername, partnercontactkey

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving distribution partner information from cloudsendpublish w/ jobkey: ' + CAST(@i_jobkey as varchar)
END

END

GO

GRANT EXEC ON qcs_get_distribution_partners TO PUBLIC
GO