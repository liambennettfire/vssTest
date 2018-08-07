IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_accepted_send_assets]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_accepted_send_assets]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 12, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_get_accepted_send_assets] 
	@i_jobkey int,
	@i_partnerkey int,
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT DISTINCT g.datadesc as assetname
FROM gentables g
JOIN customerpartnerassets cpa
ON (cpa.assettypecode = g.datacode)
WHERE g.tableid = 287
	AND (@i_partnerkey = 0 OR cpa.partnercontactkey = @i_partnerkey)
	AND cpa.customerkey IN (SELECT DISTINCT customerkey FROM cloudsendpublish WHERE jobkey = @i_jobkey)
ORDER BY assetname

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving asset information for jobkey: ' + CAST(@i_jobkey as varchar)
END

END

GO

GRANT EXEC ON qcs_get_accepted_send_assets TO PUBLIC
GO