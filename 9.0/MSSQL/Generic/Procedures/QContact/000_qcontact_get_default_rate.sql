IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcontact_get_default_rate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcontact_get_default_rate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @err int
declare @dsc varchar(2000)
--exec qcontact_get_default_rate 566192, 'Proofreader', 0, 565378, @err, @dsc
exec qcontact_get_default_rate 250999, '', 0, 0, @err, @dsc
*/

CREATE PROCEDURE [dbo].[qcontact_get_default_rate]
 (@i_globalContactKey	integer,
  @i_contactRole		varchar(200),
  @i_rolecode			integer,
  @i_projectkey			integer,
  @i_bookkey            integer,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_default_rate
**  Desc: This stored procedure returns globalcontact displayname & key for
**			the userid.
**
**  Parameters:
**		@i_globalContactKey - globalcontactkey column of globalcontact table
**
**  Auth: Lisa Cormier
**  Date: 12 Sep 2008
*******************************************************************************
**  Date    Who   Change
**  ------- ---   -------------------------------------------------------------
**  5/5/09  Kate  When rolecode not passed in, must return role even when no rate/ratetype.
**  6/17/09 Lisa  Needed bookcontactkey returned so when a contact is added with a new
**                      role, duplicate bookcontact records are not created from the search dialog.
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @keyind		INT
  DECLARE @taqprojectcontactkey INT
  DECLARE @bookcontactkey INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  select @keyind = 0
  select @taqprojectcontactkey = 0
  select @bookcontactkey = 0
  
  -- there should only be one contact key per project/globalcontactkey or book/globalcontactkey
  -- If there are multiples a repair script should be run
  if ( @i_projectkey > 0 )
  BEGIN
    select top 1 @keyind = isnull(keyind,0), @taqprojectcontactkey = isnull(taqprojectcontactkey,0)
    from taqprojectcontact
    where globalcontactkey = @i_globalContactKey and taqprojectkey = @i_projectkey
  END
  
  if ( @i_bookkey > 0 )
  BEGIN
    select top 1 @keyind = isnull(keyind,0), @bookcontactkey = isnull(bookcontactkey,0)
    from bookcontact
    where globalcontactkey = @i_globalContactKey and bookkey = @i_bookkey
  END

  IF ( @i_rolecode > 0 )  -- If we have a valid rolecode use it
  BEGIN
    SELECT top 1 g.globalcontactkey, displayname, datadesc, 
      isNull(rolecode,0) as rolecode, individualind, 
      globalcontactnotes, ratetypecode, workrate,
      @keyind as keyind, @taqprojectcontactkey as taqprojectcontactkey,
      @bookcontactkey as bookcontactkey
    FROM globalcontact g
      left join globalcontactrole gr on g.globalcontactkey = gr.globalcontactkey
      left join gentables on tableid = 285 and datacode = rolecode
    WHERE g.globalcontactkey = @i_globalContactKey 
      and gr.rolecode = @i_rolecode     
  END
  -- Else, try to use a description of the role if we have it
  ELSE IF ( LEN(@i_contactRole) > 0 )
  BEGIN
    SELECT top 1 g.globalcontactkey, displayname, datadesc, 
      isNull(rolecode,0) as rolecode, individualind, 
      globalcontactnotes, ratetypecode, workrate,
      @keyind as keyind, @taqprojectcontactkey as taqprojectcontactkey,
      @bookcontactkey as bookcontactkey
    FROM globalcontact g
      left join globalcontactrole gr on g.globalcontactkey = gr.globalcontactkey
      left join gentables on tableid = 285 and datacode = rolecode
    WHERE g.globalcontactkey = @i_globalContactKey
      and (datadesc like '%' + @i_contactRole + '%')    
  END
  ELSE IF ( @taqprojectcontactkey > 0 ) 
  BEGIN
    SELECT top 1 g.globalcontactkey, displayname, datadesc, 
      isNull(rolecode,0) as rolecode, individualind, 
      globalcontactnotes, ratetypecode, workrate,
      @keyind as keyind, @taqprojectcontactkey as taqprojectcontactkey, 0 as bookcontactkey
    FROM globalcontact g
      left join globalcontactrole gr on g.globalcontactkey = gr.globalcontactkey
      left join gentables on tableid = 285 and datacode = rolecode
    WHERE g.globalcontactkey = @i_globalContactKey
  END
  ELSE IF ( @bookcontactkey > 0 ) 
  BEGIN
    SELECT top 1 g.globalcontactkey, displayname, datadesc, 
      isNull(rolecode,0) as rolecode, individualind, 
      globalcontactnotes, ratetypecode, workrate,
      @keyind as keyind, 0 as taqprojectcontactkey, @bookcontactkey as bookcontactkey
    FROM globalcontact g
      left join globalcontactrole gr on g.globalcontactkey = gr.globalcontactkey
      left join gentables on tableid = 285 and datacode = rolecode
    WHERE g.globalcontactkey = @i_globalContactKey  
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing globalcontact table from qcontact_get_default_rate stored proc'  
  END 

GO

GRANT EXEC on qcontact_get_default_rate TO PUBLIC
GO

