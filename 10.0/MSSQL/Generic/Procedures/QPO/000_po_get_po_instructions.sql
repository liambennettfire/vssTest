if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_get_po_instructions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_get_po_instructions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE po_get_po_instructions
 (@i_projectkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: po_get_po_instructions
**  Desc: This procedure returns gpoinstructions information for the Purchase Order project.  
**
**	Auth: Uday
**	Date: 24 June 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT * 
  FROM gpoinstructions
  WHERE gpokey = @i_projectkey
  ORDER BY detaillinenbr

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning file locations for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON po_get_po_instructions TO PUBLIC
GO


