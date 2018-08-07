if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_delete_taskview_task') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_delete_taskview_task
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_delete_taskview_task]
 (@i_taskviewkey			integer,
  @i_datetype				integer,
  @o_error_code				integer output,
  @o_error_desc				varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_delete_taskview_task
**  Desc: This stored procedure deletes a taskviewdatetype record for
**          a given taskview.
**
**  Auth: Lisa Cormier
**  Date: 10 Dec 2008
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @v_count      INT
  
  DELETE FROM taskviewdatetype WHERE taskviewkey = @i_taskviewkey and datetypecode = @i_datetype

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error deleting taskviewdatetype from qutl_delete_taskview_task proc'  
  END 

