if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_task_contributorkey') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_get_task_contributorkey
GO

CREATE FUNCTION qproject_get_task_contributorkey
    ( @i_taqprojectkey as integer,
      @i_taqprojectcontactkey as integer) 

RETURNS int

/******************************************************************************
**  File: qproject_get_task_contributorkey.sql
**  Name: qproject_get_task_contributorkey
**  Desc: Returns the contributorkey if it exists. 
**
**
**    Auth: Alan Katzen
**    Date: 24 May 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_contributorkey   INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_contributorkey = NULL

---  SELECT @i_contributorkey = gc.globalcontactkey
---    FROM taqprojectcontact c, globalcontactrole gc
---   WHERE c.globalcontactkey = gc.globalcontactkey and
---         c.taqprojectkey = @i_taqprojectkey and
---         c.taqprojectcontactkey = @i_taqprojectcontactkey 

  SELECT @i_contributorkey = globalcontactkey
    FROM taqprojectcontact c
   WHERE c.taqprojectkey = @i_taqprojectkey and
         c.taqprojectcontactkey = @i_taqprojectcontactkey 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 
  BEGIN
    SET @i_contributorkey = NULL
  END 

  RETURN @i_contributorkey
END
GO

GRANT EXEC ON dbo.qproject_get_task_contributorkey TO public
GO