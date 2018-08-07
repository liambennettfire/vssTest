if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_bookpages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_bookpages
GO

CREATE PROCEDURE qpl_calc_bookpages
 (@i_numchars       integer,
  @i_numwords       integer,
  @i_manupages      integer,
  @o_bookpages      integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_calc_bookpages
**  Desc: This is a default stored procedure for calculating Book Pages on P&L Production Specs.
**        Clients may have an overridden custom version of this stored procedure.
**
**  Auth: Kate
**  Date: March 10, 2008
*********************************************************************************************************/

BEGIN

  SET @o_bookpages = 0
  SET @o_error_desc = 'No calculation exists.'
  GOTO RETURN_WARNING
  
RETURN_WARNING:  
  SET @o_error_code = -2
  RETURN  
    
END
GO

GRANT EXEC ON qpl_calc_bookpages TO PUBLIC
GO
