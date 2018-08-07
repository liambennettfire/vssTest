if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_title_territoryrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_title_territoryrights
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_title_territoryrights
 (@i_bookkey              integer,
  @i_contractkey          integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*********************************************************************************************
**  Name: qcontract_get_title_territoryrights
**  Desc: Get all rights derived from a given contract for a given title
**
**  Auth: Colman
**  Date: March 31, 2017
**********************************************************************************************
**  Change History
**********************************************************************************************
**  Date:        Author:       Description:
**  ----------   -----------   ---------------------------------------------------------------
**
**********************************************************************************************/
DECLARE @error_var    INT,
        @v_contractprojectkey INT,
        @v_mediatypecode SMALLINT,
        @v_mediatypesubcode SMALLINT,
        @v_languagecode INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode, @v_languagecode = ISNULL(languagecode, 0)
  FROM bookdetail WHERE bookkey = @i_bookkey

  SELECT r.rightskey, r.rightsdescription, r.rightstypecode, r.formatdesc, 
    f.mediacode, f.formatcode, l.languagecode, l.excludeind, 
    t.territoryrightskey, t.currentterritorycode, t.contractterritorycode, t.description, 
    t.exclusivecode, t.singlecountrycode, t.singlecountrygroupcode, t.overridepropagationind, t.updatewithsubrightsind
  FROM taqprojectrights r
  LEFT JOIN taqprojectrightsformat f
    ON (r.rightskey = f.rightskey)
  LEFT JOIN taqprojectrightslanguage l
    ON (r.rightskey = l.rightskey)
  LEFT JOIN territoryrights t
    ON (r.rightskey = t.rightskey)
  WHERE r.taqprojectkey = @i_contractkey
    AND (r.rightslanguagetypecode = 1 --All languages
    OR (@v_languagecode = 0) -- if title has no language set, match anything
    OR (r.rightslanguagetypecode = 2 AND @v_languagecode not in (select languagecode from taqprojectrightslanguage l2 where l2.rightskey = r.rightskey)) --All except
    OR (r.rightslanguagetypecode <> 2 AND l.languagecode = @v_languagecode)) --Select Countries
    AND f.mediacode = @v_mediatypecode
    AND (f.formatcode = @v_mediatypesubcode OR f.formatcode = 0)
    AND r.rightspermissioncode not in (select datacode from gentables where tableid = 463 and gen1ind = 1)

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ', contractkey = ' + cast(@i_contractkey AS VARCHAR)
  END 
  
GO

GRANT EXEC ON qcontract_get_title_territoryrights TO PUBLIC
GO