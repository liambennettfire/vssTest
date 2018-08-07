IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qcontract_generate_coedition_name') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qcontract_generate_coedition_name
GO

CREATE PROCEDURE dbo.qcontract_generate_coedition_name
 (@i_taqprojectkey           integer,
  @o_contractname             varchar(255)  output,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output)
AS

BEGIN

/******************************************************************************
**  Name: qcontract_generate_coedition_name
**  Desc: This procedure will generate the Co-edition Contract project title
**
**    Auth: Susan Burke
**    Date: June 15 2017

Auth: Tolga Tuncer
Date: May 14, 2018
Add language to the contract name


*******************************************************************************/

  DECLARE 
    @error_var             INT,
    @rowcount_var          INT,
    @v_count               INT,
    @v_bookkey             INT,
    @v_contractprojectkey  INT,
    @v_book_title          VARCHAR(255),
    @v_printingnum         INT,
    @v_customername        VARCHAR(255),
    @v_printingnum_str     VARCHAR(50), 
	@languagedesc varchar(2000)

  SET @v_count = 0
  SET @v_customername = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_contractname = NULL 
  SET @languagedesc = ''
  
  SET @v_bookkey = 0
  SET @v_contractprojectkey = COALESCE(@i_taqprojectkey,0) 
  SET @v_printingnum = 0

  -- Use the VERY first RIGHT TYPE

  Select TOP 1 @languagedesc = LTRIM(RTRIM(languagedesc))
  FROM taqprojectrights 
  where taqprojectkey = @v_contractprojectkey
  ORDER BY rightskey
  --and ISNULL(languagedesc, '') <> '' 

  -- Language desc is not required, if not populated get it from the language table for the first rightskey 
  IF ISNULL(@languagedesc, '') = ''
	BEGIN
		select @languagedesc = @languagedesc + g.datadesc + ', ' 
		from taqprojectrightslanguage rl  
		JOIN gentables g 
		on rl.languagecode = g.datacode 
		where rl.rightskey in (Select TOP 1 rightskey from taqprojectrights where taqprojectkey = @v_contractprojectkey ORDER BY rightskey)  --and ISNULL(rightslanguagetypecode, 0) <> 0 )
		and g.tableid = 318 

		SET @languagedesc = LTRIM(RTRIM(@languagedesc))

		-- strip out comma if multiple languages are chosen
		IF RIGHT(@languagedesc, 1) = ','
			SET @languagedesc = LEFT(@languagedesc, LEN(@languagedesc) - 1)


	END


  

  -- Multiple right types can be added to a contract. Especially if "ALL" print is selected. 
  --If the contract title is named with this language already, exit out so we don't call the rest of the scripts multiple times

 -- If exists (Select 1 from taqproject where taqprojectkey = @v_contractprojectkey and taqprojecttitle like '%' + @languagedesc + '%')
	--RETURN  



  SELECT @v_customername = displayname
    FROM globalcontact gc
	INNER JOIN taqprojectcontact tc ON tc.globalcontactkey = gc.globalcontactkey
	INNER JOIN taqprojectcontactrole tcr on tc.taqprojectcontactkey = tcr.taqprojectcontactkey
   WHERE EXISTS(SELECT 1 FROM gentables g
			 WHERE tcr.rolecode  = g.datacode AND tableid = 285 AND g.qsiCode = 28)
	AND tc.taqprojectkey = @v_contractprojectkey

  SELECT @v_count = COUNT(*) 
    FROM projectrelationshipview prv
	INNER JOIN gentables g on prv.relationshipcode  = g.datacode AND tableid = 582 AND g.qsiCode = 39
	WHERE prv.relatedprojectkey = @v_contractprojectkey
	PRINT @v_count

  IF @v_count > 1
   BEGIN
    SET @v_book_title  = 'Multiple Title'
	SET @v_printingnum_str = ' / ' + (SELECT FORMAT (getdate(), 'MMM yyyy') )
  END
  ELSE BEGIN
    SELECT @v_book_title = ISNULL(prv.projectname, ' ')
      FROM projectrelationshipview prv 
     WHERE EXISTS(SELECT 1 FROM gentables g
			WHERE prv.relationshipcode  = g.datacode AND tableid = 582 AND g.qsiCode = 39)
	 AND prv.relatedprojectkey = @v_contractprojectkey
	SELECT @v_printingnum = ISNULL(printingnum, ' ')
	   FROM taqprojectprinting_view tpv
	   INNER JOIN taqprojectrights tpr ON tpr.taqprojectkey = @v_contractprojectkey
      WHERE tpv.taqprojectkey = tpr.taqprojectprintingkey
	SET @v_printingnum_str = ' #' + cast(@v_printingnum as varchar)
  END  
  

  IF @v_book_title IS NULL AND @v_printingnum_str IS NULL AND @v_customername IS NULL BEGIN
      SET @o_contractname = 'No Customer or Title Chosen'
      RETURN
    END
    
  SET @o_contractname =   ISNULL(@v_book_title,'Title Not Defined') + ' / '+ ISNULL(@languagedesc, 'No Lang') + ' / ' +
  ISNULL (@v_customername,'Cust not Defined') + ISNULL(@v_printingnum_str,' ')

  IF LEN(@o_contractname) > 255 
	SET @o_contractname = LEFT(@o_contractname, 255)
 
  --PRINT @o_contractname

  RETURN
  
END

GO

GRANT EXECUTE ON dbo.qcontract_generate_coedition_name TO PUBLIC
