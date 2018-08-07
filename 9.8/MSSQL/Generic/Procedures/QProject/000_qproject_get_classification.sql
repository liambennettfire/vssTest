if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_classification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_classification
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_classification
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_classification
**  Desc: This stored procedure returns all project classification information
**        from the taqproject table. It is designed to be used 
**        in conjunction with a project classification control.
**
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
DECLARE @rowcount_var INT

SELECT p.titletypecode, p.canadianrestrictioncode, p.returncode, p.restrictioncode, p.origincode, p.copyrightyear, p.languagecode, p.languagecode2, p.allagesind,
       p.agelowupind, p.agelow, p.agehighupind, p.agehigh, p.gradelowupind, p.gradelow, p.gradehighupind, p.gradehigh, p.proposedterritorycode, t.taqprojecttitle as proposedterritorytitle
       
FROM taqproject p
LEFT OUTER JOIN taqproject t ON t.taqprojectkey = p.proposedterritorycode
where p.taqprojectkey = @i_projectkey 

SELECT @error_var = @@ERROR
IF @error_var <> 0 BEGIN
  SET @o_error_code = 1
  SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
END 

GO
GRANT EXEC ON qproject_get_classification TO PUBLIC
GO


