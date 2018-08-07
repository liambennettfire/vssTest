if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_price_validation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_price_validation
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_price_validation
 (@i_bookkey     integer,
  @i_pricevalue  float,
  @i_pricevalidationgroup integer,
  @i_pricetypecode	integer,
  @i_currencycode integer,
  @o_error_code   integer       output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_price_validation
**  Desc: This validates the prices
**
**    Auth: Kusum Basra
**    Date: 21 July 2011
*******************************************************************************/

  DECLARE @v_error_code INT
  DECLARE @v_error_desc varchar(2000)
  DECLARE @v_error_msg varchar(200)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_count	INT
  DECLARE @v_count_rows INT
  DECLARE @v_pricevalidationgroupcode	INT
  DECLARE @v_clientdefaultvalue 	INT
  DECLARE @v_budget_price float
  DECLARE @v_final_price float
  DECLARE @v_pricetypecode	INT
  DECLARE @v_currencytypecode	INT
  DECLARE @v_pricetypedesc varchar(40)
  DECLARE @v_currencytypedesc  varchar(40)
  DECLARE @v_gen2ind 	INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_error_desc = ''
     
  IF @i_bookkey > 0 BEGIN
    SELECT @v_count = count(*)
    FROM bookdetail 
    WHERE bookkey = @i_bookkey

    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to set price validation group on bookdetail: bookkey = ' + cast(@i_bookkey AS VARCHAR)
      RETURN
    END 

    IF @v_count > 0 BEGIN
      SELECT @v_pricevalidationgroupcode = pricevalidationgroupcode
      FROM bookdetail 
      WHERE bookkey = @i_bookkey

      IF @v_pricevalidationgroupcode IS NULL OR @v_pricevalidationgroupcode = 0
      BEGIN
        EXEC qtitle_set_price_validation_group @i_bookkey,@v_error_code OUTPUT,@v_error_desc OUTPUT
        IF @v_error_code = -1 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = @v_error_desc
          RETURN
        END 
      END

      SELECT @v_pricevalidationgroupcode = pricevalidationgroupcode
      FROM bookdetail 
      WHERE bookkey = @i_bookkey
      
      IF @v_pricevalidationgroupcode = 1 BEGIN  /* no error */
        RETURN
      END
      ELSE IF @v_pricevalidationgroupcode = 2 OR @v_pricevalidationgroupcode = 3
      BEGIN
        SET @v_count_rows = 0
        SET @v_error_desc = ' '

        DECLARE cur_related_bookprice_rows CURSOR FOR
          SELECT p.budgetprice, p.finalprice, p.pricetypecode, p.currencytypecode, g1.gen2ind
          FROM bookprice p
            LEFT OUTER JOIN gentables g1 ON p.pricetypecode = g1.datacode AND g1.tableid = 306
          WHERE bookkey = @i_bookkey

        OPEN cur_related_bookprice_rows
		
			  FETCH NEXT FROM cur_related_bookprice_rows 
			  INTO @v_budget_price, @v_final_price, @v_pricetypecode, @v_currencytypecode, @v_gen2ind	
	
        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          IF @v_budget_price = 0 OR @v_final_price = 0
          BEGIN
            IF @v_pricevalidationgroupcode = 2 OR (@v_pricevalidationgroupcode = 3 AND @v_gen2ind = 0)
            BEGIN
              SET @v_count_rows = @v_count_rows + 1
			  SET @v_error_msg = ''
              EXEC gentables_longdesc 306,@v_pricetypecode,@v_pricetypedesc OUTPUT
              EXEC gentables_longdesc 122,@v_currencytypecode,@v_currencytypedesc OUTPUT

              SET @v_error_msg = @v_pricetypedesc + '/' + @v_currencytypedesc + ' cannot have zero price.'

              IF @v_error_desc = ' '
                SET @v_error_desc = @v_error_msg
              ELSE
                SET @v_error_desc = @v_error_desc +  ', ' + @v_error_msg      			
            END
          END
                    
			    FETCH NEXT FROM cur_related_bookprice_rows 
			    INTO @v_budget_price, @v_final_price, @v_pricetypecode, @v_currencytypecode, @v_gen2ind	
        END
        
        IF @v_count_rows > 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = @v_error_desc + '.'
          CLOSE cur_related_bookprice_rows 
          DEALLOCATE cur_related_bookprice_rows
          RETURN
        END
		
        CLOSE cur_related_bookprice_rows 
        DEALLOCATE cur_related_bookprice_rows
        
      END --@v_pricevalidationgroupcode = 2 OR @v_pricevalidationgroupcode = 3
    END --@v_count > 0
  END --@i_bookkey > 0
   
  ELSE  --bookkey not passed in
  BEGIN
    IF @i_pricevalidationgroup = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Price Validation Group required. Unable to validate prices for bookkey = ' + cast(@i_bookkey AS VARCHAR)
      RETURN
    END
    
    IF @i_pricevalidationgroup = 1 BEGIN  /* no error */
      RETURN 
    END
       
    IF @i_pricevalidationgroup = 2 AND @i_pricevalue = 0 BEGIN
      EXEC gentables_longdesc 306,@i_pricetypecode,@v_pricetypedesc OUTPUT
      EXEC gentables_longdesc 122,@i_currencycode,@v_currencytypedesc OUTPUT
      
      SET @o_error_code = -1
      SET @o_error_desc = @v_pricetypedesc + '/' + @v_currencytypedesc + ' cannot have zero price.'
      RETURN
    END
    
    IF @i_pricevalidationgroup = 3 BEGIN
      IF @i_pricetypecode = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Price Type required for validation. Unable to validate prices for bookkey = ' + cast(@i_bookkey AS VARCHAR)
        RETURN
      END
    
      IF @i_pricevalue = 0 BEGIN
        SELECT @v_gen2ind = gen2ind, @v_pricetypedesc=datadesc
        FROM gentables
        WHERE tableid = 306 AND datacode = @i_pricetypecode

        IF @v_gen2ind = 0 OR @v_gen2ind IS NULL BEGIN
          EXEC gentables_longdesc 122,@i_currencycode,@v_currencytypedesc OUTPUT
          
          SET @o_error_code = -1
          SET @o_error_desc = @v_pricetypedesc + '/' + @v_currencytypedesc + ' cannot have zero price.'
          RETURN
        END
      END
    END
    
  END --bookkey not passed in
 
GO

GRANT EXEC ON qtitle_price_validation TO PUBLIC
GO
