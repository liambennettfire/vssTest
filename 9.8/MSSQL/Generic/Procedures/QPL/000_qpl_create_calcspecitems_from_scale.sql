if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_calcspecitems_from_scale') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_calcspecitems_from_scale
GO

IF TYPE_ID(N'dbo.SpecItemsByPrinting') IS NULL
  CREATE TYPE dbo.SpecItemsByPrinting AS TABLE (
    taqversionformatyearkey INT,
    printingnumber INT,
    yearcode INT,
    taqprojectkey INT,
    plstagecode INT,
    taqversionkey INT,
    taqprojectformatkey INT,
    taqversionspecategorykey INT,
    relatedspeccategorykey INT,
    itemcategorycode	INT,
    itemcategory_qsicode INT,
    speccategorydescription VARCHAR(255),
    scaleprojecttype	INT,
    scaleprojectdesc	VARCHAR(40),
    vendorcontactkey	INT,
    vendordisplayname	VARCHAR(255),
    taqversionspecitemkey	INT,
    itemcode	INT,
    itemcode_qsicode INT,
    itemdesc		VARCHAR(120),
    usefunctionforqtyind	TINYINT,
    quan  INT,
    usefunctionfordescind TINYINT,
    [description] VARCHAR(2000),
    usefunctionforitemdetailind	TINYINT,
    itemdetailcode INT,
    itemdetaildesc VARCHAR(120),
    usefunctionfordecimalind		TINYINT,
    [decimal]  NUMERIC(15,4),
    usefunctionforuomind		TINYINT,
    unitofmeasurecode INT,
    uomdesc VARCHAR(120),
    validforprtscode		INT,
    validforprtsdesc		VARCHAR(40)		
	  );
GO

CREATE PROCEDURE qpl_create_calcspecitems_from_scale (  
  @i_taqversionformatyearkey INT, -- Target project format year
  @SpecItemsByPrintingView SpecItemsByPrinting READONLY,
  @i_scaleprojectkey INT,
  @i_scaleprojecttype INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/********************************************************************************************************************
**  Name: qpl_create_calcspecitems_from_scale
**  Desc: If there are any calculated parameters on the scale, make sure they exist on the PO or a related printing.
**        Create them if they don't exist.
**  Case: 47625
**
**  Auth: Colman
**  Date: November 14 2017
*********************************************************************************************************************
**    Change History
*********************************************************************************************************************
**  Date:       Author:     Case #:   Description:
**  --------    --------    -------   --------------------------------------------------
**  12/21/17    Colman      48649     Cost generation times Printing Version v. PO Summary
**  02/01/18    Colman      48235
********************************************************************************************************************/

--print 'qpl_create_calcspecitems_from_scale ' + convert(varchar(100), getdate())
-- exec qutl_trace 'qpl_create_calcspecitems_from_scale',
  -- '@i_taqversionformatyearkey', @i_taqversionformatyearkey, NULL,
  -- '@i_scaleprojectkey', @i_scaleprojectkey, NULL,
  -- '@i_scaleprojecttype', @i_scaleprojecttype

DECLARE
  @v_taqprojectkey INT,
  @v_relatedprojectkey INT,
  @v_taqprojectformatkey INT,
  @v_plstagecode INT,
  @v_taqversionkey INT,
  @v_taqversionspecategorykey INT,
  @v_new_taqversionspecitemkey INT,
  @v_error INT,
  @v_summarydatacode INT,
  @v_summarydatadesc VARCHAR(40),
  @v_specitemdatacode INT,
  @v_vendorkey INT
    
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  --exec qutl_trace 'qpl_create_calcspecitems_from_scale',
  --  '@i_taqversionformatyearkey', @i_taqversionformatyearkey, NULL,
  --  '@i_scaleprojectkey', @i_scaleprojectkey

  IF ISNULL(@i_taqversionformatyearkey, 0) <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Invalid taqversionformatyearkey.'
    GOTO ERROROUT
  END

  SELECT @v_summarydatacode = datacode, @v_summarydatadesc = datadesc FROM gentables WHERE tableid = 616 AND qsicode = 1

  DECLARE @scaleparams TABLE 
  (
    scaletypecode INT,
    itemcategorycode INT,
    itemcode INT
  )

  INSERT INTO @scaleparams (scaletypecode, itemcategorycode, itemcode)
    SELECT scaletypecode, itemcategorycode, itemcode 
    FROM dbo.qscale_get_scaleparameters_view(@i_scaleprojectkey)
    UNION
    SELECT scaletypecode, itemcategorycode, itemcode 
    FROM taqscaleadminspecitem WHERE scaletypecode = @i_scaleprojecttype
  

  -- Are there any calculated spec items on the scale params?  
  IF NOT EXISTS (
    SELECT 1
    FROM @scaleparams sp
      JOIN taqspecadmin tsa ON tsa.itemcategorycode = sp.itemcategorycode
        AND tsa.itemcode = sp.itemcode
        AND (
             tsa.usefunctionforqtyind = 1
          OR tsa.usefunctionfordecimalind = 1
          OR tsa.usefunctionfordescind = 1
          OR tsa.usefunctionforitemdetailind = 1
          OR tsa.usefunctionforuomind = 1
        )
    WHERE sp.itemcategorycode = @v_summarydatacode
  )
  BEGIN
    -- Nothing to do
    RETURN
  END

  SELECT @v_taqprojectformatkey = taqprojectformatkey
   FROM taqversionformatyear 
  WHERE taqversionformatyearkey = @i_taqversionformatyearkey

  SELECT TOP 1 @v_taqprojectkey = taqprojectkey
   FROM taqversionformat
  WHERE taqprojectformatkey = @v_taqprojectformatkey

  -- Is there a summary component on this project or a related project?
  SELECT TOP 1 @v_taqversionspecategorykey = taqversionspecategorykey
  FROM @SpecItemsByPrintingView
  WHERE itemcategorycode = @v_summarydatacode

  IF @v_taqversionspecategorykey IS NULL
  BEGIN
    -- It's possible the @SpecItemsByPrintingView doesn't contain a summary component because it exists without any spec items. Double check.
    -- First any related summary component on the PO
    SELECT @v_taqversionspecategorykey = relatedspeccategorykey
    FROM taqversionspeccategory
    WHERE taqprojectkey = @v_taqprojectkey 
      AND itemcategorycode = @v_summarydatacode

    -- Then any summary component on a related printing
    IF @v_taqversionspecategorykey IS NULL
      SELECT @v_taqversionspecategorykey = taqversionspecategorykey
      FROM taqversionspeccategory
      WHERE taqprojectkey = (
        SELECT TOP 1 prv.relatedprojectkey
        FROM projectrelationshipview prv
          LEFT OUTER JOIN taqversionformatrelatedproject vfrp ON vfrp.relatedprojectkey = prv.relatedprojectkey
        WHERE prv.taqprojectkey = @v_taqprojectkey 
          AND prv.relationshipcode = (SELECT datacode FROM gentables WHERE tableid=582 AND qsicode=25) -- Printing (for Purchase Orders)
        ORDER BY vfrp.editioncostpercent DESC
      )
      AND itemcategorycode = @v_summarydatacode
      
    -- If still nothing, create a summary component on the first related printing we can find
    IF @v_taqversionspecategorykey IS NULL
    BEGIN
      SELECT TOP 1 @v_relatedprojectkey = prv.relatedprojectkey, @v_taqprojectformatkey = f.taqprojectformatkey, @v_plstagecode = f.plstagecode, @v_taqversionkey = 1
      FROM projectrelationshipview prv
        JOIN taqversionformatrelatedproject vfrp ON vfrp.relatedprojectkey = prv.relatedprojectkey
        JOIN taqversionformat f ON f.taqprojectkey = prv.relatedprojectkey AND taqversionkey = 1
      WHERE prv.taqprojectkey = @v_taqprojectkey 
        AND prv.relationshipcode = (SELECT datacode FROM gentables WHERE tableid=582 AND qsicode=25) -- Printing (for Purchase Orders)
      ORDER BY vfrp.editioncostpercent DESC

      EXEC get_next_key @i_userid, @v_taqversionspecategorykey OUTPUT

      INSERT INTO taqversionspeccategory
        (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
         speccategorydescription, scaleprojecttype, vendorcontactkey, lastuserid, lastmaintdate)
      VALUES
        (@v_taqversionspecategorykey, @v_relatedprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey, @v_summarydatacode,
         @v_summarydatadesc, NULL, @v_vendorkey, @i_userid, getdate())
           
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not insert into taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO ERROROUT
      END
    END
  END

  -- Iterate over all calculated spec items on the Scale
  DECLARE specitem_cur CURSOR FOR
    SELECT sp.itemcode
    FROM @scaleparams sp
      JOIN taqspecadmin tsa ON tsa.itemcategorycode = sp.itemcategorycode
        AND tsa.itemcode = sp.itemcode
        AND (
             tsa.usefunctionforqtyind = 1
          OR tsa.usefunctionfordecimalind = 1
          OR tsa.usefunctionfordescind = 1
          OR tsa.usefunctionforitemdetailind = 1
          OR tsa.usefunctionforuomind = 1
        )
    WHERE sp.itemcategorycode = @v_summarydatacode

  OPEN specitem_cur
  FETCH specitem_cur INTO @v_specitemdatacode

  WHILE @@FETCH_STATUS = 0
  BEGIN
    --exec qutl_trace 'qpl_create_calcspecitems_from_scale',
    --  '@v_specitemdatacode', @v_specitemdatacode

    IF NOT EXISTS (SELECT 1
      FROM taqversionspecitems
      WHERE taqversionspecategorykey = @v_taqversionspecategorykey
        AND itemcode = @v_specitemdatacode
    )
    BEGIN
      EXEC get_next_key @i_userid,  @v_new_taqversionspecitemkey OUTPUT

      --exec qutl_trace 'qpl_create_calcspecitems_from_scale',
      --  'Create spec item', NULL, NULL,
      --  '@v_new_taqversionspecitemkey', @v_new_taqversionspecitemkey

      INSERT INTO taqversionspecitems
        (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, validforprtgscode, lastuserid, lastmaintdate)
      VALUES
        (@v_new_taqversionspecitemkey, @v_taqversionspecategorykey, @v_specitemdatacode, NULL, 3, @i_userid, getdate())

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not insert into taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO ERROROUT
      END
    END

    FETCH specitem_cur INTO @v_specitemdatacode
  END

  ERROROUT:

  IF CURSOR_STATUS('global','specitem_cur') > -1
  BEGIN
    CLOSE specitem_cur
    DEALLOCATE specitem_cur
  END
END
GO

GRANT EXEC ON qpl_create_calcspecitems_from_scale TO PUBLIC
GO
