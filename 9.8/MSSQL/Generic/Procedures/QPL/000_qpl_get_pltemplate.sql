if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pltemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pltemplate
GO

CREATE PROCEDURE qpl_get_pltemplate (  
  @i_orgfilter    NVARCHAR(MAX),
  @i_status       integer,
  @i_pltype       integer,
  @i_plsubtype    integer,
  @i_relstrategy  integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_pltemplate
**  Desc: This stored procedure returns the ACTIVE P&L template for given criteria.
**
**  Auth: Kate
**  Date: September 26 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_errormsg VARCHAR(2000),
    @v_sql  NVARCHAR(MAX)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_sql = 'SELECT DISTINCT p.taqprojecttitle, v.*
    FROM taqproject p, taqprojectorgentry o, taqversion v
    WHERE p.taqprojectkey = o.taqprojectkey AND
        p.taqprojectkey = v.taqprojectkey AND
        o.orgentrykey IN ' + @i_orgfilter + ' AND
        p.searchitemcode = 5 AND 
        p.usageclasscode = 1 AND
        p.taqprojectstatuscode = ' + CONVERT(VARCHAR, @i_status) + ' AND
        v.pltypecode = ' + CONVERT(VARCHAR, @i_pltype) + ' AND
        v.releasestrategycode = ' + CONVERT(VARCHAR, @i_relstrategy)
        
  IF @i_plsubtype > 0
    SET @v_sql = @v_sql + ' AND v.pltypesubcode = ' + CONVERT(VARCHAR, @i_plsubtype)        
        
    EXECUTE sp_executesql @v_sql
  
    if @@error > 0 begin
    	select @o_error_desc = description from master..sysmessages
    	where error = @@error
        SET @o_error_code = -1
      RETURN
    END
END
GO

GRANT EXEC ON qpl_get_pltemplate TO PUBLIC
GO


