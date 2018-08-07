if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_classification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_classification
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_classification
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_classification
**  Desc: This stored procedure returns all title information
**        from the bookdetail table. It is designed to be used 
**        in conjunction with a title classification control.
**
**              
**
**    Auth: Alan Katzen
**    Date: 25 March 2004
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

SELECT d.*,b.territoriescode,b.titlestatuscode, b.titletypecode, t.taqprojecttitle as proposedterritorytitle
FROM bookdetail d, book b
LEFT OUTER JOIN taqproject t ON t.taqprojectkey = proposedterritorycode
where d.bookkey = b.bookkey and
      d.bookkey = @i_bookkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_classification TO PUBLIC
GO


