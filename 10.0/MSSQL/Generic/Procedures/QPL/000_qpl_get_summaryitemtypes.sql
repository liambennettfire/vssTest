if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_summaryitemtypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpl_get_summaryitemtypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qpl_get_summaryitemtypes
 (@i_summaryitemkey integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qpl_get_summaryitemtypes
**              
**
**    Auth: CO'C
**    Date: 12/11/15
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
  FROM plsummaryitemtype p 
  WHERE p.plsummaryitemkey = @i_summaryitemkey
  ORDER BY p.position

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0  BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: i_summaryitemkey = ' + cast(@i_summaryitemkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qpl_get_summaryitemtypes TO PUBLIC
GO


