if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titles_by_countrygroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_titles_by_countrygroup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_titles_by_countrygroup
 (@i_countrygroup		integer,
	@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_titles_by_countrygroup
**  Desc: This stored procedure returns all title bookkeys that would be affected by
					the given country code.
**
**  Auth: Dustin Miller
**  Date: 7/30/12
*************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT DISTINCT tr.bookkey
	FROM territoryrights tr
	JOIN coretitleinfo ci
	ON (ci.bookkey = tr.bookkey)
	WHERE tr.singlecountrygroupcode = @i_countrygroup
		AND tr.bookkey IS NOT NULL
		AND (ci.sendtoeloind = 1 OR ci.csapprovalcode > 0)
	UNION			
  SELECT DISTINCT ctv.bookkey
    FROM contractstitlesview ctv, bookdetail bd, territoryrights tr, taqprojectrightsformat rf, taqprojectrightslanguage rl
   WHERE tr.singlecountrygroupcode = @i_countrygroup
     and tr.taqprojectkey = ctv.contractprojectkey 
     and ctv.bookkey = bd.bookkey
     and bd.territoryderivedfromcontractind = 1
     and tr.rightskey = rf.rightskey
     and rf.mediacode = bd.mediatypecode
     and rf.formatcode in (bd.mediatypesubcode,0)
     and tr.rightskey = rl.rightskey
     and rl.languagecode in (bd.languagecode,bd.languagecode2)
			
  
END
GO

GRANT EXEC ON qtitle_get_titles_by_countrygroup TO PUBLIC
GO
