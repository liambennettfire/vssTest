PRINT 'STORED PROCEDURE : orgentry_find_ancestor_orgentrykey'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'orgentry_find_ancestor_orgentrykey')
	BEGIN
		PRINT 'Dropping Procedure orgentry_find_ancestor_orgentrykey'
		DROP  Procedure  orgentry_find_ancestor_orgentrykey
	END

GO

PRINT 'Creating Procedure orgentry_find_ancestor_orgentrykey'
GO
CREATE Procedure orgentry_find_ancestor_orgentrykey
(
  @i_anscestororglevelkey        int,
  @i_this_orgentrykey            int,
  @o_ancestororgentrykey         int         output,
  @o_error_code                  int         output,
  @o_error_desc                  char(200)   output 
)
AS

/******************************************************************************
** File: orgentry_find_ancestor_orgentrykey.sql 
** Name: orgentry_find_ancestor_orgentrykey
** Desc: 
**
** Return values:
**   This stored procedure returns the orgentry key at the level
**   specified or it returns null for the cases where the level n
**   key was not found for one reason or another.  The location to
**   start the search is determined by the 'i_this_orgentrykey
**              
**
**		Auth: James P. Weber
**		Date: 09 Jul 2003
**    
*******************************************************************************/

  DECLARE @current_orgentrykey int;        -- temp storage
  DECLARE @current_orgentryparentkey int;  -- temp storage
  DECLARE @current_orglevel int;           -- temp storage

  set @o_ancestororgentrykey = null;

  set @current_orglevel = null;
  select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey, @current_orgentryparentkey = orgentryparentkey from orgentry where orgentrykey = @i_this_orgentrykey;
  
  if (@current_orglevel = @i_anscestororglevelkey)
  BEGIN
    set @o_ancestororgentrykey = null;
    set @o_error_desc = 'Parent not a vaid concept';
    return 0;
  END 

  while (@current_orglevel is not null)
  BEGIN
    -- TEST
    --PRINT '@current_orgentrykey';
    --PRINT @current_orgentrykey;
    --PRINT '@current_orgentryparentkey';
    --PRINT @current_orgentryparentkey;
    --PRINT '@current_orglevel';
    --PRINT @current_orglevel;

    if (@current_orglevel = @i_anscestororglevelkey)
    BEGIN
        set @o_ancestororgentrykey = @current_orgentrykey
	return 0;
    END 
 
    set @current_orglevel = null;
    select @current_orgentrykey = orgentrykey, @current_orglevel = orglevelkey,  @current_orgentryparentkey = orgentryparentkey  from orgentry where orgentrykey = @current_orgentryparentkey;
  END

  set @o_ancestororgentrykey = null
  return -1;


GO

GRANT EXEC ON orgentry_find_ancestor_orgentrykey TO PUBLIC

GO

PRINT 'STORED PROCEDURE : orgentry_find_ancestor_orgentrykey complete'
GO

