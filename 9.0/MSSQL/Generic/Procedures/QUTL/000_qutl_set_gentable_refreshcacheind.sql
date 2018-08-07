IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_set_gentable_refreshcacheind')
  BEGIN
    PRINT 'Dropping Procedure qutl_set_gentable_refreshcacheind'
    DROP  Procedure  qutl_set_gentable_refreshcacheind
  END
GO

PRINT 'Creating Procedure qutl_set_gentable_refreshcacheind'
GO

CREATE PROCEDURE qutl_set_gentable_refreshcacheind
 (@i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_set_gentable_refreshcacheind
**  Desc: This stored procedure will set the refreshcacheind on 
**        gentablesdesc for one tableid
**
**
**  Auth: Kusum
**  Date: 11 November 2014
**
*******************************************************************************/

  DECLARE
    @v_tableid    INT, 
    @error_var    INT,
    @rowcount_var INT
       
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_tableid = coalesce(@i_tableid,0)

  UPDATE gentablesdesc
     SET refreshcacheind = 1
   WHERE tableid = @v_tableid
     and (refreshcacheind = 0 OR refreshcacheind is null)
     
GO

GRANT EXEC ON qutl_set_gentable_refreshcacheind TO PUBLIC
GO
