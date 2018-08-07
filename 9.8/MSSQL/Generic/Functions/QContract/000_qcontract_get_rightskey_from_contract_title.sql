if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_rightskey_from_contract_title') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qcontract_get_rightskey_from_contract_title
GO

CREATE FUNCTION dbo.qcontract_get_rightskey_from_contract_title
(
  @i_bookkey as integer,
  @i_mediatypecode as integer, --pass 0 if you want the function to find it for you
  @i_mediatypesubcode as integer, --pass 0 if you want the function to find it for you
  @i_languagecode as integer --pass 0 if you want the function to find it for you
) 
RETURNS int

/*******************************************************************************************************
**  Name: qcontract_get_rightskey_from_contract_title
**  Desc: This function returns the rightskey from a Contract for a title.
**
**  Auth: Alan Katzen
**  Date: May 23, 2012
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_rightskey INT,
    @v_projectkey INT,
    @v_mediatypecode INT,
    @v_mediatypesubcode INT,
    @v_languagecode INT,
    @v_rightspermissioncode INT
  
  SET @v_rightskey = 0
  
  IF COALESCE(@i_bookkey,0) <= 0 BEGIN
    RETURN 0
  END
        
  SELECT @v_count = COUNT(*)
    FROM contractstitlesview
   WHERE bookkey = @i_bookkey 
     AND printingkey = 1
     AND templateind <> 1
  
  IF @v_count = 0 BEGIN
    RETURN 0   
  END

  -- Find the unique rightskey for the taqprojectkey on taqprojectrights that matches on both format and language using bookdetail mediatypecode and mediatypesubcode 
  -- to select from taqprojectrightsformat and bookdetail.languagecode to select from taqprojectlanguage
  SELECT DISTINCT @v_projectkey = contractprojectkey
    FROM contractstitlesview
   WHERE bookkey = @i_bookkey 
     AND printingkey = 1
     AND templateind <> 1
   ORDER BY contractprojectkey DESC
  
  IF (@i_mediatypecode > 0)
  BEGIN
		SET @v_mediatypecode = @i_mediatypecode
  END
  ELSE BEGIN
		SELECT @v_mediatypecode = mediatypecode
			FROM bookdetail
		 WHERE bookkey = @i_bookkey
  END
  IF (@i_mediatypesubcode > 0)
  BEGIN
		SET @v_mediatypesubcode = @i_mediatypesubcode
  END
  ELSE BEGIN
		SELECT @v_mediatypesubcode = mediatypesubcode
			FROM bookdetail
		 WHERE bookkey = @i_bookkey
  END
  IF (@i_languagecode > 0)
  BEGIN
		SET @v_languagecode = @i_languagecode
  END
  ELSE BEGIN
		SELECT @v_languagecode = languagecode
			FROM bookdetail
		 WHERE bookkey = @i_bookkey
  END
   
  IF @v_mediatypecode > 0 and @v_mediatypesubcode > 0 and @v_languagecode > 0 BEGIN
    SELECT @v_count = COUNT(distinct r.rightskey)
    FROM taqprojectrights r
		LEFT JOIN taqprojectrightsformat f
			ON (r.rightskey = f.rightskey)
		LEFT JOIN taqprojectrightslanguage l
			ON (r.rightskey = l.rightskey)
		WHERE r.taqprojectkey = @v_projectkey
			AND (r.rightslanguagetypecode = 1 --All languages
			OR (r.rightslanguagetypecode = 2 AND @v_languagecode not in (select languagecode from taqprojectrightslanguage l2 where l2.rightskey = r.rightskey)) --All except
			OR (r.rightslanguagetypecode <> 2 AND l.languagecode = @v_languagecode)) --Select Countries
			AND f.mediacode = @v_mediatypecode
			AND (f.formatcode = @v_mediatypesubcode OR f.formatcode = 0)
			AND r.rightspermissioncode not in (select datacode from gentables where tableid = 463 and gen1ind = 1)
      
    -- If no rights key found or more than one rights key found or 
    -- for taqprojectrights for this rightskey the Rightspermissioncode (463) has a genind1 = 1 (‘Excluded from Contract? is true)
    -- Return 0      
    IF @v_count = 0 OR @v_count > 1 BEGIN
      RETURN 0   
    END
    
		SELECT distinct @v_rightskey = r.rightskey
		FROM taqprojectrights r
		LEFT JOIN taqprojectrightsformat f
			ON (r.rightskey = f.rightskey)
		LEFT JOIN taqprojectrightslanguage l
			ON (r.rightskey = l.rightskey)
		WHERE r.taqprojectkey = @v_projectkey
			AND (r.rightslanguagetypecode = 1 --All languages
			OR (r.rightslanguagetypecode = 2 AND @v_languagecode not in (select languagecode from taqprojectrightslanguage l2 where l2.rightskey = r.rightskey)) --All except
			OR (r.rightslanguagetypecode <> 2 AND l.languagecode = @v_languagecode)) --Select Countries
			AND f.mediacode = @v_mediatypecode
			AND (f.formatcode = @v_mediatypesubcode OR f.formatcode = 0)
			AND r.rightspermissioncode not in (select datacode from gentables where tableid = 463 and gen1ind = 1)
  END
  
  RETURN @v_rightskey
  
END
GO

GRANT EXEC ON dbo.qcontract_get_rightskey_from_contract_title TO public
GO
