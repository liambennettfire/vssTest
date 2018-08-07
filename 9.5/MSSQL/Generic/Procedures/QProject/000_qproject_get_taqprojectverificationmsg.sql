if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taqprojectverificationmsg') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taqprojectverificationmsg
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taqprojectverificationmsg
 (@i_projectkey      integer,
  @i_verifytypecode  integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_taqprojectverificationmsg
**  Desc: This stored procedure returns info from the  
**        taqprojectverificationmessage table. 
**             
**    Auth: Alan Katzen
**    Date: 2 February 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT m.*, messagetypecode severity
    FROM taqprojectverificationmessage m
   WHERE m.taqprojectkey = @i_projectkey and
         m.verificationtypecode = @i_verifytypecode

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR) 
  END 

GO
GRANT EXEC ON qproject_get_taqprojectverificationmsg TO PUBLIC
GO


