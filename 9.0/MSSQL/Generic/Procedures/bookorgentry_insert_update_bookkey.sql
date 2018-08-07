PRINT 'STORED PROCEDURE : bookorgentry_insert_update_bookkey'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'bookorgentry_insert_update_bookkey')
	BEGIN
		PRINT 'Dropping Procedure bookorgentry_insert_update_bookkey'
		DROP  Procedure  bookorgentry_insert_update_bookkey
	END

GO

PRINT 'Creating Procedure bookorgentry_insert_update_bookkey'
GO
CREATE Procedure bookorgentry_insert_update_bookkey
(
  @i_bookkey                     int,
  @i_bottom_level_orgentrykey    int,
  @i_user                        varchar(30) = 'sp_bookorgentry_insert_update_bookkey',
  @o_error_code                  int         output,
  @o_error_desc                  char(200)   output 
)
AS

/******************************************************************************
** File: bookorgentry_insert_update_bookkey.sql 
** Name: bookorgentry_insert_update_bookkey
** Desc: This stored procedure creates the entries needed for
**       a book key based on the lowest level orgentry
**       that owns the book.  It creates the rest of the levels
**       based on the orgentry table.
**
**
**		Auth: James P. Weber
**		Date: 10 Jul 2003
**    
*******************************************************************************/

  DECLARE @current_orgentrykey int;        -- temp storage
  DECLARE @current_orgentryparentkey int;  -- temp storage
  DECLARE @current_orglevel int;           -- temp storage

  BEGIN TRANSACTION
  
  delete from bookorgentry where bookkey = @i_bookkey;
  set @current_orglevel = null;
  select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey, @current_orgentryparentkey = orgentryparentkey from orgentry where orgentrykey = @i_bottom_level_orgentrykey;
  
  while (@current_orglevel is not null)
  BEGIN
    -- TEST
    --PRINT '@current_orgentrykey';
    --PRINT @current_orgentrykey;
    --PRINT '@current_orgentryparentkey';
    --PRINT @current_orgentryparentkey;
    --PRINT '@current_orglevel';
    --PRINT @current_orglevel;

    insert bookorgentry (bookkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate) VALUES
      (@i_bookkey, @current_orgentrykey, @current_orglevel, @i_user, GETDATE());
    set @current_orglevel = null;
    select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey,  @current_orgentryparentkey = orgentryparentkey  from orgentry where orgentrykey = @current_orgentryparentkey;
  END

  COMMIT
  return 0;


GO

GRANT EXEC ON bookorgentry_insert_update_bookkey TO PUBLIC

GO

PRINT 'STORED PROCEDURE : bookorgentry_insert_update_bookkey complete'
GO

