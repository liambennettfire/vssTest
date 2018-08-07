if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_productnumber') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_get_productnumber
GO

CREATE FUNCTION qutl_get_productnumber
    ( @i_productnumlockey as integer,
      @i_bookkey as integer) 

RETURNS varchar(50)

/******************************************************************************
**  File: 
**  Name: qutl_get_productnumber
**  Desc: This function returns the productnumber based on the 
**        productnumlockey and bookkey.
**
**    Auth: Alan Katzen
**    Date: 21 September 2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    02/10/2016  UK			 Case 36206
*******************************************************************************/

BEGIN 
  DECLARE @i_count            INT,
          @error_var          INT,
          @rowcount_var       INT,
          @tablename_var      VARCHAR(50),
          @columnname_var     VARCHAR(50),
          @productnumber_var  VARCHAR(50),
          @v_quote            VARCHAR(2),
          @v_sqlselect       VARCHAR(2000),
          @v_sqlwhere        VARCHAR(2000),
          @v_sqlstring        NVARCHAR(4000)
      
  SET @v_quote = ''''      

  SET @productnumber_var = ''

  SELECT @i_count = count(*)
    FROM productnumlocation 
   WHERE productnumlockey = @i_productnumlockey 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 or @i_count <= 0 BEGIN
    SET @productnumber_var = ''
    RETURN @productnumber_var 
  END 

  SELECT @tablename_var=lower(tablename),@columnname_var=lower(columnname)
    FROM productnumlocation 
   WHERE productnumlockey = @i_productnumlockey 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @productnumber_var = ''
    RETURN @productnumber_var 
  END 

--  SELECT @v_isbn=upper(isbn),@v_ean=upper(ean),@v_upc=upper(upc),@v_gtin=upper(gtin), 
--         @v_itemnumber=upper(itemnumber),@v_lccn=upper(lccn),@v_dsmarc=upper(dsmarc)
--    FROM isbn 
--   WHERE bookkey = @i_bookkey 

  SELECT @productnumber_var = 
           CASE 
             WHEN @columnname_var = 'isbn' THEN isbn
             WHEN @columnname_var = 'isbn10' THEN isbn10
             WHEN @columnname_var = 'ean' THEN ean
			 WHEN @columnname_var = 'ean13' THEN ean13
             WHEN @columnname_var = 'upc' THEN upc
             WHEN @columnname_var = 'gtin' THEN gtin
             WHEN @columnname_var = 'gtin14' THEN gtin14
             WHEN @columnname_var = 'itemnumber' THEN itemnumber
             WHEN @columnname_var = 'lccn' THEN lccn
             WHEN @columnname_var = 'dsmarc' THEN dsmarc
             ELSE 'UNKNOWN'
           END
    FROM isbn 
   WHERE bookkey = @i_bookkey 
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @productnumber_var = ''
    RETURN @productnumber_var 
  END 

  RETURN @productnumber_var
END
GO

GRANT EXEC ON dbo.qutl_get_productnumber TO public
GO
