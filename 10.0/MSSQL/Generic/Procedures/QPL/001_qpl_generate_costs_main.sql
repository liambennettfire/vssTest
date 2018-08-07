if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_generate_costs_main') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_generate_costs_main
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

CREATE PROCEDURE qpl_generate_costs_main (  
  @i_taqversionformatyearkey   INT,
  @i_date    DATETIME,
  @i_processtype  INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_generate_cost_main
**  Desc: This stored procedure will be called for each unique format/year for the selected 
**        version that has a printing associated with it to generate costs.
**
**  Auth: Kusum Basra
**  Date: March 14 2012
*******************************************************************************************
*******************************************************************************************
**  Change History
*******************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/25/2016    Kusum       Case 38290
**  06/21/16     Kate        Fixes for related specs - see case 29764.
**  07/28/2016   Alan        Case 39356
**  04/06/2017   Colman      Case 44013
**  09/20/2017   Colman      Case 44013
**  10/13/2017   Colman      Case 47248 - Error on currency mismatch
**  10/24/2017   Colman      Case 47247 - Reopen 004
**  11/14/2017   Colman      Case 47625
**  12/21/2017   Colman      Case 48649 - Cost generation times Printing Version v. PO Summary
**  01/31/2018   Colman      Case 48235
**  05/08/2018   Colman      Case 51229 - Costs display -1 instead of no row for 0 costs 
*******************************************************************************************/

DECLARE
  @v_scaleprojectkey  INT,
  @v_taqprojectkey INT,  
  @v_plstagecode  INT,
  @v_taqversionkey  INT,
  @v_projectitemtype INT,
  @v_new_taqversionspecategorykey  INT,
  @v_new_taqversionspecitemkey  INT,
  @v_error  INT,
  @v_summarydatacode     INT,
  @v_prodqtydatacode     INT,
  @v_taqversiontype  INT,
  @v_taqprojectformatkey  INT,
  @v_taqversionspecategorykey  INT, 
  @v_relatedspeccategorykey INT,
  @v_itemcategorycode  INT,
  @v_specitemkey  INT, 
  @v_validforprtgs  INT,  
  @v_itemcode  INT, 
  @v_itemdetailcode  INT,
  @v_scaleprojecttype  INT,
  @v_speccategorydescription  VARCHAR(255),
  @v_specs_formatyearkey INT,
  @v_taqprojecttitle  VARCHAR(255),
  @v_message  VARCHAR(max),
  @v_taqdetailscalekey  INT, 
  @v_calculationtypecode  INT,
  @v_calcind TINYINT,
  @v_calcsecqsicode FLOAT,
  @v_perqty  FLOAT,
  @v_specialprocess VARCHAR(255),
  @v_taqversionspecitemkey  INT,
  @v_parametertypecode  INT,
  @v_messagetypecode  INT,
  @v_scaletabkey  INT,
  @v_scaletype  INT,
  @v_autoapplyind  TINYINT,
  @error_var    INT,
  @rowcount_var INT,
  @v_printing INT,
  @v_bucket_format      INT,
  @v_bucket_internal    INT,
  @v_bucket_cost        FLOAT,
  @v_bucket_validprtgs  INT,
  @v_bucket_calccost    INT,
  @v_acceptgenind INT,
  @v_quantity INT,
  @v_unitcost  FLOAT,
  @v_prodqtyitemcategorycode INT,
  @v_prodqtyitemcode INT,
  @v_sortorder INT,
  @v_costcompkey INT,
  @v_compunitcost FLOAT,
  @v_compqty INT,
  @v_compkey INT,
  @v_speccategorykey INT,
  @v_projectcurrency INT,
  @v_scalecurrency INT,
  @v_pocostind INT

DECLARE @SpecItemsByPrintingView AS SpecItemsByPrinting;
DECLARE @vSpecItemsByPrintingView AS SpecItemsByPrinting;

BEGIN
  IF ISNULL(@i_taqversionformatyearkey,0) = 0 BEGIN
    RETURN
  END

  INSERT INTO @SpecItemsByPrintingView
    (taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
    taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
    scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
    taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
    usefunctionforqtyind, quan,
    usefunctionfordescind, [description],
    usefunctionforitemdetailind, itemdetailcode, itemdetaildesc,
    usefunctionfordecimalind, [decimal],
    usefunctionforuomind, unitofmeasurecode, uomdesc,
    validforprtscode, validforprtsdesc)
  SELECT 
    taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
    taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
    scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
    taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
    usefunctionforqtyind, quan,
    usefunctionfordescind, [description],
    usefunctionforitemdetailind, itemdetailcode, itemdetaildesc,
    usefunctionfordecimalind, [decimal],
    usefunctionforuomind, unitofmeasurecode, uomdesc,
    validforprtscode, validforprtsdesc
  FROM qproject_get_specitems_by_printingview(@i_taqversionformatyearkey)

  --PRINT '@i_taqversionformatyearkey=' + convert(varchar, @i_taqversionformatyearkey)
  --PRINT '@i_processtype=' + convert(varchar, @i_processtype)

  SELECT @v_taqprojectkey = y.taqprojectkey, @v_plstagecode = y.plstagecode, @v_taqversionkey = y.taqversionkey,
       @v_taqprojectformatkey = y.taqprojectformatkey, @v_projectcurrency = ISNULL(plenteredcurrency,0), @v_projectitemtype = g.qsicode
      FROM taqversionformatyear y
        JOIN taqproject p ON p.taqprojectkey = y.taqprojectkey
        JOIN gentables g ON g.tableid=550 AND g.datacode = p.searchitemcode
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to select from taqversionformatyear.'
    RETURN
  END 
  
  --PRINT '@v_taqprojectkey=' + convert(varchar, @v_taqprojectkey)
  --PRINT '@v_plstagecode=' + convert(varchar, @v_plstagecode)
  --PRINT '@v_taqversionkey=' + convert(varchar, @v_taqversionkey)
  --PRINT '@v_taqprojectformatkey=' + convert(varchar, @v_taqprojectformatkey)  

  DELETE FROM taqversioncostmessages 
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey
       AND (processtype = @i_processtype OR processtype IS NULL)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to delete from taqversioncostmessages.'
    RETURN
  END 

  IF @i_processtype = 1 BEGIN
    DELETE FROM taqversioncosts 
      WHERE taqversionformatyearkey = @i_taqversionformatyearkey
        AND acceptgenerationind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to delete from taqversioncosts.'
      RETURN
    END 
  END

  -- table to save all unique scaleprojectkeys
  CREATE TABLE #tmp_scaleprojectkeys
  (scaleprojectkey  INT    NOT NULL)

  -- table to mimic the spec item/ scale detail structure - will have rows inserted by the GET SPEC DETAIL procedure
  CREATE TABLE #tmp_structure 
  (taqdetailscalekey    INT  NOT NULL,
   taqversionspecitemkey  INT   NULL,
   autoapplyind      TINYINT  NULL,
   calculationtypecode  INT    NULL,
   itemcategorycode    INT    NULL,
   itemcode        INT    NULL)

  CREATE TABLE #scalecostbucket_table (formatkey INT,internalcode INT,cost FLOAT,validforprtgs INT,calccostcode TINYINT, taqversionspecitemkey INT, buckettype CHAR, sortorder INT)
   
  SELECT @v_taqversiontype = taqversiontype
  FROM taqversion 
  WHERE taqprojectkey = @v_taqprojectkey AND plstagecode = @v_plstagecode AND taqversionkey = @v_taqversionkey

  --PRINT '@v_taqversiontype=' + convert(varchar, @v_taqversiontype)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqversion table.'
    RETURN
  END 

  DECLARE versionspeccategory_cur CURSOR FOR
    SELECT DISTINCT taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, scaleprojecttype, speccategorydescription
    FROM @SpecItemsByPrintingView

  OPEN versionspeccategory_cur 

  FETCH versionspeccategory_cur 
  INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_scaleprojecttype, @v_speccategorydescription

  WHILE (@@FETCH_STATUS=0) 
  BEGIN
    
    --PRINT ' ---'
    --PRINT ' @v_taqversionspecategorykey=' + convert(varchar, @v_taqversionspecategorykey)
    --PRINT ' @v_relatedspeccategorykey=' + convert(varchar, @v_relatedspeccategorykey)
    --PRINT ' @v_itemcategorycode=' + convert(varchar, @v_itemcategorycode)
    --PRINT ' @v_scaleprojecttype=' + convert(Varchar, @v_scaleprojecttype)
    --PRINT ' @v_speccategorydescription=' + @v_speccategorydescription
    
    IF @v_projectitemtype = 15 BEGIN -- Purchase Order
      SET @v_specs_formatyearkey = @i_taqversionformatyearkey
    END
    -- Get the taqversionformatyearkey for the first encountered printing on the project holding the actual spec
    -- NOTE: @v_relatedspeccategorykey equals @v_taqversionspecategorykey if there is no related spec.
    ELSE IF @v_relatedspeccategorykey IS NULL OR @v_relatedspeccategorykey = @v_taqversionspecategorykey BEGIN
      SET @v_specs_formatyearkey = @i_taqversionformatyearkey
    END
    ELSE BEGIN
      SELECT @v_specs_formatyearkey = firstprtg_taqversionformatyearkey
      FROM taqversionrelatedcomponents_view
      WHERE taqversionspecategorykey = @v_relatedspeccategorykey     

      INSERT INTO @vSpecItemsByPrintingView
        (taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
        scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
        taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
        usefunctionforqtyind, quan,
        usefunctionfordescind, [description],
        usefunctionforitemdetailind, itemdetailcode, itemdetaildesc,
        usefunctionfordecimalind, [decimal],
        usefunctionforuomind, unitofmeasurecode, uomdesc,
        validforprtscode, validforprtsdesc)
      SELECT 
        taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
        scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
        taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
        usefunctionforqtyind, quan,
        usefunctionfordescind, [description],
        usefunctionforitemdetailind, itemdetailcode, itemdetaildesc,
        usefunctionfordecimalind, [decimal],
        usefunctionforuomind, unitofmeasurecode, uomdesc,
        validforprtscode, validforprtsdesc
      FROM qproject_get_specitems_by_printingview(@v_specs_formatyearkey)

    END 
    
    IF @v_scaleprojecttype IS NULL 
    BEGIN

      -- Check whether we need cost generation at all
      IF EXISTS (
          SELECT 1 
          FROM taqscaleadminspecitem 
          WHERE itemcategorycode = @v_itemcategorycode
            AND ISNULL(messagetypecode, 0) = 0
        ) 
        AND NOT EXISTS (
          SELECT 1 
          FROM taqscaleadminspecitem 
          WHERE itemcategorycode = @v_itemcategorycode
            AND messagetypecode IN (2, 3, 4)  --2 Errors, 3-Warnings 4-Information
        )
      BEGIN  --No spec. items are scales items - no cost generation necessary
        GOTO READ_AGAIN  
      END
      
      SELECT TOP 1 @v_messagetypecode = messagetypecode 
      FROM taqscaleadminspecitem 
      WHERE itemcategorycode = @v_itemcategorycode
        AND messagetypecode IN (2, 3, 4)  --2 Errors, 3-Warnings 4-Information
      ORDER BY messagetypecode

      IF @@ROWCOUNT > 0
      BEGIN
        SET @v_message = 'No scale type exist for ' + @v_speccategorydescription + '; cannot generate costs for this component/process.'

        --print @v_message
        --print ''
        INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
          VALUES (@i_taqversionformatyearkey, @v_message, @v_messagetypecode, NULL, NULL, getdate(), 'QSIADMIN', @i_processtype)
            
        GOTO READ_AGAIN        
      END
    END  --@v_scaleprojecttype = NULL

    -- Get Scale for Spec Category
    -- Returns @v_scaleprojectkey
    EXEC qscale_get_scale_for_speccategory @v_taqversionspecategorykey, @i_processtype, 
      @v_scaleprojectkey output, @o_error_code output, @o_error_desc output

    IF @v_scaleprojectkey = 0 OR @v_scaleprojectkey IS NULL BEGIN
      GOTO READ_AGAIN  
    END
    ELSE 
    BEGIN
      SELECT @v_taqprojecttitle = taqprojecttitle, @v_scalecurrency = plenteredcurrency FROM taqproject WHERE taqprojectkey = @v_scaleprojectkey

      -- If there are any calculated parameters on the scale, make sure they exist on the target project or a related printing.
      -- Create them if they don't exist.
      EXEC qpl_create_calcspecitems_from_scale @i_taqversionformatyearkey, @SpecItemsByPrintingView, @v_scaleprojectkey, @v_scaleprojecttype, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
      IF @o_error_code = -1 BEGIN
        SET @v_message = @o_error_desc

        --print @v_message
        --print ''
        INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
          VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL, getdate(), 'QSIADMIN', @i_processtype)

        RETURN
      END 

      SET @v_message = 'Scale chosen for ' + @v_speccategorydescription + '  is: ' + @v_taqprojecttitle
      
      --print @v_message
      --print ''
      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
        VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)

      IF @v_projectcurrency <> @v_scalecurrency
      BEGIN
        SET @v_message = 'Scale currency does not match project currency.'
        --print @v_message
        --print ''
        INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
          VALUES (@i_taqversionformatyearkey, @v_message, 2, NULL, NULL, getdate(), 'QSIADMIN', @i_processtype)
      END
      
      IF NOT EXISTS (SELECT 1 FROM #tmp_scaleprojectkeys WHERE scaleprojectkey=@v_scaleprojectkey)
        INSERT INTO  #tmp_scaleprojectkeys (scaleprojectkey) VALUES(@v_scaleprojectkey)

      -- Get all spec items for this version/format/printing/year/spec/category
      DECLARE specitems_by_printing_cur CURSOR FOR
        SELECT itemcategorycode, itemcode,itemdetailcode, taqversionspecitemkey
        FROM @SpecItemsByPrintingView
        WHERE taqversionspecategorykey = @v_taqversionspecategorykey

      OPEN specitems_by_printing_cur

      FETCH specitems_by_printing_cur INTO @v_itemcategorycode,@v_itemcode,@v_itemdetailcode,@v_taqversionspecitemkey

      WHILE (@@FETCH_STATUS=0) 
      BEGIN
        SELECT @v_messagetypecode = messagetypecode, @v_scaletabkey = scaletabkey, @v_parametertypecode = parametertypecode
        FROM taqscaleadminspecitem
        WHERE scaletypecode = @v_scaleprojecttype 
          AND itemcategorycode = @v_itemcategorycode 
          AND itemcode = @v_itemcode
                  
        -- Parameter type 1 (Scale), 2 (Grid) 
        -- Messagetypecode = 0 (Not a scale item)
        IF @@ROWCOUNT > 0 AND (@v_parametertypecode NOT IN (1,2)) AND (@v_messagetypecode <> 0) 
        BEGIN 
          -- GET SCALE DETAIL FOR SPEC ITEMS - will write to the #tmp_structure table
          -- pass @v_scaleprojecttype,@v_taqprojecttitle,@v_scaletabkey,@v_taqversionspecitemkey,@v_messagetypecode,@v_itemcategorycode,
          -- @v_itemcode,@v_itemdetailcode,0(autoapplyind)
          IF @v_specs_formatyearkey = @i_taqversionformatyearkey
            EXEC qscale_get_scale_detail @v_specs_formatyearkey, @SpecItemsByPrintingView, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
                @v_taqversionspecitemkey, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, @v_itemdetailcode, 0, @i_processtype,
                @o_error_code OUTPUT, @o_error_desc OUTPUT
          ELSE
            EXEC qscale_get_scale_detail @v_specs_formatyearkey, @vSpecItemsByPrintingView, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
                @v_taqversionspecitemkey, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, @v_itemdetailcode, 0, @i_processtype,
                @o_error_code OUTPUT, @o_error_desc OUTPUT
                  
          IF @o_error_code = -1 
          BEGIN
            SET @v_message = @o_error_desc

            --print @v_message
            --print ''
            INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
              VALUES (@i_taqversionformatyearkey, @v_message, 4, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
          END
        END
              
        FETCH specitems_by_printing_cur INTO @v_itemcategorycode,@v_itemcode,@v_itemdetailcode,@v_taqversionspecitemkey
      END --specitems_by_printing_cur

      CLOSE specitems_by_printing_cur
      DEALLOCATE specitems_by_printing_cur

      GOTO READ_AGAIN
    END
        
    READ_AGAIN:
    FETCH versionspeccategory_cur 
    INTO @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_scaleprojecttype, @v_speccategorydescription
  END

  CLOSE versionspeccategory_cur
  DEALLOCATE versionspeccategory_cur 

  IF @i_processtype = 1 BEGIN
    IF NOT EXISTS (SELECT 1 FROM #tmp_scaleprojectkeys) BEGIN
      SET @o_error_code = 0
      SET @o_error_desc = ''
      RETURN
    END
  END

  IF @i_processtype = 1 
  BEGIN  --Cost Generation
    -- Get all auto apply items for scales used by spec categories for this version/format/year that have not already
    -- been added and add them to the spec item/scale detail structure. They will not have a corresponding spec
    -- item, but will have an autoapply ind set to yes and a taqscaledetailkey
      DECLARE scaleprojectkey_cursor CURSOR FOR
        SELECT DISTINCT scaleprojectkey
          FROM #tmp_scaleprojectkeys
        ORDER BY scaleprojectkey

      OPEN scaleprojectkey_cursor 

      FETCH scaleprojectkey_cursor INTO @v_scaleprojectkey

      WHILE (@@FETCH_STATUS=0)
      BEGIN
        SELECT @v_taqprojecttitle = taqprojecttitle, @v_scaletype = taqprojecttype FROM taqproject WHERE taqprojectkey = @v_scaleprojectkey
        
        DECLARE taqprojectscaledetails_cur CURSOR FOR
          SELECT DISTINCT itemcategorycode,itemcode
            FROM taqprojectscaledetails 
           WHERE taqprojectkey = @v_scaleprojectkey AND autoapplyind = 1
           ORDER BY itemcategorycode,itemcode

        OPEN taqprojectscaledetails_cur 

        FETCH taqprojectscaledetails_cur INTO @v_itemcategorycode,@v_itemcode

        WHILE (@@FETCH_STATUS=0)
        BEGIN
        
          IF NOT EXISTS (SELECT 1 FROM #tmp_structure WHERE itemcategorycode = @v_itemcategorycode AND itemcode = @v_itemcode)
          BEGIN 
            IF NOT EXISTS (SELECT 1 FROM taqscaleadminspecitem WHERE scaletypecode = @v_scaletype AND itemcategorycode = @v_itemcategorycode AND itemcode = @v_itemcode)
            BEGIN
              SET @v_message = 'Taqscaleadminspecitem record does not exist for ' + CAST(@v_itemcategorycode AS VARCHAR) +
                               '/' + CAST(@v_itemcode AS VARCHAR) + '; Cannot process autoapply item.'

              --print @v_message
              --print ''

              INSERT INTO taqversioncostmessages 
                (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
                VALUES
                (@i_taqversionformatyearkey, @v_message, 2, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
              
            END
            ELSE 
            BEGIN
              SELECT @v_messagetypecode =  messagetypecode, @v_scaletabkey = scaletabkey
                FROM taqscaleadminspecitem
               WHERE scaletypecode = @v_scaletype
                 AND itemcategorycode = @v_itemcategorycode
                 AND itemcode = @v_itemcode

              -- GET SCALE DETAIL FOR SPEC ITEMS - will write to the #tmp_structure table
              -- pass @i_taqversionformatyearkey,@v_scaleprojecttype,@v_taqprojecttitle,@v_scaletabkey,@v_taqversionspecitemkey(NULL),@v_messagetypecode,@v_itemcategorycode,
              -- @v_itemcode,@v_itemdetailcode(NULL),1(autoapplyind)
              IF @v_specs_formatyearkey = @i_taqversionformatyearkey
                EXEC qscale_get_scale_detail @v_specs_formatyearkey, @SpecItemsByPrintingView, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
                  NULL, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, NULL, 1, @i_processtype, @o_error_code OUTPUT, @o_error_desc OUTPUT
              ELSE
                EXEC qscale_get_scale_detail @v_specs_formatyearkey, @vSpecItemsByPrintingView, @v_scaleprojectkey, @v_taqprojecttitle, @v_scaletabkey,
                  NULL, @v_messagetypecode, @v_itemcategorycode, @v_itemcode, NULL, 1, @i_processtype, @o_error_code OUTPUT, @o_error_desc OUTPUT

              IF @o_error_code = -1 BEGIN
                SET @v_message = @o_error_desc

                --print @v_message
                --print ''
                INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
                  VALUES (@i_taqversionformatyearkey, @v_message, @v_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
                    
              END
            END
           END
          
          FETCH taqprojectscaledetails_cur INTO @v_itemcategorycode,@v_itemcode
        END  --taqprojectscaledetails_cur

        CLOSE taqprojectscaledetails_cur
        DEALLOCATE taqprojectscaledetails_cur 

      FETCH scaleprojectkey_cursor INTO @v_scaleprojectkey
    END   --scaleprojectkey_cursor

    CLOSE scaleprojectkey_cursor
    DEALLOCATE scaleprojectkey_cursor 

    -- Generate costs
    --SELECT * FROM #tmp_structure
        
    -- Sort the spec item/scale detail structure by the sort order on the gentables tableid 627 for 
    -- taqprojectscaledetails.calculationtype    
    DECLARE calctype_cur CURSOR FOR
      SELECT DISTINCT t.calculationtypecode, ISNULL(g.sortorder,0) sortorder
        FROM #tmp_structure t
        LEFT OUTER JOIN gentables g ON t.calculationtypecode = g.datacode AND g.tableid = 627
        ORDER BY sortorder, t.calculationtypecode

    OPEN calctype_cur
    FETCH calctype_cur INTO @v_calculationtypecode,@v_sortorder

    WHILE (@@FETCH_STATUS=0) BEGIN
      SELECT @v_calcind=g.gen1ind,@v_calcsecqsicode=g.numericdesc1,@v_perqty=g.numericdesc2,@v_specialprocess=e.gentext1
        FROM gentables g, gentables_ext e
        WHERE g.tableid = 627 
          AND g.datacode = @v_calculationtypecode
          AND g.tableid = e.tableid 
          AND g.datacode = e.datacode

    --print '**@v_calculationtypecode= ' + cast(@v_calculationtypecode as varchar)

      DECLARE tmpstructure_cur CURSOR FOR
        SELECT taqdetailscalekey,taqversionspecitemkey,autoapplyind
          FROM #tmp_structure
          WHERE calculationtypecode = @v_calculationtypecode

      OPEN tmpstructure_cur

      FETCH tmpstructure_cur INTO @v_taqdetailscalekey,@v_taqversionspecitemkey,@v_autoapplyind

      WHILE (@@FETCH_STATUS=0) BEGIN
    --print '**@v_calcsecqsicode= ' + cast(@v_calcsecqsicode as varchar)
    --print '**@v_taqdetailscalekey= ' + cast(@v_taqdetailscalekey as varchar)
          
        -----  GENERATE COSTS (pass in taqdetailscalkey,autoapplyind,taqversionspecitemkey,calcind,
        -----  calcsecqsicode,perqty,specialprocess,taqversionformatkey
        EXEC qpl_generate_scale_costs @v_taqversionspecitemkey,@v_taqdetailscalekey,@v_autoapplyind,@v_calcind,
          @v_calcsecqsicode,@v_perqty,@v_specialprocess, @v_specs_formatyearkey, @SpecItemsByPrintingView,
        @o_error_code output,@o_error_desc output

        FETCH tmpstructure_cur INTO @v_taqdetailscalekey,@v_taqversionspecitemkey,@v_autoapplyind
      END
      CLOSE tmpstructure_cur
      DEALLOCATE tmpstructure_cur 

      FETCH calctype_cur INTO @v_calculationtypecode,@v_sortorder
    END   --calctype_cur

    CLOSE calctype_cur
    DEALLOCATE calctype_cur 

      -- Write costs
    SELECT @v_prodqtyitemcategorycode = datacode,@v_prodqtyitemcode = datasubcode FROM subgentables  WHERE tableid = 616 AND qsicode = 6
        
    SELECT @v_printing = printingnumber, @v_quantity = ISNULL(quan, 0)
      FROM @SpecItemsByPrintingView
      WHERE itemcategorycode = @v_prodqtyitemcategorycode
        AND itemcode = @v_prodqtyitemcode

    --print '@v_printing= ' + cast(@v_printing as varchar)
    --print '@v_production_quantity= ' + cast(@v_quantity as varchar)

    DECLARE bucketcosts_cursor CURSOR FOR
      SELECT formatkey, internalcode, SUM(cost) cost, validforprtgs, calccostcode
      FROM #scalecostbucket_table
      GROUP BY formatkey, internalcode, validforprtgs, calccostcode

    OPEN bucketcosts_cursor
          
    FETCH bucketcosts_cursor
      INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
          
    WHILE (@@FETCH_STATUS = 0) 
    BEGIN
      SET @v_acceptgenind=NULL

      IF EXISTS (
        SELECT 1 FROM taqversioncosts
        WHERE taqversionformatyearkey = @i_taqversionformatyearkey AND acctgcode = @v_bucket_internal
      )
      BEGIN --- acctgcode exists on taqversioncosts already for that version/format/year
        SELECT @v_acceptgenind=acceptgenerationind
          FROM taqversioncosts
          WHERE acctgcode = @v_bucket_internal 
            AND taqversionformatyearkey = @i_taqversionformatyearkey  

        IF ISNULL(@v_acceptgenind, 0) > 0 
        BEGIN
          IF (ISNULL(@v_quantity, 0) <> 0) BEGIN
            SET @v_unitcost = ISNULL(@v_bucket_cost, 0) / @v_quantity --unit cost calculation

            --exec qutl_trace 'qpl_generate_costs_main', 
            --  'UPDATE taqversioncosts', NULL, NULL,
            --  '@v_acceptgenind', @v_acceptgenind, NULL,
            --  '@v_bucket_internal', @v_bucket_internal, NULL,
            --  '@v_bucket_cost', @v_bucket_cost, NULL

            UPDATE taqversioncosts
                SET versioncostsamount = ISNULL(@v_bucket_cost, 0), unitcost = ISNULL(@v_unitcost, 0)
              WHERE acctgcode = @v_bucket_internal 
                AND taqversionformatyearkey = @i_taqversionformatyearkey
          END
          ELSE BEGIN
            SET @v_unitcost = 0
                  
            --exec qutl_trace 'qpl_generate_costs_main', 
            --  'UPDATE taqversioncosts', NULL, NULL,
            --  '@v_acceptgenind', @v_acceptgenind, NULL,
            --  '@v_bucket_internal', @v_bucket_internal, NULL,
            --  '@v_bucket_cost', @v_bucket_cost, NULL

            UPDATE taqversioncosts
                SET versioncostsamount = ISNULL(@v_bucket_cost, 0), unitcost = @v_unitcost
              WHERE acctgcode = @v_bucket_internal 
                AND taqversionformatyearkey = @i_taqversionformatyearkey
          END
          SET @v_message = 'New costs for P&L Spec item have been added to this charge code'
          -- print @v_message + ': ' + convert(varchar,@v_bucket_cost)
          -- print ''
          INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
            VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_bucket_internal, ISNULL(@v_bucket_cost, 0),
              getdate(), 'QSIADMIN', @i_processtype)
        END
        ELSE BEGIN  -- error
             --write error to taqversioncostmessages
          SET @v_message = 'Allow Gen? is not selected for this printing. Costs will not be added to the charge code.'
          --print @v_message
          --print ''
          INSERT INTO taqversioncostmessages 
          (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
          VALUES
          (@i_taqversionformatyearkey, @v_message, 3, @v_bucket_internal, @v_bucket_cost,
          getdate(), 'QSIADMIN', @i_processtype)
        END 
      END
      ELSE BEGIN -- add taqversioncosts row
        --if there is a quantity, recalculate unit cost and update it
        IF (@v_quantity > 0) BEGIN
          SET @v_unitcost = @v_bucket_cost / @v_quantity --unit cost calculation
        --END
        --ELSE BEGIN
        --  SET @v_unitcost = @v_bucket_cost            
        --END

          -- component unitcost
          SET @v_compkey  = 0
          SET @v_costcompkey = 0
          SET @v_pocostind = 0
          SET @v_compunitcost = @v_unitcost

          SELECT @v_compkey = ISNULL(compkey, 0), @v_pocostind = ISNULL(pocostind, 0)
            FROM cdlist
            WHERE internalcode =  @v_bucket_internal
            
          IF @v_compkey > 0 
          BEGIN
            --print '@v_compkey= ' + cast(@v_compkey as varchar)
            --print '@v_bucket_internal= ' + cast(@v_bucket_internal as varchar)
            SET @v_speccategorykey = 0
            
            SELECT TOP 1 @v_speccategorykey = ISNULL(taqversionspecategorykey,0), @v_compqty = ISNULL(quantity,0)
              FROM taqversionspeccategory 
              WHERE taqversionkey = @v_taqversionkey
                AND taqversionformatkey = @v_taqprojectformatkey
                AND itemcategorycode = @v_compkey

            --print '@v_speccategorykey= ' + cast(@v_speccategorykey as varchar)
            --print '@v_compqty= ' + cast(@v_compqty as varchar)

            IF @v_speccategorykey > 0 BEGIN
              SET @v_costcompkey = @v_speccategorykey
            END
            IF @v_compqty > 0 BEGIN
              SET @v_compunitcost = @v_bucket_cost / @v_compqty
            END
            
            SET @v_acceptgenind = 1
            
            IF @v_costcompkey > 0 AND (@v_bucket_cost IS NOT NULL OR @v_unitcost IS NOT NULL OR @v_compunitcost IS NOT NULL)
            BEGIN
              --exec qutl_trace 'qpl_generate_costs_main', 
              --  'INSERT INTO taqversioncosts', NULL, NULL,
              --  '@v_bucket_internal', @v_bucket_internal, NULL,
              --  '@v_bucket_cost', @v_bucket_cost, NULL,
              --  '@v_printing', @v_printing, NULL,
              --  '@v_acceptgenind', @v_acceptgenind, NULL,
              --  '@v_pocostind', @v_pocostind, NULL

              INSERT INTO taqversioncosts --insert replacement cost with unitcost
                (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, unitcost, printingnumber, acceptgenerationind, lastuserid, lastmaintdate, taqversionspeccategorykey, compunitcost, pocostind)
                VALUES (@i_taqversionformatyearkey, @v_bucket_internal, @v_bucket_calccost, ISNULL(@v_bucket_cost, 0), ISNULL(@v_unitcost, 0), @v_printing, @v_acceptgenind, 'QSIADMIN', getdate(), @v_costcompkey, ISNULL(@v_compunitcost, 0), @v_pocostind)

              SET @v_message = 'Costs for P&L Spec item have been added to this charge code'
              -- print @v_message + ': ' + convert(varchar,@v_bucket_cost)
              -- print ''
              INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
                VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_bucket_internal, ISNULL(@v_bucket_cost, 0),
                  getdate(), 'QSIADMIN', @i_processtype)
            END
          END
        END
      END
      FETCH bucketcosts_cursor INTO @v_bucket_format, @v_bucket_internal, @v_bucket_cost, @v_bucket_validprtgs, @v_bucket_calccost
    END
    CLOSE bucketcosts_cursor
    DEALLOCATE bucketcosts_cursor
  END --@i_processtype = 1
  ELSE BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END

  RETURN
 
 RETURN_ERROR:
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_generate_costs_main TO PUBLIC
GO
