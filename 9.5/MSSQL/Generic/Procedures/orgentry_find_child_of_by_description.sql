PRINT 'STORED PROCEDURE : orgentry_find_child_of_by_description'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'orgentry_find_child_of_by_description')
	BEGIN
		PRINT 'Dropping Procedure orgentry_find_child_of_by_description'
		DROP  Procedure  orgentry_find_child_of_by_description
	END

GO

PRINT 'Creating Procedure orgentry_find_child_of_by_description'
GO
CREATE Procedure orgentry_find_child_of_by_description
(
  @i_parent_orgentrykey         int,
  @i_orgentrydesc               varchar(40),
  @o_found_orgentrykey          int         output,
  @o_error_code                 int         output,
  @o_error_desc                 char(200)   output 
)
AS

/******************************************************************************
**		File: orgentry_find_child_of_by_description.sql
**		Name: orgentry_find_child_of_by_description
**		Desc: This stored procedure finds a child of the specified
**            organization that has the specified name.
**
**		This template can be customized:
**              
**		Return values:
**               
**
**		Auth: James P. Weber
**		Date: 09 Jul 2003
**    
*******************************************************************************/

  DECLARE @current_orgentrykey int;        -- temp storage
  DECLARE @temp_error_code int;
  DECLARE @temp_error_desc varchar(200);
  DECLARE @level_of_proposed_parent_key int;
  DECLARE @test varchar(200)

  SET @level_of_proposed_parent_key = null;
  select @level_of_proposed_parent_key = orglevelkey from orgentry where orgentrykey = @i_parent_orgentrykey;

  if (@level_of_proposed_parent_key is not null)
  BEGIN
    DECLARE orgentry_cursor cursor for 
    select orgentrykey from orgentry where orgentry.orgentrydesc = @i_orgentrydesc 
  
    OPEN orgentry_cursor;

    FETCH NEXT FROM orgentry_cursor INTO @current_orgentrykey
    
    SET @o_error_code = -1;
    -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
    WHILE @@FETCH_STATUS = 0
    BEGIN
      --print '@current_orgentrykey';
      --print @current_orgentrykey
      --print '@test'
      --print @test

      DECLARE @current_proposed_parent int;
      exec orgentry_find_ancestor_orgentrykey @level_of_proposed_parent_key, @current_orgentrykey, @current_proposed_parent out, @temp_error_code out, @temp_error_desc out 
      if (@current_proposed_parent = @i_parent_orgentrykey)
      BEGIN
        --print 'Parent Found'
        SET @o_found_orgentrykey = @current_orgentrykey;
        SET @o_error_code = 0;
        BREAK;
        
      END
      FETCH NEXT FROM orgentry_cursor INTO @current_orgentrykey
    END 
  END
  ELSE
  BEGIN
    set @o_error_code = -1;
    set @o_error_desc = 'Proposed parent orgentrykey does not exist';
  END

  close orgentry_cursor;
  deallocate orgentry_cursor;
  return @o_error_code;


GO

GRANT EXEC ON orgentry_find_child_of_by_description TO PUBLIC

GO


PRINT 'STORED PROCEDURE : orgentry_find_child_of_by_description complete'
GO

