IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[qtitle_create_title_postprocess_custom]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qtitle_create_title_postprocess_custom]
GO

/**************************************************************************************************
**  Name: qtitle_create_title_postprocess_custom
**  Desc: Called after title creation by qtitle_create_title_postprocess to allow custom post processing
**        Custom version for Quarto to set the first Printing project type
**  Case: 48528
**
**  Auth: Colman
**  Date: 30 November 2017
***************************************************************************************************
**	Change History
***************************************************************************************************
**  Date	    Author  Description
**	--------	------	-----------
**************************************************************************************************/

CREATE PROCEDURE dbo.qtitle_create_title_postprocess_custom
  @i_bookkey      INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN

  DECLARE
    @v_usageclass INT,
    @v_coeditionclass INT,
    @v_diskandroyaltyclass INT,
    @v_printingprojectkey INT,
    @v_taqprojecttype INT,
    @v_is_coedition TINYINT,
    @v_is_diskandroyalty TINYINT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_is_coedition = 0
  SET @v_is_diskandroyalty = 0
  
  SELECT @v_diskandroyaltyclass = datasubcode
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 77 -- Disk & Royalty Title

  SELECT @v_coeditionclass = datasubcode
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 59 -- Co-edition

  IF EXISTS (SELECT 1 FROM book WHERE bookkey = @i_bookkey AND usageclasscode = @v_coeditionclass)
    SET @v_is_coedition = 1
  ELSE IF EXISTS (SELECT 1 FROM book WHERE bookkey = @i_bookkey AND usageclasscode = @v_diskandroyaltyclass)
    SET @v_is_diskandroyalty = 1

  IF @v_is_coedition = 1 OR @v_is_diskandroyalty = 1
  BEGIN
    SELECT @v_printingprojectkey = taqprojectkey 
    FROM taqprojecttitle t
      JOIN book b ON b.bookkey = t.bookkey
      JOIN gentables g ON g.tableid = 604 
        AND g.datacode = t.projectrolecode 
        AND g.qsicode = 3 -- Printing project role
    WHERE t.bookkey = @i_bookkey
      AND t.printingkey = 1

    -- The printing type will be set to Disk & Royalty unless the title (first printing) has the Nominated Printer? 
    -- spec item checked then the printing will have a type of Nominated Printer.
    IF ISNULL(@v_printingprojectkey, 0) > 0
    BEGIN
      IF EXISTS 
      (
        SELECT 1 
        FROM taqversionspeccategory c
          JOIN taqversionspecitems i ON i.taqversionspecategorykey = c.taqversionparentspecategorykey
          JOIN subgentables g ON g.tableid = 616 -- SPECS gentable
            AND i.itemdetailcode = 1 -- Nominated Printer is checked
            AND i.itemcode = g.datasubcode
            AND g.datacode = 1    -- Summary
            AND g.qsicode = 9     -- Nominated Printer? spec
        WHERE c.taqprojectkey = @v_printingprojectkey 
          AND c.itemcategorycode = 1 -- Summary
      )
      BEGIN
        SELECT @v_taqprojecttype = datacode FROM gentables WHERE tableid = 521 AND qsicode = 11 -- Nominated Printer
      END
      ELSE IF @v_is_coedition = 1
        SELECT @v_taqprojecttype = datacode FROM gentables WHERE tableid = 521 AND qsicode = 13 -- Co-edition
      ELSE
        SELECT @v_taqprojecttype = datacode FROM gentables WHERE tableid = 521 AND qsicode = 12 -- Disk & Royalty

      UPDATE taqproject SET taqprojecttype = @v_taqprojecttype
      WHERE taqprojectkey = @v_printingprojectkey
    END
  END
END
GO

GRANT EXECUTE ON qtitle_create_title_postprocess_custom TO PUBLIC
GO