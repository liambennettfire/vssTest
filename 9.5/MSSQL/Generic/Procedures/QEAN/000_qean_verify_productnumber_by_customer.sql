IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_verify_productnumber_by_customer')
BEGIN
  DROP PROCEDURE qean_verify_productnumber_by_customer
END
GO

CREATE PROCEDURE qean_verify_productnumber_by_customer (
  @i_bookkey          INT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)
AS

/**********************************************************************************
**  Name: qean_verify_productnumber_by_customer
**  Desc: Procedure will be called from any place that currently validates the
**        ISBN-10 or EAN as the required product id in place of current ISBN-10
**        or EAN validation.
**
**  @o_error_code 0   product id to be validated by customerkey 
**  @o_error_code -1  ERROR
**
**  Auth: Kusum Basra
**  Date: 27 August 2012
**********************************************************************************/

BEGIN

  DECLARE 
    @v_gentext1 VARCHAR(255),
    @v_datadesc VARCHAR(255),
    @v_productidvalue VARCHAR(30),
    @v_numericdesc1 INT,
    @v_productidcode  INT,
    @v_elocustomerkey INT,
    @v_qsicode  INT,
    @o_new_string VARCHAR(25),
    @v_columnname NVARCHAR(100),
    @SQLString_var NVARCHAR(4000),
    @SQLparams_var NVARCHAR(4000),
    @error_var INT,
    @rowcount_var INT,
    @v_rowcount INT,
    @o_error_desc_validation VARCHAR(2000)
  
  SET @v_columnname = ''

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_error_desc_validation = ''

  IF @i_bookkey IS NULL OR @i_bookkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid bookkey.'
    SET @o_error_code = -1
    RETURN  
  END

  SELECT @v_elocustomerkey = elocustomerkey
    FROM book
   WHERE bookkey = @i_bookkey

  IF @v_elocustomerkey IS NULL OR @v_elocustomerkey <= 0 BEGIN
    SET @o_error_desc = 'Elocustomerkey missing on book for bookkey = ' + CONVERT(VARCHAR,@i_bookkey) + ' .'
    SET @o_error_code = -1
    RETURN
  END

  DECLARE customerreqproductids_cur CURSOR FOR
    SELECT productidcode
      FROM customerreqproductids
     WHERE customerkey = @v_elocustomerkey 
     ORDER BY productidcode

  OPEN customerreqproductids_cur

  FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode

  WHILE (@@FETCH_STATUS= 0) 
  BEGIN
    SELECT @v_numericdesc1 = g.numericdesc1 ,@v_qsicode = g.qsicode,@v_gentext1 = e.gentext1,
            @v_datadesc = g.datadesc
      FROM gentables g, gentables_ext e
     WHERE g.tableid = 551
       AND g.tableid = e.tableid
       AND g.datacode = e.datacode
       AND g.datacode = @v_productidcode

    IF @v_gentext1 IS NULL OR @v_gentext1 = '' BEGIN
      SET @o_error_code = -1
      IF @o_error_desc <> '' BEGIN
        SET @o_error_desc = @o_error_desc + '<newline>' + @v_datadesc + ': Column on database for ' + @v_datadesc + ' is not defined in User Tables.'
      END
      ELSE BEGIN
        SET @o_error_desc = @v_datadesc + ':Column on database for ' + @v_datadesc + ' is not defined in User Tables.'
      END
      FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
      CONTINUE
    END

    IF @v_numericdesc1 IS NULL OR @v_numericdesc1 < 0 BEGIN
      SET @o_error_code = -1
      IF @o_error_desc <> '' BEGIN
        SET @o_error_desc = @o_error_desc + '<newline>' + @v_datadesc + ':Numeric validation type for ' + @v_datadesc + ' is not defined in User Tables.'
      END
      ELSE BEGIN
         SET @o_error_desc = @v_datadesc + ':Numeric validation type for ' + @v_datadesc + ' is not defined in User Tables.'
      END
      FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
      CONTINUE
    END

    SELECT @v_columnname = @v_gentext1    
    
    SET @SQLString_var = N'SELECT @p_rowcount = COUNT(*) FROM isbn 
      WHERE bookkey <> ' + CONVERT(VARCHAR, @i_bookkey) 

    EXECUTE sp_executesql @SQLString_var, 
      N'@p_rowcount INT OUTPUT',@v_rowcount OUTPUT

    IF @v_rowcount = 0
    BEGIN
      SET @o_error_code = -1
      IF @o_error_desc <> '' BEGIN
        SET @o_error_desc = @o_error_desc + '<newline>' + @v_datadesc + ': missing from isbn table.'
      END
      ELSE BEGIN
        SET @o_error_desc = @v_datadesc + ': missing from isbn table.'
      END
      FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
      CONTINUE
    END  
      
    SET @SQLString_var = N'SELECT @v_productidvalue = ' + @v_columnname + ' FROM isbn' +
                           N' WHERE bookkey = ' + cast(@i_bookkey AS NVARCHAR)

--- print '@SQLString_var= ' + @SQLString_var

      SET @SQLparams_var = N'@v_productidvalue VARCHAR(19) OUTPUT' 
      EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_productidvalue OUTPUT

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        IF @o_error_desc <> '' BEGIN
          SET @o_error_desc = @o_error_desc + '<newline>' + @v_datadesc + ':Unable to retrieve ' + @v_columnname + ' from isbn (' + cast(@error_var AS VARCHAR) + ').'
        END
        ELSE BEGIN
           SET @o_error_desc = @v_datadesc + ':Unable to retrieve ' + @v_columnname + ' from isbn (' + cast(@error_var AS VARCHAR) + ').'
        END
        FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
        CONTINUE
      END

    IF @v_productidvalue IS NULL OR @v_productidvalue = '' BEGIN
      SET @o_error_code = -1
      IF @o_error_desc <> '' BEGIN
         SET @o_error_desc = @o_error_desc + '<newline>' + @v_datadesc + ':' + @v_columnname + ' missing.'
      END
      ELSE BEGIN
         SET @o_error_desc = @v_datadesc + ':' + @v_columnname + ' missing.'
      END
      FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
      CONTINUE
    END

    exec qean_productid_validation @v_qsicode, @v_productidvalue, @v_numericdesc1, 0, @i_bookkey, @o_new_string output, @o_error_code output, @o_error_desc_validation output

    IF @o_error_desc_validation <> '' BEGIN
      -- do not set @o_error_code here - use values returned by qean_productid_validation
      -- for customiized warning messages 
      IF @o_error_desc <> '' BEGIN
        SET @o_error_desc = @o_error_desc + '<newline>' + @v_columnname + ':' + @o_error_desc_validation
      END
      ELSE BEGIN
        SET @o_error_desc = @v_columnname + ':' + @o_error_desc_validation
      END
      FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
      CONTINUE
    END
 
    FETCH NEXT FROM customerreqproductids_cur INTO @v_productidcode
  END
  CLOSE customerreqproductids_cur
  DEALLOCATE customerreqproductids_cur

END
GO

GRANT EXEC ON dbo.qean_verify_productnumber_by_customer TO PUBLIC
GO

