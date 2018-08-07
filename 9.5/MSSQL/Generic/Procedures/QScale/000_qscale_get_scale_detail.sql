if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scale_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qscale_get_scale_detail
GO

CREATE PROCEDURE qscale_get_scale_detail ( 
  @i_taqversionformatyearkey	INT, 
  @i_scaleprojectkey	INT,
  @i_taqprojecttitle	VARCHAR(255),
  @i_scaletabkey		INT,
  @i_taqversionspecitemkey	INT,
  @i_messagetypecode	INT,
  @i_itemcategorycode	INT,
  @i_itemcode			INT,
  @i_itemdetailcode		INT,
  @i_autoapplyind		TINYINT,
  @i_processtype		INT,
  @o_error_code			INT OUTPUT,
  @o_error_desc			VARCHAR(2000) OUTPUT)
AS

/************************************************************************************************
**  Name: qscale_get_scale_detail
**  Desc: This stored procedure will be find the valid scale detail keys for the itmecategory/ 
**        itemcode and itemdetail code matching all grid parameters and thresholds
**
**  Auth: Kusum Basra
**  Date: March 21 2012
*************************************************************************************************/

DECLARE
  @v_tabsectiontype	INT,
  @v_rowspeckey		INT,
  @v_columnspeckey  int,
  @v_rowitemcategorycode	INT,
  @v_colitemcategorycode	INT,
  @v_rowitemcode		INT,
  @v_colitemcode		INT,
  @v_row_int			INT,
  @v_col_int			INT,
  @v_row_isrange  tinyint,
  @v_col_isrange  tinyint,
  @v_row_parametervaluecode INT,
  @v_col_parametervaluecode INT,
  @v_thresholdvalue_int INT,
  @v_row_numeric		NUMERIC(15,4),
  @v_col_numeric		NUMERIC(15,4),
  @v_thresholdvalue_numeric NUMERIC(15,4), 
  @v_pos				INT,
  @v_precision        VARCHAR(40),
  @v_use_int		    CHAR(1),
  @v_use_num			CHAR(1),
  @v_use_col_int	CHAR(1),	
  @v_use_col_num	CHAR(1),
  @v_use_threshold_int CHAR(1),	
  @v_use_threshold_num CHAR(1),
  @v_count			INT,
  @v_count2			INT,
  @v_count3			INT,
  @v_count4			INT,
  @v_count5     INT,
  @v_count_num  INT,
  @v_message			VARCHAR(255),
  @v_itemcategory_desc	VARCHAR(40),   
  @v_colitemcategory_desc VARCHAR(40),   
  @v_itemcode_desc	VARCHAR(120),
  @v_itemdetail_desc	VARCHAR(120),
  @v_rowcategory_desc	VARCHAR(40),
  @v_rowitem_desc		VARCHAR(120),
  @v_colcategory_desc	VARCHAR(40),
  @v_colitem_desc		VARCHAR(120),
  @v_thresholdcategory_desc VARCHAR(40),
  @v_thresholdcode_desc VARCHAR(120),
  @v_taqscalerowkey	INT,
  @v_taqscalecolkey	INT,
  @v_col_itemcategorycode	INT,
  @v_col_itemcode		INT,
  @v_taqdetailscalekey	INT,
  @v_taqprojecttitle		VARCHAR(255),
  @v_calculationtypecode	INT,
  @v_thresholdspeccategorycode  INT,
  @v_thresholdspecitemcode INT,
  @v_saved_thresholdspeccategorycode  INT,
  @v_saved_thresholdspecitemcode  INT,
  @v_values_same CHAR(1),
  @v_thresholdvalue1  DECIMAL(15,4),
  @v_thresholdvalue2  DECIMAL(15,4),
  @v_threshold_match CHAR(1)


BEGIN

  --print 'In qscale_get_scale_detail' 

  SELECT @v_threshold_match = 'N'
  SELECT @v_count = 0
	SELECT @v_count2 = 0
  SELECT @v_count3 = 0
  SELECT @v_count4 = 0

  EXEC gentables_longdesc 616, @i_itemcategorycode, @v_itemcategory_desc OUTPUT
  SET @v_itemcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@i_itemcategorycode,@i_itemcode,'long')))
  IF @i_itemdetailcode > 0 BEGIN
		SET  @v_itemdetail_desc  = dbo.get_sub2gentables_desc (616,@i_itemcategorycode,@i_itemcode,@i_itemdetailcode,'long')
	END

	SELECT @v_tabsectiontype = tabsectiontype, @v_rowspeckey = rowspeckey, @v_columnspeckey = columnspeckey
	  FROM taqscaleadmintab
     WHERE scaletabkey = @i_scaletabkey

  SET @v_row_isrange = 0
  SET @v_col_isrange = 0
  
	IF @v_tabsectiontype = 1 BEGIN  -- Grid
		SELECT @v_rowitemcategorycode = itemcategorycode, @v_rowitemcode = itemcode, @v_row_parametervaluecode = COALESCE(parametervaluecode,0)
      FROM taqscaleadminspecitem
     WHERE scaleadminspeckey = @v_rowspeckey

    IF COALESCE(@v_rowitemcategorycode,0) = 0 BEGIN
      -- no itemcategorycode found
      SET @v_message = 'Itemcategorycode (row)' + @v_rowitemcategorycode + ' not found in taqscaleadminspecitem for scaleadminspeckey ' +
       CONVERT(VARCHAR,@v_rowspeckey) + ' .' 
      SET @o_error_code = -1
      SET @o_error_desc = @v_message
      goto ExitHandler
    END

    IF COALESCE(@v_rowitemcode,0) = 0 BEGIN
      -- no itemcode found
      SET @v_message = 'Itemcategorycode (row)' + @v_rowitemcode + ' not found in taqscaleadminspecitemfor scaleadminspeckey ' +
       CONVERT(VARCHAR,@v_rowspeckey) + ' .' 
      SET @o_error_code = -1
      SET @o_error_desc = @v_message
      goto ExitHandler
    END

    IF @v_row_parametervaluecode = 2 BEGIN
      -- range
      SET @v_row_isrange = 1
    END
    
    EXEC gentables_longdesc 616, @v_rowitemcategorycode, @v_rowcategory_desc OUTPUT
    SET @v_rowitem_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@v_rowitemcategorycode,@v_rowitemcode,'long')))

		SELECT @v_row_int = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_rowitemcategorycode,@v_rowitemcode),0),
			   @v_row_numeric = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_rowitemcategorycode,@v_rowitemcode),0)
    
    IF @v_row_int = 0 AND @v_row_numeric = 0 BEGIN
    -- No specification values found
      SET @v_message = 'Specification value for row itemcategory ' + @v_rowcategory_desc + '  and for  row item ' +
       @v_rowitem_desc + ' = 0.' 
      SET @o_error_code = -1
      SET @o_error_desc = @v_message
      goto ExitHandler
    END
		  
		SET @v_pos = charindex('.',CONVERT(VARCHAR(40),@v_row_numeric))
		SET @v_precision = ltrim(rtrim(substring(CONVERT(VARCHAR(40),@v_row_numeric), @v_pos+1, (len(@v_row_numeric)+1))))
    IF CONVERT(INT,@v_precision) > 0 BEGIN
			SELECT @v_use_int = 'N'	
      SELECT @v_use_num = 'Y'
		END 
    ELSE BEGIN
			SELECT @v_use_int = 'Y'	
      SELECT @v_use_num = 'N'
		END

    IF @v_row_isrange = 1 BEGIN
		  IF  @v_use_int = 'N' BEGIN
		    SELECT @v_count = count(*)
		      FROM taqprojectscalerowvalues
		     WHERE taqprojectkey = @i_scaleprojectkey
		       AND scaletabkey = @i_scaletabkey
		       AND rowvalue1 <= @v_row_numeric
           AND (rowvalue2 >= @v_row_numeric OR rowvalue2 IS NULL)
		  END
		  ELSE BEGIN
			  SELECT @v_count = count(*)
			    FROM taqprojectscalerowvalues
			   WHERE taqprojectkey = @i_scaleprojectkey
			     AND scaletabkey = @i_scaletabkey
			     AND rowvalue1 <= @v_row_int
           AND (rowvalue2 >= @v_row_int OR rowvalue2 IS NULL)
		  END
    END
    ELSE BEGIN
		  IF  @v_use_int = 'N' BEGIN
		    SELECT @v_count = count(*)
		      FROM taqprojectscalerowvalues
		     WHERE taqprojectkey = @i_scaleprojectkey
		       AND scaletabkey = @i_scaletabkey
		       AND rowvalue1 = @v_row_numeric
		  END
		  ELSE BEGIN
			  SELECT @v_count = count(*)
			    FROM taqprojectscalerowvalues
			   WHERE taqprojectkey = @i_scaleprojectkey
			     AND scaletabkey = @i_scaletabkey
			     AND rowvalue1 = @v_row_int
		  END
    END
    
		IF @v_count = 0 BEGIN
			IF @i_itemdetailcode > 0 BEGIN
				IF  @v_use_int = 'N' BEGIN
					SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
					  '/' + @v_itemdetail_desc + ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
					  @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_numeric) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
				END
        ELSE BEGIN
					SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
					  '/' + @v_itemdetail_desc + ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
					  @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_int) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
				END
			END 
      ELSE BEGIN
				IF  @v_use_int = 'N' BEGIN
					SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
					  ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
					  @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_numeric) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
				END
        ELSE BEGIN
					SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
					  ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
					  @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_int) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
				END
			END

      SET @o_error_code = -1
      SET @o_error_desc = @v_message
			goto ExitHandler
				
		END   -- @v_count = 0
		ELSE BEGIN
      IF @v_row_isrange = 1 BEGIN
			  IF  @v_use_int = 'N' BEGIN
				  SELECT @v_taqscalerowkey = COALESCE(taqscalerowkey,0)
				    FROM taqprojectscalerowvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND rowvalue1 <= @v_row_numeric
				     AND (rowvalue2 >= @v_row_numeric OR rowvalue2 IS NULL)
			  END
			  ELSE BEGIN
				  SELECT @v_taqscalerowkey = COALESCE(taqscalerowkey,0)
				    FROM taqprojectscalerowvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND rowvalue1 <= @v_row_int
				     AND (rowvalue2 >= @v_row_int OR rowvalue2 IS NULL)
			  END
			END
			ELSE BEGIN
			  IF  @v_use_int = 'N' BEGIN
				  SELECT @v_taqscalerowkey = COALESCE(taqscalerowkey,0)
				    FROM taqprojectscalerowvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND rowvalue1 = @v_row_numeric
			  END
			  ELSE BEGIN
				  SELECT @v_taqscalerowkey = COALESCE(taqscalerowkey,0)
				    FROM taqprojectscalerowvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND rowvalue1 = @v_row_int
			  END
      END

      SELECT @v_count_num = COUNT(*)
        FROM taqscaleadminspecitem
       WHERE scaleadminspeckey = @v_columnspeckey

      IF @v_count_num = 0 BEGIN
        SET @v_message = 'No row found in taqscaleadminspecitem for scaleadminspeckey (column) = ' + CONVERT(VARCHAR,@v_columnspeckey) + 
          ' and scaletabkey = ' + CONVERT(VARCHAR,@i_scaletabkey)
         			
        SET @o_error_code = -1
        SET @o_error_desc = @v_message
        goto ExitHandler
      END

      SELECT @v_col_itemcategorycode = COALESCE(itemcategorycode,0),@v_col_itemcode = COALESCE(itemcode,0), @v_col_parametervaluecode = COALESCE(parametervaluecode,0)
        FROM taqscaleadminspecitem
       WHERE scaleadminspeckey = @v_columnspeckey

      IF @v_col_itemcategorycode = 0 BEGIN
        -- no itemcategorycode found
        SET @v_message = 'Itemcategorycode ' + CONVERT(VARCHAR,@v_col_itemcategorycode) + ' not found in taqscaleadminspecitem for ' +
        'scaleadminspeckey (column)= ' + CONVERT(VARCHAR,@v_columnspeckey) + 
        ' and scaletabkey = ' + CONVERT(VARCHAR,@i_scaletabkey)
         			 
        SET @o_error_code = -1
        SET @o_error_desc = @v_message
        goto ExitHandler
      END

      IF @v_col_itemcode = 0 BEGIN
        -- no itemcode found
        SET @v_message = 'Itemcode ' + CONVERT(VARCHAR,@v_col_itemcode) + ' not found in taqscaleadminspecitem for ' +
        'scaleadminspeckey (column) = ' + CONVERT(VARCHAR,@v_columnspeckey) + 
        ' and scaletabkey = ' + CONVERT(VARCHAR,@i_scaletabkey)
          			
        SET @o_error_code = -1
        SET @o_error_desc = @v_message
        goto ExitHandler
      END

      IF @v_col_parametervaluecode = 2 BEGIN
        -- range
        SET @v_col_isrange = 1
      END

--print '@i_taqversionformatyearkey= ' + cast(@i_taqversionformatyearkey as varchar)
--print '@v_col_itemcategorycode= ' + cast(@v_col_itemcategorycode as varchar)
--print '@v_col_itemcode= ' + cast(@v_col_itemcode as varchar)

			SELECT @v_col_int = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_col_itemcategorycode,@v_col_itemcode),0),
			   @v_col_numeric = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_col_itemcategorycode,@v_col_itemcode),0)

      IF (@v_col_int = 0 AND @v_col_numeric = 0) OR (@v_col_int = -1 AND @v_col_numeric = -1) BEGIN
      -- No specification values found
        SET @v_message = 'Specification value for itemcategorycode ' + CONVERT(VARCHAR,@v_col_itemcategorycode) + 
          ' and for itemcode ' + CONVERT(VARCHAR,@v_col_itemcode) + ' = 0 for taqprojectscalecolumnvalues for'  +
          ' scaleadminspeckey (column) = ' + CONVERT(VARCHAR,@v_columnspeckey) + 
          ' and scaletabkey = ' + CONVERT(VARCHAR,@i_scaletabkey)
        SET @o_error_code = -1
        SET @o_error_desc = @v_message
        goto ExitHandler
      END

			SET @v_pos = charindex('.',CONVERT(VARCHAR(40),@v_col_numeric))
			SET @v_precision = ltrim(rtrim(substring(CONVERT(VARCHAR(40),@v_col_numeric), @v_pos+1, (len(@v_col_numeric)+1))))
			IF CONVERT(INT,@v_precision) > 0 BEGIN
				SELECT @v_use_col_int = 'N'	
				SELECT @v_use_col_num = 'Y'
			END 
			ELSE BEGIN
				SELECT @v_use_col_int = 'Y'	
				SELECT @v_use_col_num = 'N'
			END

      IF @v_col_isrange = 1 BEGIN
			  IF  @v_use_col_int = 'N' BEGIN
				  SELECT @v_count2 = count(*)
				    FROM taqprojectscalecolumnvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND columnvalue1 <= @v_col_numeric
				     AND (columnvalue2 >= @v_col_numeric OR columnvalue2 IS NULL)
			  END
			  ELSE BEGIN
  --print '@v_col_int= ' + cast(@v_col_int as varchar)
  --print '@i_scaletabkey ' + cast(@i_scaletabkey as varchar)
  --print '@i_scaleprojectkey ' + cast(@i_scaleprojectkey as varchar)

				  SELECT @v_count2 = count(*)
				    FROM taqprojectscalecolumnvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND columnvalue1 <= @v_col_int
				     AND (columnvalue2 >= @v_col_int OR columnvalue2 IS NULL)
			  END
      END
      ELSE BEGIN
			  IF  @v_use_col_int = 'N' BEGIN
				  SELECT @v_count2 = count(*)
				    FROM taqprojectscalecolumnvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND columnvalue1 = @v_col_numeric
			  END
			  ELSE BEGIN
  --print '@v_col_int= ' + cast(@v_col_int as varchar)
  --print '@i_scaletabkey ' + cast(@i_scaletabkey as varchar)
  --print '@i_scaleprojectkey ' + cast(@i_scaleprojectkey as varchar)

				  SELECT @v_count2 = count(*)
				    FROM taqprojectscalecolumnvalues
				   WHERE taqprojectkey = @i_scaleprojectkey
				     AND scaletabkey = @i_scaletabkey
				     AND columnvalue1 = @v_col_int
			  END
      END
      
      EXEC gentables_longdesc 616, @v_col_itemcategorycode, @v_colcategory_desc OUTPUT
			SET @v_colitem_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@v_col_itemcategorycode,@v_col_itemcode,'long')))
            
			IF @v_count2 = 0 BEGIN  -- No row found on scales for item
				IF @i_itemdetailcode > 0 BEGIN
					IF  @v_use_col_int = 'N' BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  '/' + @v_itemdetail_desc + ' where the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_numeric) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
					ELSE BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  '/' + @v_itemdetail_desc + ' where the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_int) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
				END 
				ELSE BEGIN
					IF  @v_use_col_int = 'N' BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  ' where the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_numeric) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
					ELSE BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  ' where the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_int) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
				END

				INSERT INTO taqversioncostmessages 
					(taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
					VALUES
					(@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
				goto ExitHandler
			END   -- @v_count2 = 0
      ELSE BEGIN  --@v_count2 > 0
        IF @v_col_isrange = 1 BEGIN
				  IF  @v_use_col_int = 'N' BEGIN
					  SELECT @v_taqscalecolkey = taqscalecolumnkey
					    FROM taqprojectscalecolumnvalues
					   WHERE taqprojectkey = @i_scaleprojectkey
					     AND scaletabkey = @i_scaletabkey
				       AND columnvalue1 <= @v_col_numeric
				       AND (columnvalue2 >= @v_col_numeric OR columnvalue2 IS NULL)
				  END
				  ELSE BEGIN
					  SELECT @v_taqscalecolkey = taqscalecolumnkey
					    FROM taqprojectscalecolumnvalues
					   WHERE taqprojectkey = @i_scaleprojectkey
					     AND scaletabkey = @i_scaletabkey
				       AND columnvalue1 <= @v_col_int
				       AND (columnvalue2 >= @v_col_int OR columnvalue2 IS NULL)
				  END
				END
				ELSE BEGIN
				  IF  @v_use_col_int = 'N' BEGIN
					  SELECT @v_taqscalecolkey = taqscalecolumnkey
					    FROM taqprojectscalecolumnvalues
					   WHERE taqprojectkey = @i_scaleprojectkey
					     AND scaletabkey = @i_scaletabkey
				       AND columnvalue1 = @v_col_numeric
				  END
				  ELSE BEGIN
					  SELECT @v_taqscalecolkey = taqscalecolumnkey
					    FROM taqprojectscalecolumnvalues
					   WHERE taqprojectkey = @i_scaleprojectkey
					     AND scaletabkey = @i_scaletabkey
				       AND columnvalue1 = @v_col_int
				  END
				END
			END --@v_count2 > 0
		END   -- @v_count > 0

	END --@v_tabsectiontype = 1 
  ELSE BEGIN
    SET @v_rowcategory_desc = ''
    SET @v_rowitem_desc = ''
    SET @v_colcategory_desc = ''
    SET @v_colitem_desc = ''
		SELECT @v_taqscalerowkey = NULL
    SELECT @v_taqscalecolkey = NULL
	END

--print '@v_taqscalerowkey ' + cast(@v_taqscalerowkey as varchar)
--print '@v_taqscalecolkey ' + cast(@v_taqscalecolkey as varchar)

	IF @i_autoapplyind = 0 BEGIN
		SELECT @v_count3 = COUNT(*)
      FROM taqprojectscaledetails
     WHERE taqprojectkey = @i_scaleprojectkey
		   AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
		   AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
       AND itemcategorycode = @i_itemcategorycode
       AND itemcode = @i_itemcode
       AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)

	END
  ELSE BEGIN
		SELECT @v_count3 = COUNT(*)
      FROM taqprojectscaledetails
     WHERE taqprojectkey = @i_scaleprojectkey
		   AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
		   AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
       AND itemcategorycode = @i_itemcategorycode
       AND itemcode = @i_itemcode
       AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
       AND autoapplyind = 1
	END
	
  IF @v_count3 = 0 BEGIN
			SELECT @v_taqprojecttitle = taqprojecttitle
        FROM taqproject 
       WHERE taqprojectkey = @i_scaleprojectkey

      IF (@v_taqscalerowkey IS NOT NULL AND @v_taqscalecolkey IS NOT NULL) BEGIN
        IF (@i_itemdetailcode > 0  AND @i_itemdetailcode IS NOT NULL) BEGIN
          IF @v_use_col_int = 'N' BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  '/' + @v_itemdetail_desc + ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
				      @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_numeric) + ' and the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_numeric) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
					ELSE BEGIN
						SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  '/' + @v_itemdetail_desc + ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
				      @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_int) +' and the grid column parameter ' + @v_colcategory_desc + '/' +
						  @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_int) + ' on ' + @i_taqprojecttitle + ';cannot generate costs for this item'
					END
        END  -- detailcode > 0
        ELSE BEGIN
			    IF  @v_use_col_int = 'N' BEGIN
				    SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
				      ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
				      @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_numeric) + ' and the grid column parameter ' + + @v_colcategory_desc + '/' +
				      @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_numeric) + ' on ' + @v_taqprojecttitle + ';cannot generate costs for this item'
			    END
			    ELSE BEGIN
				    SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
				      ' where the grid row parameter ' + @v_rowcategory_desc + '/' +
				      @v_rowitem_desc + ' = ' + CONVERT(VARCHAR,@v_row_int) + ' and the grid column parameter ' + @v_colcategory_desc + '/' +
				      @v_colitem_desc + ' = ' + CONVERT(VARCHAR,@v_col_int) + ' on ' + @v_taqprojecttitle + ';cannot generate costs for this item'
			    END
        END  --detailcode = 0


			  INSERT INTO taqversioncostmessages 
				  (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
			  VALUES
				  (@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
        goto ExitHandler
      END

      ELSE BEGIN  --@v_taqscalerowkey IS NULL AND @v_taqscalecolkey IS NULL
         IF (@i_itemdetailcode > 0  AND @i_itemdetailcode IS NOT NULL) BEGIN
            SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
						  '/' + @v_itemdetail_desc + ' on ' + @v_taqprojecttitle + ';cannot generate costs for this item'
         END
         ELSE BEGIN
            SET @v_message = 'No scale item exists for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc +
				      ' on ' + @v_taqprojecttitle + ';cannot generate costs for this item'
			   END

			    INSERT INTO taqversioncostmessages 
				    (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
			    VALUES
				    (@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
          goto ExitHandler
      END
			
	END --@v_count3 = 0

  ELSE BEGIN  --@v_count3 > 0 (Scale values exist for item)
			IF @i_autoapplyind = 0 BEGIN
				SELECT @v_count4 = COUNT(*)
				  FROM taqprojectscaledetails
				 WHERE taqprojectkey = @i_scaleprojectkey
		       AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
		       AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
				   AND itemcategorycode = @i_itemcategorycode
				   AND itemcode = @i_itemcode
				   AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
           AND (thresholdspeccategorycode IS NOT NULL AND thresholdspeccategorycode > 0)

			END
			ELSE BEGIN
				SELECT @v_count4 = COUNT(*)
				  FROM taqprojectscaledetails
				 WHERE taqprojectkey = @i_scaleprojectkey
		       AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
		       AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
				   AND itemcategorycode = @i_itemcategorycode
				   AND itemcode = @i_itemcode
				   AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
				   AND autoapplyind = 1
           AND (thresholdspeccategorycode IS NOT NULL AND thresholdspeccategorycode > 0)
			END

      IF @v_count4 = 0 BEGIN -- all  rows found have NULL thresholdspeccategorycode -save all rows to temporary structure
         IF @i_autoapplyind = 0 BEGIN
					DECLARE taqprojectscaledetails_cur1 CURSOR FOR
						SELECT taqdetailscalekey,calculationtypecode
						  FROM taqprojectscaledetails
						 WHERE taqprojectkey = @i_scaleprojectkey
						   AND coalesce(rowkey,0) = coalesce(@v_taqscalerowkey,0)
						   AND coalesce(columnkey,0) = coalesce(@v_taqscalecolkey,0)
						   AND itemcategorycode = @i_itemcategorycode
						   AND itemcode = @i_itemcode
						   AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						   AND (thresholdspeccategorycode IS NULL OR thresholdspeccategorycode = 0)
				END
        ELSE BEGIN
					DECLARE taqprojectscaledetails_cur1 CURSOR FOR
						SELECT taqdetailscalekey,calculationtypecode
						  FROM taqprojectscaledetails
						 WHERE taqprojectkey = @i_scaleprojectkey
						   AND coalesce(rowkey,0) = coalesce(@v_taqscalerowkey,0)
						   AND coalesce(columnkey,0) = coalesce(@v_taqscalecolkey,0)
						   AND itemcategorycode = @i_itemcategorycode
               AND autoapplyind = 1
						   AND itemcode = @i_itemcode
						   AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						   AND (thresholdspeccategorycode IS NULL OR thresholdspeccategorycode = 0)
				END

        OPEN taqprojectscaledetails_cur1 

				FETCH taqprojectscaledetails_cur1 INTO @v_taqdetailscalekey,@v_calculationtypecode

				WHILE (@@FETCH_STATUS=0)
				BEGIN
--print 'scale detail1'
--print '@i_scaleprojectkey = ' + cast(@i_scaleprojectkey as varchar)
--print '@i_autoapplyind = ' + cast(@i_autoapplyind as varchar)
--print '@v_taqscalerowkey = ' + cast(@v_taqscalerowkey as varchar)
--print '@v_taqscalecolkey = ' + cast(@v_taqscalecolkey as varchar)
--print '@i_itemcategorycode = ' + cast(@i_itemcategorycode as varchar)
--print '@i_itemcode = ' + cast(@i_itemcode as varchar)
--print '@i_itemdetailcode = ' + cast(@i_itemdetailcode as varchar)
--print '@v_taqdetailscalekey = ' + cast(@v_taqdetailscalekey as varchar)
					INSERT INTO #tmp_structure 
						(taqdetailscalekey,taqversionspecitemkey,autoapplyind,calculationtypecode,itemcategorycode,itemcode)
						VALUES (@v_taqdetailscalekey,@i_taqversionspecitemkey,@i_autoapplyind,@v_calculationtypecode,
                           @i_itemcategorycode,@i_itemcode)

					FETCH taqprojectscaledetails_cur1 INTO @v_taqdetailscalekey,@v_calculationtypecode
				END

				CLOSE taqprojectscaledetails_cur1
				DEALLOCATE taqprojectscaledetails_cur1
			END -- @v_count4 = 0 (all rows have NULL for thresholdspeccategorycode)

      ELSE BEGIN  -- some or all rows have value for thresholdspeccategorycode
        IF @v_count4 = 1 BEGIN
           IF @i_autoapplyind = 0 BEGIN
             SELECT @v_saved_thresholdspeccategorycode=thresholdspeccategorycode,@v_saved_thresholdspecitemcode=thresholdspecitemcode
				       FROM taqprojectscaledetails
						  WHERE taqprojectkey = @i_scaleprojectkey
						    AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					      AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
					      AND itemcategorycode = @i_itemcategorycode
					      AND itemcode = @i_itemcode
					      AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
					      AND (thresholdspeccategorycode IS NOT NULL AND thresholdspeccategorycode > 0)
          END
          ELSE BEGIN
              SELECT @v_saved_thresholdspeccategorycode=thresholdspeccategorycode,@v_saved_thresholdspecitemcode=thresholdspecitemcode
				       FROM taqprojectscaledetails
						  WHERE taqprojectkey = @i_scaleprojectkey
						    AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					      AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
					      AND itemcategorycode = @i_itemcategorycode
					      AND itemcode = @i_itemcode
					      AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
					      AND (thresholdspeccategorycode IS NOT NULL AND thresholdspeccategorycode > 0)
           END
        END
        ELSE BEGIN  --@v_count4 > 1 
          IF @i_autoapplyind = 0 BEGIN
					  DECLARE taqprojectscaledetails_cur2 CURSOR FOR
						  SELECT taqdetailscalekey,calculationtypecode,thresholdspeccategorycode,thresholdspecitemcode
						    FROM taqprojectscaledetails
						   WHERE taqprojectkey = @i_scaleprojectkey
						      AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					        AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
                 AND itemcategorycode = @i_itemcategorycode
						     AND itemcode = @i_itemcode
						     AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						     AND (thresholdspeccategorycode IS NOT NULL AND thresholdspeccategorycode > 0)
				  END
          ELSE BEGIN
					  DECLARE taqprojectscaledetails_cur2 CURSOR FOR
						  SELECT taqdetailscalekey,calculationtypecode,thresholdspeccategorycode,thresholdspecitemcode
						    FROM taqprojectscaledetails
						   WHERE taqprojectkey = @i_scaleprojectkey
						      AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					        AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
                 AND autoapplyind = 1
						     AND itemcategorycode = @i_itemcategorycode
						     AND itemcode = @i_itemcode
						     AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						     AND (thresholdspeccategorycode IS NOT NULL AND  thresholdspeccategorycode > 0)
				  END

          -- Determine if all rows found have the same thresholdspeccategorycode and thresholdspecitemcode
          OPEN taqprojectscaledetails_cur2 

				  FETCH taqprojectscaledetails_cur2 INTO @v_taqdetailscalekey,@v_calculationtypecode,
            @v_thresholdspeccategorycode,@v_thresholdspecitemcode

          IF @@FETCH_STATUS=0 BEGIN
            SELECT @v_saved_thresholdspeccategorycode = @v_thresholdspeccategorycode
            SELECT @v_saved_thresholdspecitemcode = @v_thresholdspecitemcode

            IF @i_autoapplyind = 0 BEGIN
              SELECT @v_count5 = count(*)
                FROM taqprojectscaledetails
						   WHERE taqprojectkey = @i_scaleprojectkey
						      AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					        AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
                 AND itemcategorycode = @i_itemcategorycode
						     AND itemcode = @i_itemcode
						     AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						     AND (thresholdspeccategorycode = @v_saved_thresholdspeccategorycode AND thresholdspecitemcode = @v_saved_thresholdspecitemcode )
				    END
            ELSE BEGIN
					      SELECT @v_count5 = count(*)
						      FROM taqprojectscaledetails
						     WHERE taqprojectkey = @i_scaleprojectkey
						        AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					          AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
                   AND autoapplyind = 1
						       AND itemcategorycode = @i_itemcategorycode
						       AND itemcode = @i_itemcode
						       AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
						       AND (thresholdspeccategorycode = @v_saved_thresholdspeccategorycode AND thresholdspecitemcode = @v_saved_thresholdspecitemcode )
				    END

            IF @v_count4 = @v_count5 BEGIN
              SELECT @v_values_same = 'Y'
            END
            ELSE BEGIN
              SELECT @v_values_same = 'N'
            END
          END

				  CLOSE taqprojectscaledetails_cur2
				  DEALLOCATE taqprojectscaledetails_cur2
        END --@v_count4 > 1

        --All rows found have the same thresholdspeccategorycode and thresholdspecitemcode
        IF (@v_count4 = 1) OR (@v_count4 > 1 AND @v_values_same = 'Y') BEGIN  
          SELECT @v_thresholdvalue_int = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_saved_thresholdspeccategorycode,@v_saved_thresholdspecitemcode),0),
			      @v_thresholdvalue_numeric = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_saved_thresholdspeccategorycode,@v_saved_thresholdspecitemcode),0)
        
          -- The threshold value is null on all rows
          IF (@v_thresholdvalue_int IS NULL OR @v_thresholdvalue_int = 0) AND 
             (@v_thresholdvalue_numeric IS NULL AND @v_thresholdvalue_numeric = 0) BEGIN

              EXEC gentables_longdesc 616, @v_saved_thresholdspeccategorycode, @v_thresholdcategory_desc OUTPUT
              SET @v_thresholdcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@v_saved_thresholdspeccategorycode,@v_saved_thresholdspecitemcode,'long')))

              IF (@i_itemdetailcode > 0  AND @i_itemdetailcode IS NOT NULL) BEGIN
						    SET @v_message = 'No Item exists for ' + @v_thresholdcategory_desc + ',' + @v_thresholdcode_desc 
                  + ' which is required as a threshold value for ' +
                  + @v_itemcategory_desc + '/' + @v_itemcode_desc  + '/' + @v_itemdetail_desc + ' on' 
                  + @v_taqprojecttitle + ';cannot generate costs for this item'
              END 
				      ELSE BEGIN
    				    SET @v_message = 'No Item exists for ' + @v_thresholdcategory_desc + ',' + @v_thresholdcode_desc 
                  + ' which is required as a threshold value for ' + @v_itemcategory_desc + '/' + @v_itemcode_desc + ' on' 
                  + @v_taqprojecttitle + ';cannot generate costs for this item'
    					
				      END
              INSERT INTO taqversioncostmessages 
				        (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
			        VALUES
				        (@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
              goto ExitHandler
          END 

          ELSE BEGIN --(@v_count4 = 1) OR (@v_count4 > 1 AND @v_values_same = 'Y') AND threshold value is NOT NULL 
      
              IF @i_autoapplyind = 0 BEGIN
					      DECLARE taqprojectscaledetails_cur3 CURSOR FOR
						      SELECT taqdetailscalekey,calculationtypecode,thresholdspeccategorycode,thresholdspecitemcode,
                         thresholdvalue1,thresholdvalue2
                    FROM taqprojectscaledetails
						       WHERE taqprojectkey = @i_scaleprojectkey
						        AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					          AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
						         AND itemcategorycode = @i_itemcategorycode
						         AND itemcode = @i_itemcode
						         AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
					    END
              ELSE BEGIN
					      DECLARE taqprojectscaledetails_cur3 CURSOR FOR
						      SELECT taqdetailscalekey,calculationtypecode,thresholdspeccategorycode,thresholdspecitemcode,
                         thresholdvalue1,thresholdvalue2
						        FROM taqprojectscaledetails
						       WHERE taqprojectkey = @i_scaleprojectkey
						        AND COALESCE(rowkey,0) = COALESCE(@v_taqscalerowkey,0)
					          AND COALESCE(columnkey,0) = COALESCE(@v_taqscalecolkey,0)
                     AND autoapplyind = 1
						         AND itemcategorycode = @i_itemcategorycode
						         AND itemcode = @i_itemcode
						         AND (itemdetailcode = @i_itemdetailcode OR itemdetailcode IS NULL OR itemdetailcode = 0)
					    END

              OPEN taqprojectscaledetails_cur3 

				      FETCH taqprojectscaledetails_cur3 INTO @v_taqdetailscalekey,@v_calculationtypecode,
                @v_thresholdspeccategorycode,@v_thresholdspecitemcode,@v_thresholdvalue1,@v_thresholdvalue2

              WHILE (@@FETCH_STATUS=0)
				      BEGIN
                SELECT @v_thresholdvalue_int = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_thresholdspeccategorycode,@v_thresholdspecitemcode),0),
			          @v_thresholdvalue_numeric = COALESCE(dbo.qscale_find_specification_value(@i_taqversionformatyearkey,@v_thresholdspeccategorycode,@v_thresholdspecitemcode),0)

--PRINT '@v_taqdetailscalekey=' + convert(varchar, @v_taqdetailscalekey)
--PRINT '@v_calculationtypecode=' + convert(varchar, @v_calculationtypecode)
--PRINT '@v_thresholdspeccategorycode=' + convert(varchar, @v_thresholdspeccategorycode)
--PRINT '@v_thresholdspecitemcode=' + convert(varchar, @v_thresholdspecitemcode)
--PRINT '@v_thresholdvalue1=' + convert(varchar, @v_thresholdvalue1)
--PRINT '@v_thresholdvalue2=' + convert(varchar, @v_thresholdvalue2)
--PRINT '@v_thresholdvalue_int=' + convert(Varchar, @v_thresholdvalue_int)
--PRINT '@v_thresholdvalue_numeric=' + convert(varchar, @v_thresholdvalue_numeric)

                IF @v_col_int = 0 AND @v_col_numeric = 0 BEGIN
                -- No specification values found
                  SET @v_message = 'Specification (threshold) values for itemcategorycode ' + CONVERT(VARCHAR,@v_thresholdspeccategorycode) + '  and for itemcode ' +
                   CONVERT(VARCHAR,@v_thresholdspecitemcode) + ' not found.' 
                  SET @o_error_code = -1
                  SET @o_error_desc = @v_message
                  goto ExitHandler
                END

                SET @v_pos = charindex('.',CONVERT(VARCHAR(40),@v_thresholdvalue_numeric))
		        SET @v_precision = ltrim(rtrim(substring(CONVERT(VARCHAR(40),@v_thresholdvalue_numeric), @v_pos+1, (len(@v_thresholdvalue_numeric)+1))))

                IF CONVERT(INT,@v_precision) > 0 BEGIN
			            SELECT @v_use_threshold_int = 'N'	
                  SELECT @v_use_threshold_num = 'Y'
		            END 
                ELSE BEGIN
			            SELECT @v_use_threshold_int = 'Y'	
                  SELECT @v_use_threshold_num = 'N'
		            END

                IF @v_use_threshold_int = 'Y' BEGIN
                   IF @v_thresholdvalue_int >= @v_thresholdvalue1 AND @v_thresholdvalue_int <= @v_thresholdvalue2 BEGIN
--print 'scale detail2'
--print '@i_scaleprojectkey + ' + cast(@i_scaleprojectkey as varchar)
--print '@i_autoapplyind + ' + cast(@i_autoapplyind as varchar)
--print '@v_taqscalerowkey + ' + cast(@v_taqscalerowkey as varchar)
--print '@v_taqscalecolkey + ' + cast(@v_taqscalecolkey as varchar)
--print '@i_itemcategorycode + ' + cast(@i_itemcategorycode as varchar)
--print '@i_itemcode + ' + cast(@i_itemcode as varchar)
--print '@i_itemdetailcode + ' + cast(@i_itemdetailcode as varchar)
                      INSERT INTO #tmp_structure 
						          (taqdetailscalekey,taqversionspecitemkey,autoapplyind,calculationtypecode,itemcategorycode,itemcode)
						          VALUES (@v_taqdetailscalekey,@i_taqversionspecitemkey,@i_autoapplyind,@v_calculationtypecode,
                                     @i_itemcategorycode,@i_itemcode)

                    IF @v_threshold_match = 'N' SELECT @v_threshold_match = 'Y'
                   END
                END
                ELSE BEGIN
                   IF @v_thresholdvalue_numeric >= @v_thresholdvalue1 AND @v_thresholdvalue_numeric <= @v_thresholdvalue2 BEGIN
--print 'scale detail3'
--print '@i_scaleprojectkey + ' + cast(@i_scaleprojectkey as varchar)
--print '@i_autoapplyind + ' + cast(@i_autoapplyind as varchar)
--print '@v_taqscalerowkey + ' + cast(@v_taqscalerowkey as varchar)
--print '@v_taqscalecolkey + ' + cast(@v_taqscalecolkey as varchar)
--print '@i_itemcategorycode + ' + cast(@i_itemcategorycode as varchar)
--print '@i_itemcode + ' + cast(@i_itemcode as varchar)
--print '@i_itemdetailcode + ' + cast(@i_itemdetailcode as varchar)
                      INSERT INTO #tmp_structure 
						          (taqdetailscalekey,taqversionspecitemkey,autoapplyind,calculationtypecode,itemcategorycode,itemcode)
						          VALUES (@v_taqdetailscalekey,@i_taqversionspecitemkey,@i_autoapplyind,@v_calculationtypecode,
                                     @i_itemcategorycode,@i_itemcode)

                      IF @v_threshold_match = 'N' SELECT @v_threshold_match = 'Y'
                   END
                END

                 FETCH taqprojectscaledetails_cur3 INTO @v_taqdetailscalekey,@v_calculationtypecode,
                   @v_thresholdspeccategorycode,@v_thresholdspecitemcode,@v_thresholdvalue1,@v_thresholdvalue2
   			      END

				      CLOSE taqprojectscaledetails_cur3
				      DEALLOCATE taqprojectscaledetails_cur3

              IF @v_threshold_match = 'N' BEGIN   -- no rows found that have threshold match
                  EXEC gentables_longdesc 616, @v_saved_thresholdspeccategorycode, @v_thresholdcategory_desc OUTPUT
                  SET @v_thresholdcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(616,@v_saved_thresholdspeccategorycode,@v_saved_thresholdspecitemcode,'long')))

                  IF (@i_itemdetailcode > 0  AND @i_itemdetailcode IS NOT NULL) BEGIN
                    IF @v_use_threshold_int = 'Y' BEGIN
						          SET @v_message = 'No match found on ' + @v_taqprojecttitle + ' for ' + 
                        + @v_itemcategory_desc + '/' + @v_itemcode_desc  + '/' + @v_itemdetail_desc + ' that matches the threshold value = ' 
                        + CONVERT(VARCHAR,@v_thresholdvalue_int) + ';cannot generate costs for this item'
                    END
                    ELSE BEGIN
                      SET @v_message = 'No match found on ' + @v_taqprojecttitle + ' for ' + 
                        + @v_itemcategory_desc + '/' + @v_itemcode_desc  + '/' + @v_itemdetail_desc + ' that matches the threshold value = ' 
                        + CONVERT(VARCHAR,@v_thresholdvalue_numeric) + ';cannot generate costs for this item'
                    END
                  END 
				          ELSE BEGIN
    				        IF @v_use_threshold_int = 'Y' BEGIN
						          SET @v_message = 'No match found on ' + @v_taqprojecttitle + ' for ' + 
                        + @v_itemcategory_desc + '/' + @v_itemcode_desc  + ' that matches the threshold value = ' 
                        + CONVERT(VARCHAR,@v_thresholdvalue_int) + ';cannot generate costs for this item'
                    END
                    ELSE BEGIN
                      SET @v_message = 'No match found on ' + @v_taqprojecttitle + ' for ' + 
                        + @v_itemcategory_desc + '/' + @v_itemcode_desc  + ' that matches the threshold value = ' 
                        + CONVERT(VARCHAR,@v_thresholdvalue_numeric) + ';cannot generate costs for this item'
                    END
        					END
                  INSERT INTO taqversioncostmessages 
				            (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
			            VALUES
				            (@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
                  goto ExitHandler
               END -- no threshold match
          END  --(@v_count4 = 1) OR (@v_count4 > 1 AND @v_values_same = 'Y') AND threshold value is NOT NULL    
        END --(@v_count4 = 1) OR (@v_count4 > 1 AND @v_values_same = 'Y')

        ELSE BEGIN  --@v_count4 > 1 AND @v_values_same = 'N' (thresholdspeccategorycode and thresholdspecitemcode are NOT the same for all rows)
          IF (@i_itemdetailcode > 0  AND @i_itemdetailcode IS NOT NULL) BEGIN
             SET @v_message = 'Threshold type for'  + 
                 + @v_itemcategory_desc + '/' + @v_itemcode_desc  + '/' + @v_itemdetail_desc + ' on ' + @v_taqprojecttitle 
                 + ' are not consistent;cannot generate costs for this item ' 
          END 
				  ELSE BEGIN
    			    SET @v_message = 'Threshold type for'  + 
                 + @v_itemcategory_desc + '/' + @v_itemcode_desc  + ' on ' + @v_taqprojecttitle 
                 + ' are not consistent;cannot generate costs for this item ' 
        	END
          INSERT INTO taqversioncostmessages 
				     (taqversionformatyearkey, message, messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
			    VALUES
				     (@i_taqversionformatyearkey, @v_message, @i_messagetypecode, NULL, NULL,getdate(), 'QSIADMIN', @i_processtype)
           goto ExitHandler
        END  --@v_count4 > 1 AND @v_values_same = 'N'
      END  -- @v_count4 > 0 (some or all rows have value for thresholdspeccategorycode)
		END -- @v_count3 > 0

ExitHandler:

  IF CURSOR_STATUS('local', 'taqprojectscaledetails_cur1') >= 0
  BEGIN
    CLOSE taqprojectscaledetails_cur1
    DEALLOCATE taqprojectscaledetails_cur1
  END

  IF CURSOR_STATUS('local', 'taqprojectscaledetails_cur2') >= 0
  BEGIN
    CLOSE taqprojectscaledetails_cur2
    DEALLOCATE taqprojectscaledetails_cur2
  END

  IF CURSOR_STATUS('local', 'taqprojectscaledetails_cur3') >= 0
  BEGIN
    CLOSE taqprojectscaledetails_cur3
    DEALLOCATE taqprojectscaledetails_cur3
  END

END
GO

GRANT EXEC ON qscale_get_scale_detail TO PUBLIC
GO