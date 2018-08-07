if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_specific_task') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_specific_task
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_specific_task
 (@i_taqtaskkey			integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_specific_task
**  Desc: This stored procedure returns task information
**        from the taqprojecttask table for a title/printing task. 
**
**    Auth: Dustin Miller
**    Date: 8/30/12
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  
  --SELECT COALESCE(d.datelabel,d.description) description,t.taqtaskkey
		SELECT *
    FROM taqprojecttask t
    JOIN datetype d
    ON (t.datetypecode = d.datetypecode)
		WHERE t.taqtaskkey = @i_taqtaskkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttask: taqtaskkey = ' + cast(@i_taqtaskkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qutl_get_specific_task TO PUBLIC
GO


