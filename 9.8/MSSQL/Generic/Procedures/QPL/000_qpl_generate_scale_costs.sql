if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_generate_scale_costs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_generate_scale_costs
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

CREATE PROCEDURE qpl_generate_scale_costs (  
  @i_taqversionspecitemkey     integer,
  @i_taqdetailscalekey         integer,
  @i_autoapplyind              tinyint,
  @i_percentcalcind            tinyint,
  @i_calcspecqsicode           float,
  @i_perqty                    float,
  @i_specialprocess            varchar(255),
  @i_taqversionformatyearkey   integer,
  @SpecItemsByPrintingView SpecItemsByPrinting READONLY,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_generate_scale_costs
**  Desc: This stored procedure generates the costs based on the calculation types for the scale detail
**    row being processed
**
**  Auth: Kusum Basra
**  Date: March 22, 2012
*******************************************************************************************************
*******************************************************************************************************
**  Change History
******************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/24/2016    Kusum       Case 38273
**  04/06/2017   Colman      Case 44013
**  09/30/2017   Colman      Case 47247 - Math wrong on generate cost message page
**  12/21/2017   Colman      Case 48649 - Cost generation times Printing Version v. PO Summary
**  01/24/2018   Colman      Case 48235 - SS: Implement deductions in scales
******************************************************************************************************/

DECLARE
  @v_count        INT,
  @v_chargecodedesc    VARCHAR(30),
  @v_taqdetailscalekey  INT,
  @v_formatyearkey    INT,
  @v_specitemkey      INT,
  @v_itemcategorycode    INT,
  @v_itemcode        INT,
  @v_itemdetailcode    INT,
  @v_itemcategory_desc  VARCHAR(40),
  @v_itemcode_desc    VARCHAR(120),
  @v_itemdetail_desc    VARCHAR(120),
  @v_specitemdesc      VARCHAR(255),
  @v_fixedcost      NUMERIC(15,4),
  @v_variablecost      NUMERIC(15,4),
  @v_acctgcatcode      INT,
  @v_cost          NUMERIC(15,4),
  @v_unitcost        NUMERIC(15,4),
  @v_costtype        VARCHAR(50),
  @v_ext_chargecode    VARCHAR(255),
  @v_int_chargecode    INT,
  @v_bucket_format    INT,
  @v_bucket_internal    INT,
  @v_bucket_cost      FLOAT,
  @v_bucket_validprtgs  INT,
  @v_bucket_calccost    INT,
  @v_acceptgenind      INT,
  @v_taqversionspecategorykey  INT,
  @v_fixedamount      NUMERIC(15,4),
  @v_variableamount    NUMERIC(15,4),
  @v_specifiedquantity  INT,
  @v_manuscriptpages    INT,
  @v_message        VARCHAR(255),
  @v_fixedchargecode    INT,
  @v_chargecode      INT,
  @v_calcspecitemcategorycode INT,
  @v_calcspecitemcode    INT,
  @v_calcspec_int      INT,
  @v_calcspec_numeric    NUMERIC(15,4),
  @v_calculationtypedesc  VARCHAR(120),
  @v_calculationtypecode  INT,
  @v_code2        INT,
  @v_total_cost      NUMERIC(15,4),
  @v_validforprtscode    INT,
  @v_taqprojectformatkey  INT,
  @v_externaldesc      VARCHAR(30)


BEGIN
  SET @o_error_code=0
  SET @o_error_desc=NULL

  SELECT @v_itemcategorycode=itemcategorycode,@v_itemcode=itemcode,@v_itemdetailcode=itemdetailcode,@v_fixedamount=COALESCE(fixedamount,0),
         @v_fixedchargecode=fixedchargecode,@v_variableamount=COALESCE(amount,0),@v_chargecode=chargecode, @v_chargecodedesc = c.externaldesc,
         @v_calculationtypecode=calculationtypecode, @v_calculationtypedesc=(SELECT datadesc FROM gentables WHERE tableid = 627 AND datacode=calculationtypecode)
    FROM taqprojectscaledetails LEFT OUTER JOIN cdlist c ON chargecode = c.internalcode
   WHERE taqdetailscalekey = @i_taqdetailscalekey

--PRINT '*** Generating Scale Costs... ***'
--PRINT '@i_taqversionspecitemkey=' + convert(varchar, @i_taqversionspecitemkey)
--PRINT '@i_taqdetailscalekey=' + convert(varchar, @i_taqdetailscalekey)
--PRINT '@i_autoapplyind='+ convert(varchar, @i_autoapplyind)
--PRINT '@i_percentcalcind=' + convert(varchar, @i_percentcalcind)
--print '@i_specialprocess= ' + @i_specialprocess
--print '@i_calcspecqsicode= ' + cast(@i_calcspecqsicode as varchar)
--print '@i_perqty= ' + cast(@i_perqty as varchar)
--print '@i_taqdetailscalekey= ' + cast(@i_taqdetailscalekey as varchar) 
--print '@v_fixedchargecode= ' + cast(@v_fixedchargecode as varchar)
--print '@v_fixedamount= ' + cast(@v_fixedamount as varchar)
--print '@v_chargecode= ' + cast(@v_chargecode as varchar)
--print '@v_variableamount= ' + cast(@v_variableamount as varchar)

  EXEC gentables_longdesc 616, @v_itemcategorycode, @v_itemcategory_desc OUTPUT
  SET @v_itemcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@v_itemcategorycode,@v_itemcode,'long')))
  SET @v_specitemdesc = @v_itemcategory_desc + '/' +@v_itemcode_desc

  IF @v_itemdetailcode > 0 BEGIN
  SET @v_itemdetail_desc = dbo.get_sub2gentables_desc(616,@v_itemcategorycode,@v_itemcode,@v_itemdetailcode,'long')
    SET @v_specitemdesc = @v_specitemdesc + '/' +@v_itemdetail_desc
  END
  IF @i_autoapplyind = 1 BEGIN
    SET @v_specitemdesc = @v_specitemdesc + '- Auto Applied' 
  END

  SELECT @v_validforprtscode = validforprtscode, @v_taqprojectformatkey = taqprojectformatkey
    FROM @SpecItemsByPrintingView

  SET @v_fixedcost = NULL
  SET @v_ext_chargecode=NULL

  
  -- Generate Fixed Cost
  IF 1=1 -- @v_fixedamount > 0 
  BEGIN
    IF @v_fixedchargecode IS NOT NULL 
    BEGIN
      SELECT @v_acctgcatcode=placctgcategorycode,@v_ext_chargecode=externalcode, @v_costtype=costtype,@v_externaldesc = externaldesc
      FROM cdlist
      WHERE internalcode = @v_fixedchargecode 
                  
      IF (LOWER(@v_costtype)='e') BEGIN
        SET @v_bucket_calccost=2
      END
      ELSE BEGIN
        SET @v_bucket_calccost=1
      END
      
      --insert costs into bucket
      SET @v_bucket_cost=NULL

      SELECT @v_bucket_cost=cost FROM #scalecostbucket_table WHERE internalcode=@v_fixedchargecode 
        AND taqversionspecitemkey=@i_taqversionspecitemkey
        AND buckettype = 'f'
          
      IF @v_bucket_cost IS NULL BEGIN --insert value to costbucket
        SET @v_bucket_cost = @v_fixedamount
        INSERT INTO #scalecostbucket_table (formatkey,internalcode,cost,validforprtgs,calccostcode,taqversionspecitemkey,buckettype)
          VALUES (@v_taqprojectformatkey, @v_fixedchargecode, @v_bucket_cost,@v_validforprtscode,@v_bucket_calccost,@i_taqversionspecitemkey,'f')
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'New cost bucket 1', NULL, NULL,
          -- '@v_fixedchargecode', @v_fixedchargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
      ELSE BEGIN --update already existing bucket value
        SET @v_bucket_cost = @v_bucket_cost + @v_fixedamount
        UPDATE #scalecostbucket_table
           SET cost=@v_bucket_cost
         WHERE internalcode=@v_fixedchargecode 
          AND taqversionspecitemkey = @i_taqversionspecitemkey
          AND buckettype='f'
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'Update cost bucket 1', NULL, NULL,
          -- '@v_fixedchargecode', @v_fixedchargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
          
      SET @v_message = 'Fixed Costs for ' + @v_specitemdesc + ' has been added to this charge code: ' + @v_externaldesc
      -- PRINT @v_message
            
      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_fixedchargecode, @v_bucket_cost,getdate(), 'QSIADMIN', 1)
    END
  END

  --Generate Variable Cost
  IF @i_specialprocess = 'SPECUNIT' 
  BEGIN
    SELECT @v_specifiedquantity = quan
      FROM @SpecItemsByPrintingView
     WHERE taqversionspecitemkey = @i_taqversionspecitemkey

    --print '@v_specifiedquantity = ' + coalesce(cast(@v_specifiedquantity AS VARCHAR),'null')

    SELECT @v_variablecost = (@v_specifiedquantity/@i_perqty) * @v_variableamount

    IF 1=1 -- @v_variablecost > 0 
    BEGIN
      SELECT @v_acctgcatcode = placctgcategorycode, @v_costtype = costtype,@v_ext_chargecode = externalcode, @v_externaldesc = externaldesc
        FROM cdlist WHERE internalcode = @v_chargecode 

      --print '@v_ext_chargecode  = ' + cast(@v_ext_chargecode AS VARCHAR)
      --print '@v_chargecode  = ' + cast(@v_chargecode AS VARCHAR)  
      --print '@v_externaldesc  = ' + cast(@v_externaldesc AS VARCHAR)  
      --print '@v_acctgcatcode  = ' + cast(@v_acctgcatcode AS VARCHAR)  

      IF LOWER(@v_costtype) = 'e'
        SET @v_bucket_calccost=2
      ELSE
        SET @v_bucket_calccost=1

      --insert costs into bucket
      SET @v_bucket_cost=NULL
      
      SELECT @v_bucket_cost = cost FROM #scalecostbucket_table WHERE internalcode = @v_chargecode 
        AND taqversionspecitemkey=@i_taqversionspecitemkey
        AND buckettype = 'v'

      IF @v_bucket_cost IS NULL BEGIN--insert value to costbucket
        SET @v_bucket_cost = @v_variablecost
        INSERT INTO #scalecostbucket_table (formatkey, internalcode, cost, validforprtgs,  calccostcode, taqversionspecitemkey, buckettype)
        VALUES (@v_taqprojectformatkey, @v_chargecode, @v_bucket_cost, @v_validforprtscode,  @v_bucket_calccost, @i_taqversionspecitemkey,'v')
        
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'New cost bucket 2', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
      ELSE  BEGIN--update already existing bucket value
        SET @v_bucket_cost = @v_bucket_cost + @v_variablecost
        UPDATE #scalecostbucket_table SET cost = @v_bucket_cost WHERE internalcode = @v_chargecode
          AND taqversionspecitemkey = @i_taqversionspecitemkey
          AND buckettype = 'v'
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'Update cost bucket 2', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END

      SET @v_message = 'Variable Costs for ' + @v_specitemdesc + ' has been added to this charge code: ' + @v_externaldesc
      -- PRINT @v_message

      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost, getdate(), 'QSIADMIN', 1)
    END
    ELSE BEGIN
      SET @v_message = 'Unable to generate Variable Costs for ' + @v_specitemdesc + ' because unable to get quantity' 
      -- PRINT @v_message

      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost, getdate(), 'QSIADMIN', 1)
    END
  END
  
  ELSE IF @i_specialprocess = 'MANUSPG' BEGIN
    SELECT @v_manuscriptpages = v.manuscriptpages 
      FROM taqversionformatyear y, taqversion v 
     WHERE v.taqprojectkey = y.taqprojectkey 
       AND v.plstagecode = y.plstagecode 
       AND v.taqversionkey = y.taqversionkey 
       AND y.taqversionformatyearkey = @i_taqversionformatyearkey

    --print '@v_manuscriptpages = ' + coalesce(cast(@v_manuscriptpages AS VARCHAR),'null')

    SELECT @v_variablecost = (@v_manuscriptpages/@i_perqty) * @v_variableamount

    IF 1=1 -- @v_variablecost > 0
    BEGIN
      SELECT @v_acctgcatcode = placctgcategorycode, @v_costtype = costtype,@v_ext_chargecode = externalcode, @v_externaldesc = externaldesc
      FROM cdlist WHERE internalcode = @v_chargecode 

      --print '@v_ext_chargecode  = ' + cast(@v_ext_chargecode AS VARCHAR)
      --print '@v_chargecode  = ' + cast(@v_chargecode AS VARCHAR)  
      --print '@v_externaldesc  = ' + cast(@v_externaldesc AS VARCHAR)  
      --print '@v_acctgcatcode  = ' + cast(@v_acctgcatcode AS VARCHAR)  

      IF LOWER(@v_costtype) = 'e'
        SET @v_bucket_calccost=2
      ELSE
        SET @v_bucket_calccost=1

      --insert costs into bucket
      SET @v_bucket_cost=NULL
      
      SELECT @v_bucket_cost = cost FROM #scalecostbucket_table WHERE internalcode = @v_chargecode
        AND taqversionspecitemkey=@i_taqversionspecitemkey
        AND buckettype = 'v'

      IF @v_bucket_cost IS NULL --insert value to costbucket
      BEGIN
        SET @v_bucket_cost = @v_variablecost
        INSERT INTO #scalecostbucket_table  (formatkey, internalcode, cost, validforprtgs,  calccostcode, taqversionspecitemkey, buckettype)
        VALUES (@v_taqprojectformatkey, @v_chargecode, @v_bucket_cost, @v_validforprtscode,  @v_bucket_calccost, @i_taqversionspecitemkey, 'v')
        
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'New cost bucket 3', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
      ELSE BEGIN --update already existing bucket value
        SET @v_bucket_cost = @v_bucket_cost + @v_variablecost
        UPDATE #scalecostbucket_table SET cost = @v_bucket_cost WHERE internalcode = @v_chargecode
          AND taqversionspecitemkey = @i_taqversionspecitemkey
          AND buckettype = 'v'
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'Update cost bucket 3', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END

      SET @v_message = 'Variable Costs for ' + @v_specitemdesc + ' has been added to this charge code: ' + @v_externaldesc
      -- PRINT @v_message

      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
    VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost, getdate(), 'QSIADMIN', 1)
    END
    ELSE BEGIN
      SET @v_message = 'Unable to generate Variable Costs for ' + @v_specitemdesc + ' because unable to get quantity' 
      -- PRINT @v_message
      
      INSERT INTO taqversioncostmessages(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost, getdate(), 'QSIADMIN', 1)
    END
  END  
   
  ELSE IF @i_calcspecqsicode IS NOT NULL AND @i_calcspecqsicode <> 0 BEGIN
    SELECT @v_acctgcatcode=placctgcategorycode,@v_costtype=costtype,@v_ext_chargecode = externalcode,@v_externaldesc = externaldesc
    FROM cdlist WHERE internalcode = @v_chargecode 

--print '@v_ext_chargecode  = ' + cast(@v_ext_chargecode AS VARCHAR)
--print '@v_chargecode  = ' + cast(@v_chargecode AS VARCHAR)  
--print '@v_externaldesc  = ' + cast(@v_externaldesc AS VARCHAR)  
--print '@v_acctgcatcode  = ' + cast(@v_acctgcatcode AS VARCHAR)  
   
    SELECT @v_calcspecitemcategorycode= datacode,@v_calcspecitemcode = datasubcode,@v_calculationtypedesc=datadesc
      FROM subgentables WHERE tableid = 616 AND qsicode = @i_calcspecqsicode

    SELECT @v_calcspec_int = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@SpecItemsByPrintingView,@v_calcspecitemcategorycode,@v_calcspecitemcode),0),
         @v_calcspec_numeric = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@SpecItemsByPrintingView,@v_calcspecitemcategorycode,@v_calcspecitemcode),0)

--print '@v_calcspec_int= ' + cast(@v_calcspec_int as varchar)
--print '@v_calcspec_numeric= ' + cast(@v_calcspec_numeric as varchar)

    IF @v_calcspec_int = -1 BEGIN
       SET @v_message = 'Cannot find specification item for ' + @v_specitemdesc + ' for this format year which is required for ' + 
         'the calculation type of ' + @v_calculationtypedesc + '. Cannot generate variable items for this item ' + convert(varchar,@v_chargecode)
      -- PRINT @v_message

       INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 2, @v_chargecode, NULL,getdate(), 'QSIADMIN', 1)
    END
    ELSE BEGIN
      IF @v_calcspec_int > 0 
         SELECT @v_variablecost = (@v_calcspec_int/@i_perqty) * @v_variableamount
      ELSE
         SELECT @v_variablecost = (@v_calcspec_numeric/@i_perqty) * @v_variableamount
    END
--print '@v_variablecost= ' + cast(@v_variablecost as varchar)

    IF 1=1 -- @v_variablecost > 0 
    BEGIN
      SELECT @v_acctgcatcode=placctgcategorycode,@v_costtype=costtype,@v_ext_chargecode = externalcode,@v_externaldesc = externaldesc
      FROM cdlist
      WHERE internalcode = @v_chargecode 
                  
      IF (LOWER(@v_costtype)='e') BEGIN
        SET @v_bucket_calccost=2
      END
      ELSE BEGIN
        SET @v_bucket_calccost=1
      END
      
      --insert costs into bucket
      SET @v_bucket_cost=NULL

      SELECT @v_bucket_cost=cost FROM #scalecostbucket_table  WHERE internalcode=@v_chargecode 
        AND taqversionspecitemkey=@i_taqversionspecitemkey
        AND buckettype = 'v'
          
      IF @v_bucket_cost IS NULL BEGIN --insert value to costbucket
        SET @v_bucket_cost = @v_variablecost
        INSERT INTO #scalecostbucket_table  (formatkey,internalcode,cost,validforprtgs,calccostcode,taqversionspecitemkey,buckettype)
        VALUES (@v_taqprojectformatkey, @v_chargecode, @v_bucket_cost,@v_validforprtscode,@v_bucket_calccost,@i_taqversionspecitemkey,'v')
                      
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'New cost bucket 4', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
      ELSE BEGIN --update already existing bucket value
        SET @v_bucket_cost = @v_bucket_cost + @v_variablecost
        UPDATE #scalecostbucket_table
        SET cost=@v_bucket_cost
        WHERE internalcode=@v_chargecode
          AND taqversionspecitemkey = @i_taqversionspecitemkey
          AND buckettype = 'v'
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'Update cost bucket 4', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
          
      SET @v_message = 'Variable Costs for ' + @v_specitemdesc + ' has been added to this charge code: ' + @v_externaldesc
      -- PRINT @v_message
            
      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES  (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost,getdate(), 'QSIADMIN', 1)
    END
  END 
  ELSE IF @i_percentcalcind IS NOT NULL AND @i_percentcalcind <> 0 BEGIN

    SELECT @v_total_cost = 0
    
    SELECT @v_count = COUNT(*) FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 21 AND code1 = @v_calculationtypecode
    
    IF @v_count = 0 BEGIN
      SET @v_message = 'Missing Calculation Type to Charge Code Mapping for the calculation type of ''' + @v_calculationtypedesc + 
        '''. Cannot allocate costs for Charge Code ' + convert(varchar,@v_chargecode) + ' (' + @v_chargecodedesc + ')'
      -- PRINT @v_message

      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 3, @v_chargecode, NULL,getdate(), 'QSIADMIN', 1)
    END

    DECLARE gentablesrelationshipdetail_cur CURSOR FOR
      SELECT code2
        FROM gentablesrelationshipdetail
       WHERE code1 = @v_calculationtypecode 
         AND gentablesrelationshipkey = 21   --Calculation Type to Charge code Mapping (for % Calc Type Only)

    OPEN gentablesrelationshipdetail_cur

    FETCH gentablesrelationshipdetail_cur INTO @v_code2

    WHILE (@@FETCH_STATUS=0) BEGIN
      SET @v_bucket_cost=0
      SELECT @v_bucket_cost=ISNULL(cost, 0) FROM #scalecostbucket_table WHERE internalcode=@v_code2 

      SELECT @v_total_cost = @v_total_cost + @v_bucket_cost
        
      FETCH gentablesrelationshipdetail_cur INTO @v_code2
    END

    CLOSE gentablesrelationshipdetail_cur
    DEALLOCATE gentablesrelationshipdetail_cur

    SELECT @v_variablecost = @v_total_cost * (@v_variableamount/100)
 
    IF 1=1  -- @v_variablecost > 0 
    BEGIN
      SELECT @v_acctgcatcode=placctgcategorycode,@v_costtype=costtype,@v_ext_chargecode = externalcode,@v_externaldesc = externaldesc
      FROM cdlist
      WHERE internalcode = @v_chargecode 
                    
      IF (LOWER(@v_costtype)='e') BEGIN
        SET @v_bucket_calccost=2
      END
      ELSE BEGIN
        SET @v_bucket_calccost=1
      END
      
      --insert costs into bucket
      SET @v_bucket_cost=NULL

      SELECT @v_bucket_cost=cost FROM #scalecostbucket_table WHERE internalcode=@v_chargecode 
        AND taqversionspecitemkey=@i_taqversionspecitemkey
        AND buckettype = 'v'
          
      IF @v_bucket_cost IS NULL BEGIN --insert value to costbucket
        SET @v_bucket_cost = @v_variablecost
        INSERT INTO #scalecostbucket_table (formatkey,internalcode,cost,validforprtgs,calccostcode,taqversionspecitemkey,buckettype)
        VALUES (@v_taqprojectformatkey, @v_chargecode, @v_bucket_cost,@v_validforprtscode,@v_bucket_calccost,@i_taqversionspecitemkey,'v')
        
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'New cost bucket 5', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
      ELSE BEGIN --update already existing bucket value
        SET @v_bucket_cost = @v_bucket_cost + @v_variablecost
        UPDATE #scalecostbucket_table
           SET cost=@v_bucket_cost
         WHERE internalcode=@v_chargecode
          AND taqversionspecitemkey = @i_taqversionspecitemkey
          AND buckettype = 'v'
          
        -- print ''
        -- exec qutl_trace 'qpl_generate_scale_costs', 'Update cost bucket 5', NULL, NULL,
          -- '@v_chargecode', @v_chargecode, NULL,
          -- '@v_bucket_cost', @v_bucket_cost, NULL,
          -- '@i_taqversionspecitemkey', @i_taqversionspecitemkey, NULL,
          -- '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL,
          -- '@v_validforprtscode', @v_validforprtscode, NULL,
          -- '@v_bucket_calccost', @v_bucket_calccost
      END
          
      SET @v_message = 'Variable Costs for ' + @v_specitemdesc + ' has been added to this charge code: ' + @v_externaldesc 
      -- PRINT @v_message
            
      INSERT INTO taqversioncostmessages (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
      VALUES (@i_taqversionformatyearkey, @v_message, 4, @v_chargecode, @v_variablecost,getdate(), 'QSIADMIN', 1)
    END
  END     
END
GO

GRANT EXEC ON qpl_generate_scale_costs TO PUBLIC
GO
