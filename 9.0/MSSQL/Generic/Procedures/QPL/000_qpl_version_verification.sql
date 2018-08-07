if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_version_verification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_version_verification
GO

CREATE PROCEDURE qpl_version_verification
 (@i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qpl_version_verification
**  Desc: This is the default P&L Version Verification stored procedure for all clients (blank).
**
**  Auth: Kate
**  Date: 26 January 2011
************************************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
END
GO

GRANT EXEC ON qpl_version_verification TO PUBLIC
GO


