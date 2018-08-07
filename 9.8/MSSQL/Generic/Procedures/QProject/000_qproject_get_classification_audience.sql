if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_classification_audience') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_classification_audience
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_classification_audience
 (@i_projectkey     integer,
  @i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_classification_audience
**  Desc: This stored procedure returns all audience information
**        for a project from the projectaudience table. It is designed  
**        to be used in conjunction with a project classification 
**        control.
**              
**
**    Auth: Colman
**    Date: 1 June 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''
DECLARE @error_var    INT

SELECT taqprojectaudience.*, gentables.datadesc
FROM taqprojectaudience LEFT OUTER JOIN gentables ON taqprojectaudience.audiencecode = gentables.datacode 
WHERE gentables.tableid = @i_tableid AND taqprojectaudience.taqprojectkey = @i_projectkey 
ORDER BY taqprojectaudience.sortorder

SELECT @error_var = @@ERROR
IF @error_var <> 0 BEGIN
  SET @o_error_code = 1
  SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
END 

GO
GRANT EXEC ON qproject_get_classification_audience TO PUBLIC
GO



