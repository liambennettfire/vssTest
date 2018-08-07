IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcontact_get_contactplaces]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcontact_get_contactplaces]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qcontact_get_contactplaces]
 (@i_globalcontactkey	integer,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_contactplaces
**  Desc: This stored procedure returns globalcontactplaces displayname & key for
**			the userid.
**
**  Parameters:
**		@i_globalcontactkey - globalcontactkey column of globalcontactplaces table
**
**  Auth: Colman
**  Date: 9 Jul 2015
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  SELECT g.globalcontactkey, g.placecode, g.countrycode, r1.tag as countrytag, r1.name as countrydesc, 
         g.regioncode, r2.name as regiondesc, r2.tag as regiontag
  FROM globalcontactplaces g
  LEFT OUTER JOIN cloudregion AS r1 ON
     r1.id = g.countrycode
  LEFT OUTER JOIN cloudregion AS r2 ON
     r2.id = g.regioncode
  WHERE g.globalcontactkey = @i_globalcontactkey
 
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing globalcontactplaces table from qcontact_get_contactplaces stored proc'  
  END 

GO

GRANT EXEC on qcontact_get_contactplaces TO PUBLIC
GO

