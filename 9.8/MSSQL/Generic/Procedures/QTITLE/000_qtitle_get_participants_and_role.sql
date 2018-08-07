if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_participants_and_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_participants_and_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
declare @err int,
@dsc varchar(2000)
exec qtitle_get_participants_and_role 2736834, 1, 0, @err, @dsc
*/

CREATE PROCEDURE [dbo].[qtitle_get_participants_and_role]
 (@i_bookkey                integer,
  @i_printingkey            integer,
  @i_keyonly                bit,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/******************************************************************************
**  File: qtitle_get_participants_and_role.sql
**  Name: qtitle_get_participants_and_role
**  Desc: This stored procedure gets the particpants and their roles for the 
**        bookkey/printingkey.  Use this procedure if you need to show participants 
**        and each role as a seperate item.
**
**    Auth: Lisa Cormier
**    Date: 22 May 2009
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  IF @i_keyonly IS NULL OR @i_keyonly = 0
    BEGIN
      SELECT b.bookkey, b.bookcontactkey, b.globalcontactkey, 
        participantroles = dbo.qtitle_participant_role_summary(@i_bookkey, b.bookcontactkey),
        b.keyind, b.sortorder, c.displayname, c.email, c.phone, r.rolecode,
        CASE WHEN LEN(b.participantnote) > 45 THEN
          CAST(b.participantnote AS VARCHAR(45)) + '...'
          ELSE b.participantnote
        END AS participantnote
      FROM bookcontact b, corecontactinfo c, bookcontactrole r
      WHERE b.bookkey = @i_bookkey AND b.printingkey = @i_printingkey
        AND b.globalcontactkey = c.contactkey
        AND b.bookcontactkey = r.bookcontactkey
      ORDER BY b.sortorder, c.displayname
    END
  ELSE
    BEGIN
      SELECT b.bookkey, b.bookcontactkey, b.globalcontactkey, 
        participantroles = dbo.qtitle_participant_role_summary(@i_bookkey, b.bookcontactkey),
        b.keyind, b.sortorder, c.displayname, c.email, c.phone, r.rolecode,
        CASE WHEN LEN(b.participantnote) > 45 THEN
          CAST(b.participantnote AS VARCHAR(45)) + '...'
          ELSE b.participantnote
        END AS participantnote
      FROM bookcontact b, corecontactinfo c, bookcontactrole r
      WHERE b.bookkey = @i_bookkey AND b.printingkey = @i_printingkey
        AND b.globalcontactkey = c.contactkey
        AND b.bookcontactkey = r.bookcontactkey
        AND b.keyind = 1  
      ORDER BY b.sortorder, c.displayname
    END

  
ExitHandler:

GO
GRANT EXEC ON qtitle_get_participants_and_role TO PUBLIC
GO

 

