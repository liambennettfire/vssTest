if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_description') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_description
GO

CREATE FUNCTION get_description
    (@i_taqversionformatyearkey as integer,@i_qsicode as integer) 

RETURNS VARCHAR(4000)


/******************************************************************************
**  File: 
**  Name: get_itemdetailcode
**  Desc: This function returns the description
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
  DECLARE @v_desc VARCHAR(4000)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  

  SET @v_desc = ''
  
  RETURN @v_desc
   
END
GO

GRANT EXEC ON dbo.get_description TO public
GO
