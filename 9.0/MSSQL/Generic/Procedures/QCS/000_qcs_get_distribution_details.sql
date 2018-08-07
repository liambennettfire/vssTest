IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_distribution_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_distribution_details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dustin Miller
-- Create date: July 10, 2013
-- Description:	Gets the data for the details tab in the manual send
-- =============================================
CREATE PROCEDURE [qcs_get_distribution_details] 
	@i_jobkey int,
	@i_partnerkey int,
	@i_title varchar(255),
	@i_isbn	varchar(2000),
	@o_error_code integer output,
  @o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_error  INT

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT DISTINCT cp.customerkey, cp.jobkey, cp.partnercontactkey, gc.displayname as partnername, cp.bookkey, bk.title, i.ean, bd.mediatypecode, bd.mediatypesubcode,
	STUFF((SELECT DISTINCT ', ' + tpe.taqelementdesc
	 FROM taqprojectelement tpe
	 JOIN cloudsendpublish cp2
	 ON (tpe.taqelementkey = cp2.elementkey)
	 WHERE cp2.jobkey = cp.jobkey
	   AND cp2.partnercontactkey = cp.partnercontactkey
	   AND cp2.bookkey = cp.bookkey
	 FOR XML PATH('')), 1, 2, '') as assets
FROM cloudsendpublish cp
JOIN globalcontact gc
ON (cp.partnercontactkey = gc.globalcontactkey)
JOIN book bk
ON (cp.bookkey = bk.bookkey)
JOIN bookdetail bd
ON (cp.bookkey = bd.bookkey)
JOIN isbn i
ON (cp.bookkey = i.bookkey)
WHERE cp.jobkey = @i_jobkey
	AND (@i_partnerkey <= 0 OR cp.partnercontactkey = @i_partnerkey)
	AND (COALESCE(@i_title, '') = '' OR LOWER(bk.title) like '%' + @i_title + '%')
	AND (COALESCE(@i_isbn, '') = '' OR REPLACE(i.ean, '-', '') like '%' + @i_isbn + '%')
	AND COALESCE(cp.jobendind, 0) = 0
ORDER BY partnername, bk.title

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
	SET @o_error_code = 1
  SET @o_error_desc = 'Error retrieving distribution details information from cloudsendpublish w/ jobkey: ' + CAST(@i_jobkey as varchar)
END

END

GO

GRANT EXEC ON qcs_get_distribution_details TO PUBLIC
GO