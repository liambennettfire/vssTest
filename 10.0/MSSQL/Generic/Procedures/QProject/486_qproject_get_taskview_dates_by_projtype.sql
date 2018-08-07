/* Old name qproject_get_taskviewdates_by_projecttype was too long for Oracle */
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskviewdates_by_projecttype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_taskviewdates_by_projecttype
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskview_dates_by_projtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_taskview_dates_by_projtype
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskview_dates_by_projtype
 (@i_projecttype  integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_taskview_dates_by_projtype
**  Desc: This stored procedure gets a list of tasks from taskviewdatetype
**        table for a given Project Type code.
**
**  Auth: Kate Wiewiora
**  Date: 21 April 2005
*******************************************************************************/

  DECLARE @ErrorValue    INT
  DECLARE @RowcountValue INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @ErrorValue = 0
  SET @RowcountValue = 0
  
  SELECT vd.datetypecode
  FROM taskview v, taskviewdatetype vd
  WHERE v.taskviewkey = vd.taskviewkey AND
    v.taqprojecttypecode = @i_projecttype
  
  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT  
  IF @ErrorValue <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taskviewdatetype table'
    RETURN
  END
  
GO

GRANT EXEC ON qproject_get_taskview_dates_by_projtype TO PUBLIC
GO
