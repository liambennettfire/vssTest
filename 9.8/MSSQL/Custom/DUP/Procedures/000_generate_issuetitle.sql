if exists (select * from dbo.sysobjects where id = object_id(N'dbo.generate_issuetitle') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.generate_issuetitle 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.generate_issuetitle
	@i_related_journalkey	INT,
	@i_related_volumekey  INT,
	@o_issuetitle         VARCHAR(255) OUTPUT,	
	@o_issuenum           INT OUTPUT,
	@o_seq_issuenum       INT OUTPUT,
	@o_error_code         INT OUTPUT,
	@o_error_desc         VARCHAR(2000) OUTPUT
AS

/**************************************************************************************
**  Name: generate_issuetitle
**  Desc: Custom Duke stored procedure used to generate taqprojecttitle for Issues.
**        Acronym + ' ' + Volume# + ':' + Issue# + '(' + Seq Issue# + ')'
**        Example:  RHR 11:1(109)
**
**  Auth: Kate Wiewiora
**  Date: 30 September 2010
**************************************************************************************/

DECLARE
  @v_acronym  VARCHAR(40),
  @v_issuenum INT,
  @v_seqissuenum  INT,
  @v_volumenum  INT,
  @v_count INT

BEGIN
  
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @o_issuetitle = ''
  SET @v_count = 0

  -- Check if all 3 org levels are filled in Related Journal
  SELECT @v_count = COUNT(*)
  FROM taqprojectorgentry 
  WHERE orglevelkey = 3 AND taqprojectkey = @i_related_journalkey

  IF @v_count = 0
  BEGIN
    SET @o_error_code = -1 --Error 
    SET @o_error_desc = 'Could not generate Issue title - The related Journal''s third level Organizational Entries needs to be entered.'
    RETURN
  END

  -- Get the Acronym for the Journal
  SELECT @v_acronym = IsNull(orgentrydesc,'')
  FROM taqprojectorgentry tpo, orgentry o
  WHERE tpo.orgentrykey = o.orgentrykey AND
    tpo.orglevelkey = 3 AND
    tpo.taqprojectkey = @i_related_journalkey

  IF @v_acronym = ''
  BEGIN
    SET @o_error_code = -2 --warning 
    SET @o_error_desc = 'Could not generate Issue title - Acronym not found on the related Journal''s third level organization.'
    RETURN
  END

  -- Get the current Volume's Volume Number
  SELECT @v_volumenum = CONVERT(INT, IsNull(productnumber,0))
  FROM taqproductnumbers 
  WHERE taqprojectkey = @i_related_volumekey AND 
    productidcode IN (SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 9)

  -- Get the current max Issue Number for the current Volume
  SELECT @v_issuenum = MAX(CONVERT(INT, IsNull(tpn.productnumber,0)))
  FROM taqprojectrelationship r
    JOIN taqproject t1 ON r.taqprojectkey1 = t1.taqprojectkey
    JOIN taqproject t2 ON r.taqprojectkey2 = t2.taqprojectkey
    LEFT OUTER JOIN taqproductnumbers tpn	ON t2.taqprojectkey = tpn.taqprojectkey	AND tpn.productidcode = 9
  WHERE t1.taqprojectkey = @i_related_volumekey
    AND relationshipcode1 = 6
    AND relationshipcode2 = 13
    AND IsNumeric(tpn.productnumber) = 1
  GROUP BY t1.taqprojectkey

  IF @v_issuenum IS NULL
    SET @v_issuenum = 1
  ELSE
    SET @v_issuenum = @v_issuenum + 1

  -- Get the current max Sequential Issue Number for the this Journal
  SELECT @v_seqissuenum = MAX(CONVERT(INT, IsNull(tpn.productnumber,0)))
  FROM taqprojectrelationship r
    JOIN taqproject t1 ON r.taqprojectkey1 = t1.taqprojectkey
    JOIN taqproject t2 ON r.taqprojectkey2 = t2.taqprojectkey
    LEFT OUTER JOIN taqproductnumbers tpn	ON t2.taqprojectkey = tpn.taqprojectkey	AND tpn.productidcode = 10
  WHERE t1.taqprojectkey = @i_related_journalkey
    AND relationshipcode1 = 7
    AND relationshipcode2 = 13
    AND IsNumeric(tpn.productnumber) = 1
  GROUP BY t1.taqprojectkey	 

  -- Form the new Issue Title
  IF @v_seqissuenum IS NOT NULL
	BEGIN
		SET @v_seqissuenum = @v_seqissuenum + 1
		SET @o_issuetitle = @v_acronym + ' ' + CONVERT(VARCHAR, @v_volumenum) + ':' + 
		CONVERT(VARCHAR, @v_issuenum) + ' (' + CONVERT(VARCHAR, @v_seqissuenum) + ')'
	END
  ELSE
 	SET @o_issuetitle = @v_acronym + ' ' + CONVERT(VARCHAR, @v_volumenum) + ':' + 
	CONVERT(VARCHAR, @v_issuenum)

  -- Return new Issue Number and Sequential Issue Number
  SET @o_issuenum = @v_issuenum
  SET @o_seq_issuenum = @v_seqissuenum

END
