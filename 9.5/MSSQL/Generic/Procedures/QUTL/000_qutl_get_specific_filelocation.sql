if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_specific_filelocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_specific_filelocation
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_specific_filelocation
 (@i_locationgenkey  integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_specific_filelocation
**  Desc: This stored procedure returns filelocation information
**        from the filelocation table for a specific filelocationgeneratedkey. 
**
**    Auth: Alan Katzen
**    Date: 5/30/08
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT fl.*
  FROM filelocation fl
  WHERE fl.filelocationgeneratedkey = @i_locationgenkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: filelocationgeneratedkey = ' + cast(@i_locationgenkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qutl_get_specific_filelocation TO PUBLIC
GO


