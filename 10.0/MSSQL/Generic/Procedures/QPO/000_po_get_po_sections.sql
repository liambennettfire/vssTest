if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_get_po_sections') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_get_po_sections
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE po_get_po_sections
 (@i_taqprojectkey  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************************************************
**  Name: po_get_po_sections
**  Desc: This procedure returns section details for PO
**
**	Auth: Dustin
**	Date: 22 November 2016
*******************************************************************************************************************
**	Change History
*******************************************************************************************************************
**	Date:     Author:   Case #:   Description:
**	--------  -------   -------   --------------------------------------
**	
*******************************************************************************************************************/

DECLARE
  @v_error	INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT *
  FROM taqversionformat
  WHERE taqprojectkey = @i_taqprojectkey
  ORDER BY sortorder

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning PO section detail (taqprojectkey = ' + cast(@i_taqprojectkey as varchar) + ')'
    RETURN  
  END 

END
GO

GRANT EXEC ON po_get_po_sections TO PUBLIC
GO


