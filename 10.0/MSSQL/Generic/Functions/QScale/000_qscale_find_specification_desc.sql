if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_find_specification_desc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_find_specification_desc
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

CREATE FUNCTION qscale_find_specification_desc
    ( @i_taqversionformatyearkey as integer,
      @SpecItemsByPrintingView SpecItemsByPrinting READONLY,
      @i_itemcategorycode as integer,
      @i_itemcode as integer) 

RETURNS varchar(2000)

/******************************************************************************
**  File: qscale_find_specification_desc
**  Name: qscale_find_specification_desc
**  Desc: This returns the desc of a specification item. 
**
**
**    Auth: Alan Katzen
**    Date: 2 April 2012
********************************************************************************
**  Change History
********************************************************************************
**  Date:     Author:   Description:
*   --------  -------   -------------------------------------------
**  12/21/17  Colman    48649 - Cost generation times Printing Version v. PO Summary
*******************************************************************************/

BEGIN 
  DECLARE 
    @v_count          INT,
    @error_var        INT,
    @rowcount_var     INT,
    @v_scalevaluetype INT,
    @v_specdesc       varchar(2000)
   
  IF COALESCE(@i_taqversionformatyearkey,0) <= 0 BEGIN
    RETURN -1
  END

  -- make sure itemcategorycode/itemcode is on taqspecadmin
  SELECT @v_count = count(*)
    FROM taqspecadmin
   WHERE itemcategorycode = @i_itemcategorycode
     AND itemcode = @i_itemcode
  
  IF @v_count <= 0 BEGIN
    return -1
  END
  
  SELECT @v_scalevaluetype = scalevaluetype
    FROM taqspecadmin
   WHERE itemcategorycode = @i_itemcategorycode
     AND itemcode = @i_itemcode
     
  IF @v_scalevaluetype = 1 BEGIN
    -- numeric
    SELECT @v_specdesc = cast(COALESCE(s.quan,0) as varchar)
      FROM @SpecItemsByPrintingView s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
  ELSE IF @v_scalevaluetype = 2 BEGIN
    -- decimal
    SELECT @v_specdesc = cast(COALESCE(s.decimal,0) as varchar)
      FROM @SpecItemsByPrintingView s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
  ELSE IF @v_scalevaluetype = 5 BEGIN
    -- gentable
    SELECT @v_specdesc = CASE WHEN s.itemdetailcode > 0 THEN s.itemdetaildesc 
                         ELSE COALESCE(s.itemdesc,'') END
      FROM @SpecItemsByPrintingView s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
     
  return ''
END
GO

GRANT EXEC ON dbo.qscale_find_specification_desc TO public
GO
