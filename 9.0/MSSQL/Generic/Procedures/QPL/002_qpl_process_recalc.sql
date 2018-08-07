if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_process_recalc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_process_recalc
GO

CREATE PROCEDURE qpl_process_recalc (  
  @i_projectkey     integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************
**  Name: qpl_process_recalc
**  Desc: This stored procedure recalculates all p&l summary items for any versions of the project
**        that need recalculation (ex: changes were made to version but system timing out
**        before leaving Version Details screen - where recalc normally would occur)
**
**  Auth: Kate
**  Date: July 9 2014
*************************************************************************************************/

DECLARE
  @v_errorcode	INT,
  @v_errordesc	VARCHAR(2000),
  @v_plstage  INT,
  @v_plversion  INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE recalc_cur CURSOR FOR
    SELECT plstagecode, taqversionkey
    FROM taqversionrecalcneeded
    WHERE taqprojectkey = @i_projectkey
    
  OPEN recalc_cur 

  FETCH recalc_cur INTO @v_plstage, @v_plversion

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    
    EXEC qpl_recalc_pl_items @i_projectkey, @v_plstage, @v_plversion, @i_userid, @v_errorcode OUTPUT, @v_errordesc OUTPUT
      
    IF @v_errorcode <> 0
      GOTO ERROR
  
    FETCH recalc_cur INTO @v_plstage, @v_plversion
  END

  CLOSE recalc_cur
  DEALLOCATE recalc_cur
    
  RETURN

  ERROR:
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN
   
END
GO

GRANT EXEC ON qpl_process_recalc TO PUBLIC
GO

