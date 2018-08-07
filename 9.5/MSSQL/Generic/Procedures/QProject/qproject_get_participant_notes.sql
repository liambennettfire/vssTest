if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participant_notes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_participant_notes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_participant_notes
 (@i_projectkey        integer,
  @i_projectcontactkey integer,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qproject_get_participant_notes
**  Desc: This stored procedure returns notes for a participant
**        from the taqprojectcontact table. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 31 May 2004
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

  SELECT pc.*
    FROM taqprojectcontact pc 
   WHERE pc.taqprojectkey = @i_projectkey and
         pc.taqprojectcontactkey = @i_projectcontactkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontact: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)+ ' taqprojectcontactkey = ' + cast(@i_projectcontactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qproject_get_participant_notes TO PUBLIC
GO


