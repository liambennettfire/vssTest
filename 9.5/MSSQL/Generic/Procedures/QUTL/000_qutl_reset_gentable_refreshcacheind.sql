IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_reset_gentable_refreshcacheind')
  BEGIN
    PRINT 'Dropping Procedure qutl_reset_gentable_refreshcacheind'
    DROP  Procedure  qutl_reset_gentable_refreshcacheind
  END
GO

PRINT 'Creating Procedure qutl_reset_gentable_refreshcacheind'
GO

CREATE PROCEDURE qutl_reset_gentable_refreshcacheind
 (@i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_reset_gentable_refreshcacheind
**  Desc: This stored procedure will reset all the refreshcacheind on 
**        gentablesdesc for one or all tableids
**
**  @@i_tableid: 
**    0 - reset all tableids
**    > 0 - reset the specific tableid
**
**  Auth: Alan Katzen
**  Date: 7 November 2014
**
*******************************************************************************/

  DECLARE
    @v_tableid    INT, 
    @error_var    INT,
    @rowcount_var INT
       
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_tableid = coalesce(@i_tableid,0)

  IF @v_tableid = 0 BEGIN
    -- reset indicator for ALL gentables
    UPDATE gentablesdesc
       SET refreshcacheind = 0
     WHERE refreshcacheind = 1
  END
  ELSE IF @v_tableid > 0 BEGIN
    UPDATE gentablesdesc
       SET refreshcacheind = 0
     WHERE tableid = @v_tableid
       and refreshcacheind = 1
  END
   
GO

GRANT EXEC ON qutl_reset_gentable_refreshcacheind TO PUBLIC
GO
