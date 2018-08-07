if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_check_scaletab_grid_status') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_check_scaletab_grid_status
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_check_scaletab_grid_status
 (@i_scaletabkey					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_check_scaletab_grid_status
**  Desc: This procedure checks whether the indicated scaletabkey is a grid or not
**
**	Auth: Dustin Miller
**	Date: February 23 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT tabsectiontype 
  FROM taqscaleadmintab 
  WHERE scaletabkey=@i_scaletabkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale tab grid status information (scaletabkey=' + cast(@i_scaletabkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_check_scaletab_grid_status TO PUBLIC
GO