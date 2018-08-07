if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_all_globalcontactinfo_for_contact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_all_globalcontactinfo_for_contact
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_all_globalcontactinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_all_globalcontactinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_get_all_globalcontactinfo
 (@i_contactkey     integer,
  @i_tablename      varchar(255),
  @i_primaryonlyind bit,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_all_globalcontactinfo
**  Desc: This stored procedure returns ALL global contact information, 
**        for a given contact, from any global contact table. The table
**        must contain globalcontactkey as the result set will return 
**        ALL rows for that key.  
**
**        It is designed to be used in conjunction with any contact
**        information control needing ALL info for a specific globalcontactkey.
**
**  Auth: Alan Katzen
**  Date: 13 May 2004
*******************************************************************************
**  Change History
*******************************************************************************
**  6/23/05 - KW - Added primaryindonly for more flexibility
*******************************************************************************/

  DECLARE @v_error      INT,
          @v_rowcount   INT,
          @v_SQLString  NVARCHAR(4000)

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to retrieve data: tablename is empty.'
    RETURN
  END 

  IF (@i_tablename IS NOT NULL) BEGIN 
    SET @v_SQLString = N'SELECT * ' +  
              ' FROM ' + cast(@i_tablename AS NVARCHAR) + ' c ' +
              ' WHERE c.globalcontactkey = ' + cast(@i_contactkey AS NVARCHAR) 

    -- If return only primary flag is set to TRUE (1)
    IF @i_primaryonlyind = 1
      SET @v_SQLString = @v_SQLString + N' AND c.primaryind = 1'

    EXECUTE sp_executesql @v_SQLString
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on ' + @i_tablename + '(' + cast(@v_error AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qcontact_get_all_globalcontactinfo TO PUBLIC
GO


