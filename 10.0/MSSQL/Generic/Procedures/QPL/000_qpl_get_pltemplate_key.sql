if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pltemplate_key') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pltemplate_key
GO

CREATE PROCEDURE qpl_get_pltemplate_key (  
  @i_orgfilter    varchar(max),
  @i_status       integer,
  @i_pltype       integer,
  @i_plsubtype    integer,
  @i_relstrategy  integer,
  @o_templatekey  integer output,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_pltemplate_key
**  Desc: This stored procedure returns the ACTIVE P&L template for given criteria.
**
**  Auth: Kate
**  Date: September 26 2007
**************************************************************************************/

DECLARE
  @v_error  INT,
  @v_errormsg VARCHAR(2000),
  @v_sql  NVARCHAR(max)

BEGIN
    
  SET @o_templatekey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @v_sql = N'SELECT @p_templatekey = v.taqprojectkey
    FROM taqproject p, taqprojectorgentry o, taqversion v
    WHERE p.taqprojectkey = o.taqprojectkey AND
        p.taqprojectkey = v.taqprojectkey AND
        o.orgentrykey IN ' + @i_orgfilter + ' AND
        p.searchitemcode = 5 AND 
        p.usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 29) AND
        p.taqprojectstatuscode = ' + CONVERT(VARCHAR, @i_status) + ' AND
        v.pltypecode = ' + CONVERT(VARCHAR, @i_pltype) + ' AND
        v.releasestrategycode = ' + CONVERT(VARCHAR, @i_relstrategy)
        
  IF @i_plsubtype > 0
    SET @v_sql = @v_sql + ' AND v.pltypesubcode = ' + CONVERT(VARCHAR, @i_plsubtype)        

  EXECUTE sp_executesql @v_sql, N'@p_templatekey INT OUTPUT', @o_templatekey OUTPUT

  if @@error > 0 begin
  	select @o_error_desc = description 
  	from master..sysmessages
  	where error = @@error
  	
  	SET @o_error_desc = 'Error geetting P&L template key: ' + @o_error_desc
    SET @o_error_code = -1
    RETURN
  end

END
GO

GRANT EXEC ON qpl_get_pltemplate_key TO PUBLIC
GO


