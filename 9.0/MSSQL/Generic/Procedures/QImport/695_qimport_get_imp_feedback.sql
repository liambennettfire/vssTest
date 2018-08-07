if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qimport_get_imp_feedback') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qimport_get_imp_feedback
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qimport_get_imp_feedback
 (@i_batchkey       integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qimport_get_imp_feedback
**  Desc: This gets the messages generated by an import.
**
**    Auth: Alan Katzen
**    Date: 9 November 2005
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT f.*, f.serverity severity, e.elementdesc, bd.originalvalue, 
         cast(f.batchkey AS VARCHAR) + ',' + 
         cast(COALESCE(f.row_id,0) AS VARCHAR) + ',' +
         cast(COALESCE(f.elementkey,0) AS VARCHAR) + ',' +
         cast(COALESCE(f.elementseq,0) AS VARCHAR) + ',' +
         cast(COALESCE(f.rulekey,0) AS VARCHAR) rowkeys 
    FROM imp_feedback_view f LEFT OUTER JOIN imp_batch_detail bd ON
        f.elementkey = bd.elementkey AND
        f.elementseq = bd.elementseq  AND
        f.batchkey = bd.batchkey AND
        f.row_id = bd.row_id  
	 LEFT OUTER JOIN imp_element_defs e ON
	    f.elementkey = e.elementkey 
   WHERE f.batchkey = @i_batchkey 
ORDER BY f.batchkey, f.ImpIdentifier, f.row_id, f.elementkey, f.rulekey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: batchkey = ' + cast(@i_batchkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qimport_get_imp_feedback TO PUBLIC
GO



