if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleparameters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleparameters
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleparameters
 (@i_taqprojectkey				integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleparameters
**  Desc: This procedure returns rows for the Scale Parameters section
**
**	Auth: Dustin Miller
**	Date: February 21 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  11/08/17  Colman    47625 - Moved code into a function
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT * FROM dbo.qscale_get_scaleparameters_view(@i_taqprojectkey)

IF @@ERROR <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error returning scale parameters information (taqprojectkey=' + cast(@i_taqprojectkey as varchar) + ')'
  RETURN  
END 
  
GO

GRANT EXEC ON qscale_get_scaleparameters TO PUBLIC
GO