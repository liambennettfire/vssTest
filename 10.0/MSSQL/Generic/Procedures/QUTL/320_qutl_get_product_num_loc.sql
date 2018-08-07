if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_product_num_loc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
  print 'Dropping dbo.qutl_get_product_num_loc'
  drop procedure dbo.qutl_get_product_num_loc
END
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

print 'Creating dbo.qutl_get_product_num_loc'
GO

CREATE PROCEDURE dbo.qutl_get_product_num_loc
 (@i_product_num_loc_key        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_product_num_loc
**  Desc: For the type of product number location get the entries that
**        explain where the product number exists.
**
**              
**    Auth: James Weber
**    Date: 13 Sept 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT p.* 
    FROM productnumlocation p
   WHERE p.productnumlockey = @i_product_num_loc_key 


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for product number locations contacts: @i_product_num_loc_key = ' + cast(@i_product_num_loc_key AS VARCHAR) 
  END 

GO
GRANT EXEC ON qutl_get_product_num_loc TO PUBLIC
GO

GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_product_num_loc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
print 'Granting exec on dbo.qutl_get_product_num_loc TO PUBLIC'
GRANT EXEC ON dbo.qutl_get_product_num_loc TO PUBLIC
END
GO


