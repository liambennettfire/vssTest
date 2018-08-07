if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_default_productidtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_default_productidtype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_default_productidtype
 (@o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_default_productidtype
**  Desc: Based on productnumlocation configuration, return default ProductID
**        datacode (gentable 551).
**
**  Auth: Alan Katzen
**  Date: 08 March 2006
*******************************************************************************/

  DECLARE @v_count               INT,
          @error_var             INT,
          @rowcount_var          INT,
          @v_default_prodnum_col varchar(50),
          @v_datacode            INT,
          @v_qsicode  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- use productnumlocation table to determine default productidtype
  SELECT @v_default_prodnum_col = columnname 
  FROM productnumlocation
  WHERE productnumlockey = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found on productnumlocation.' 
    RETURN 
  END
  
  SET @v_default_prodnum_col = LOWER(@v_default_prodnum_col)
  
  SET @v_qsicode = 
    CASE @v_default_prodnum_col
      WHEN 'isbn' THEN 1
      WHEN 'isbn10' THEN 1
      WHEN 'gtin' THEN 3
      WHEN 'gtin14' THEN 3
      WHEN 'itemnumber' THEN 6
      ELSE 2  --default to EAN/ISBN-13
    END
  
  SELECT datacode 
  FROM gentables
  WHERE tableid = 551 and qsicode = @v_qsicode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'no data found on gentables 551: qsicode = ' + CONVERT(VARCHAR, @v_qsicode)
    RETURN  
  END

GO

GRANT EXEC ON qtitle_get_default_productidtype TO PUBLIC
GO


