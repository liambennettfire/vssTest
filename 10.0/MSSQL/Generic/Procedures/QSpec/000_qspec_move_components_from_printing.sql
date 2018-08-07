if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_move_components_from_printing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_move_components_from_printing
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qspec_move_components_from_printing
 (@i_fromprojectkey  integer,
  @i_speccategorykey integer,
  @i_toprojectkey     integer,
  @i_toformatkey     integer,
  @i_forcederivefromfgind tinyint,
  @i_forcespoilagepercent DECIMAL(9,2),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/****************************************************************************************
**  Name: qspec_move_components_from_printing
**  Desc: moves spec category (component) and child spec items from the printing projectkey to
**        a PO project and sets the printing project to have a reference record to the PO category
**        via relatedspeccategorykey
**
**  Auth: Dustin Miller
**  Date: 31 January 2016
**
****************************************************************************************
**  Change History
****************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------
**  05/23/17     Colman      Case 45158 - Changes for the Shared PO Sections and Components
**  06/21/17     Colman      Case 45174 - Finished good quantity issue
**  06/26/17     Colman      Case 45995 - Need to be able to move components from the existing PO
****************************************************************************************/

  DECLARE @v_new_taqversionspecategorykey INT,
          @v_taqversionspecitemkey INT,
          @v_new_taqversionspecitemkey INT,
          @v_plstagecode INT,
          @v_vendorrolecode INT,
          @v_vendorcontactkey INT,
          @error_var    INT,
          @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_plstagecode = datacode
  FROM gentables
  WHERE tableid = 562
    AND qsicode = 2

  SELECT @v_vendorrolecode = datacode
  FROM gentables
  WHERE tableid = 285
    AND qsicode = 15

  --get vendor for new category
  select top 1 @v_vendorcontactkey = pc.globalcontactkey
  from taqprojectcontact pc
  join globalcontactrole gcr
  on pc.globalcontactkey = gcr.globalcontactkey
  where pc.taqprojectkey = @i_toprojectkey
    and gcr.rolecode = @v_vendorrolecode
  order by pc.keyind desc, pc.sortorder asc
  
  EXEC get_next_key 'QSIDBA', @v_new_taqversionspecategorykey OUTPUT

  INSERT INTO taqversionspeccategory
    (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, 
      taqversionformatkey, itemcategorycode, speccategorydescription, scaleprojecttype, vendorcontactkey,
      lastuserid, lastmaintdate, 
      quantity,
      finishedgoodind, 
      relatedspeccategorykey, sortorder, 
      deriveqtyfromfgqty, 
      spoilagepercentage, 
      taqversionparentspecategorykey)
  SELECT @v_new_taqversionspecategorykey taqversionspecategorykey, @i_toprojectkey taqprojectkey, @v_plstagecode plstagecode, taqversionkey, 
    @i_toformatkey taqversionformatkey, itemcategorycode, speccategorydescription, scaleprojecttype, @v_vendorcontactkey vendorcontactkey,
    'QSIDBA' lastuserid, GETDATE() lastmaintdate, 
    CASE WHEN @i_forcederivefromfgind <> 1 AND finishedgoodind = 1 THEN quantity ELSE NULL END quantity, 
    CASE WHEN @i_forcederivefromfgind = 1 THEN 0 ELSE finishedgoodind END finishedgoodind, 
    NULL relatedspeccategorykey, sortorder, 
    CASE WHEN @i_forcederivefromfgind = 1 THEN 1 ELSE 0 END deriveqtyfromfgqty, 
    CASE WHEN @i_forcederivefromfgind = 1 THEN @i_forcespoilagepercent ELSE 0 END spoilagepercentage, 
    taqversionparentspecategorykey
  FROM taqversionspeccategory
  WHERE taqversionspecategorykey = @i_speccategorykey

  DECLARE curSpecItem CURSOR FOR
  SELECT taqversionspecitemkey
  FROM taqversionspecitems
  WHERE taqversionspecategorykey = @i_speccategorykey
      
  OPEN curSpecItem 

  FETCH NEXT FROM curSpecItem INTO @v_taqversionspecitemkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    EXEC get_next_key 'QSIDBA', @v_new_taqversionspecitemkey OUTPUT

    INSERT INTO taqversionspecitems
    SELECT @v_new_taqversionspecitemkey taqversionspecitemkey, @v_new_taqversionspecategorykey taqversionspecategorykey, itemcode, itemdetailcode, quantity, validforprtgscode, [description], decimalvalue,
      unitofmeasurecode, 'QSIDBA' lastuserid, GETDATE() lastmaintdate, description2, itemdetailsubcode, itemdetailsub2code
    FROM taqversionspecitems
    WHERE taqversionspecitemkey = @v_taqversionspecitemkey

    FETCH NEXT FROM curSpecItem INTO @v_taqversionspecitemkey
  END

  CLOSE curSpecItem
  DEALLOCATE curSpecItem

  -- Is this component on the PO?
  IF EXISTS (
    SELECT 1 
    FROM taqversionspeccategory poc
      JOIN taqversionspeccategory prc ON prc.relatedspeccategorykey = poc.taqversionspecategorykey
    WHERE poc.taqversionspecategorykey = @i_speccategorykey
      AND poc.taqprojectkey = @i_toprojectkey
  )
  BEGIN
    --update the printing component relationship to the new shared po section
    UPDATE taqversionspeccategory
    SET relatedspeccategorykey = @v_new_taqversionspecategorykey
    WHERE relatedspeccategorykey = @i_speccategorykey

    -- delete the po component to which the printing component was related
    DELETE FROM taqversionspeccategory
    WHERE taqversionspecategorykey = @i_speccategorykey
  END
  ELSE
  BEGIN
    -- Is there already a component on the PO related to this printing component?
    IF EXISTS (
      SELECT 1 
      FROM taqversionspeccategory prc
        JOIN taqversionspeccategory poc ON poc.relatedspeccategorykey = prc.taqversionspecategorykey
      WHERE prc.taqversionspecategorykey = @i_speccategorykey
        AND poc.taqprojectkey = @i_toprojectkey
    )
    BEGIN
      -- Delete existing related component from PO
      DELETE FROM taqversionspeccategory
      WHERE relatedspeccategorykey = @i_speccategorykey
        AND taqprojectkey = @i_toprojectkey
    END

    --Change old spec category to point to new one
    UPDATE taqversionspeccategory
    SET relatedspeccategorykey = @v_new_taqversionspecategorykey
    WHERE taqversionspecategorykey = @i_speccategorykey
  END

  --Remove spec items under old category
  DELETE taqversionspecitems
  WHERE taqversionspecategorykey = @i_speccategorykey

GO
GRANT EXEC ON qspec_move_components_from_printing TO PUBLIC
GO