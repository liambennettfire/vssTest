if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleorgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleorgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qscale_get_scaleorgentry
 (@i_projectkey          integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_scaleorgentry
**  Desc: This stored procedure returns all organizational entries
**        for a scale. 
**
**    Auth: Alan Katzen
**    Date: 25 January 2012
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT
          
  SELECT so.orgentrykey, (select orgentrydesc from orgentry where orgentrykey = so.orgentrykey) orgentrydesc
    FROM taqprojectscaleorgentry so
   WHERE so.taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to retrieve scale orgentries'
    RETURN
  END 
 
GO
GRANT EXEC ON qscale_get_scaleorgentry TO PUBLIC
GO


