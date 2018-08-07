if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_contactnamesearch_by_grouptype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.get_contactnamesearch_by_grouptype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE get_contactnamesearch_by_grouptype
 (@i_grouptypecode  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: get_contactnamesearch_by_grouptype
**  Desc: This stored procedure returns contactinfo data
**        for a global contacts based on grouptypecode. 
**
**    Auth: Kusum Basra
**    Date: 29 August 2011
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
  
  IF @i_grouptypecode is null OR @i_grouptypecode <= 0 BEGIN
    return
  END
  
  SELECT DISTINCT gc.globalcontactkey, gc.displayname
    FROM globalcontact gc 
   WHERE gc.grouptypecode = @i_grouptypecode 
     AND gc.activeind = 1
ORDER BY gc.displayname

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error getting data from globalcontact (' + cast(@error_var AS VARCHAR) + '): grouptypecode = ' + cast(@i_grouptypecode AS VARCHAR)   
  END 

GO
GRANT EXEC ON get_contactnamesearch_by_grouptype TO PUBLIC
GO



