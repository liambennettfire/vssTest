IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_global_participant_roles') )
DROP FUNCTION dbo.qtitle_global_participant_roles
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[qtitle_global_participant_roles]
    ( @i_bookkey as integer,
      @i_printingkey as integer,
      @i_globalcontactkey as integer) 

RETURNS varchar(256)

/******************************************************************************
**  File: qtitle_global_participant_roles.sql
**  Name: qtitle_global_participant_roles
**  Desc: This returns a string which gives a summary of the roles
**        which the participant has in the creation of a book.  The list
**        is grouped by globalcontactkey.
**
**
**    Auth: Lisa Cormier
**    Date: 28 May 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @finalValue varchar(256)
  DECLARE @currentRole varchar(200)

  SET @finalValue = ''
  
  DECLARE participants_cursor CURSOR FOR
	SELECT g.datadesc  
      FROM bookcontact b
	  JOIN bookcontactrole r on b.bookcontactkey = r.bookcontactkey
	  JOIN gentables g on g.tableid = 285 
	   and g.datacode = r.rolecode
     WHERE b.bookkey = @i_bookkey
       and b.printingkey = @i_printingkey
       and b.globalcontactkey = @i_globalcontactkey
       
  OPEN participants_cursor

  -- Perform the first fetch.
  FETCH NEXT FROM participants_cursor INTO 
    @currentRole
    
  IF @@FETCH_STATUS = 0
  BEGIN
    SET @finalValue = @currentRole
    FETCH NEXT FROM participants_cursor INTO 
      @currentRole
  END
    
  -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @finalValue = @finalValue + ', ' + @currentRole
    -- This is executed as long as the previous fetch succeeds.
  FETCH NEXT FROM participants_cursor INTO 
    @currentRole
  END

  CLOSE participants_cursor
  DEALLOCATE participants_cursor

return @finalValue

END
