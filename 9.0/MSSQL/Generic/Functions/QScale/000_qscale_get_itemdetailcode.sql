if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_itemdetailcode') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_itemdetailcode
GO

CREATE FUNCTION get_itemdetailcode
    (@i_taqversionformatyearkey as integer,@i_qsicode as integer) 

RETURNS INT


/******************************************************************************
**  File: 
**  Name: get_itemdetailcode
**  Desc: This function returns the itemdetailcode
**         
**
**    Auth: Kusum Basra
**    Date: 26 March 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_itemdetailcode INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  

  SET @v_itemdetailcode = 0
  
  RETURN @v_itemdetailcode
   
END
GO

GRANT EXEC ON dbo.get_itemdetailcode TO public
GO
