PRINT 'STORED PROCEDURE : author_match_author'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'author_match_author')
	BEGIN
		PRINT 'Dropping Procedure author_match_author'
		DROP  Procedure  author_match_author
	END

GO

PRINT 'Creating Procedure author_match_author'
GO
CREATE Procedure author_match_author
(
  @i_firstname                   varchar(75) = null,
  @i_lastname                    varchar(75) = null,
  @i_middlename                  varchar(75) = null,
  @i_title                       varchar(80) = null,
  @o_existing_authorkey          int         = null output,
  @o_error_code                  int         output,
  @o_error_desc                  char(200)   output 
)
AS

/******************************************************************************
**		File: author_match_author.sql
**		Name: author_match_author
**		Desc: This stored procedure try's to match an author by making sure
**      that all parameter (null/blank) etc match the request. 
**
**		Return values:  The most recent author key will be returned.
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------							-----------
**
**		Auth: James P. Weber
**		Date: 15 July 2003
*******************************************************************************/

  SET @o_existing_authorkey = null;

  if (@i_firstname is not null)
  BEGIN
    IF (RTRIM(@i_firstname) = '') SET @i_firstname = null;

  END
  
  IF (@i_lastname is not null)
  BEGIN
    IF (RTRIM(@i_lastname) = '') SET @i_lastname = null;
  END
  
  IF (@i_middlename is not null)
  BEGIN
    IF (RTRIM(@i_middlename) = '') SET @i_middlename = null;
  END
  
  IF (@i_title  is not null)
  BEGIN
    IF (RTRIM(@i_title) = '') SET @i_title = null;
  END
  
  --PRINT '@i_firstname';
  --PRINT @i_firstname;
  --PRINT '@i_lastname';
  --PRINT @i_lastname;
  --PRINT '@i_middlename';
  --PRINT @i_middlename;
  --PRINT '@i_title';
  --PRINT @i_title;


  -- This is rather complicated so as to be able to match in he negative sense.  A null or blank must
  -- be the same as the original otherwise Dr. Jones and Jones would be the same, when just searching
  -- for 'Jones'.  I have done this with a series of if statements instead of dynamic sql to see if 
  -- performance is increases by not having to recompile the query each time.  All possible combinations
  -- should exist in this list.  If many more parameters are added, this will no longer be reasonable.
  -- It is almost unreasonable now.

  IF (@i_firstname is null)
  BEGIN
    IF (@i_lastname is null)
    BEGIN
      IF (@i_middlename is null)
      BEGIN
        IF (@i_title is null)
        BEGIN
          SET @o_existing_authorkey = null;
        END
        ELSE
        BEGIN
          select @o_existing_authorkey = authorkey from author where title=@i_title and (firstname is null or firstname = '') and (lastname is null or lastname = '') and (middlename is null or middlename = '') order by authorkey desc;
        END
      END
      ELSE
      BEGIN -- Middle Name not null
        IF (@i_title is null)
        BEGIN
           select @o_existing_authorkey = authorkey from author where middlename = @i_middlename and (firstname is null or firstname = '') and (lastname is null or lastname = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
          select @o_existing_authorkey = authorkey from author where middlename = @i_middlename and title=@i_title and (firstname is null or firstname = '') and (lastname is null or lastname = '') order by authorkey desc;
        END
      END
    END
    ELSE
    BEGIN  -- Last name not null
      IF (@i_middlename is null)
      BEGIN
        IF (@i_title is null) 
        BEGIN
           select @o_existing_authorkey = authorkey from author where lastname = @i_lastname and (firstname is null or firstname = '') and (middlename is null or middlename = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
           select @o_existing_authorkey = authorkey from author where lastname = @i_lastname and title = @i_title and (firstname is null or firstname = '') and (middlename is null or middlename = '') order by authorkey desc;
        END
      END
      ELSE
      BEGIN
        IF (@i_title is null)
        BEGIN
           select @o_existing_authorkey = authorkey from author where lastname = @i_lastname and middlename = @i_middlename and (firstname is null or firstname = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
          select @o_existing_authorkey = authorkey from author where lastname = @i_lastname and middlename = @i_middlename and title=@i_title and (firstname is null or firstname = '') order by authorkey desc ;
        END
      END
    END   
  END
  ELSE
  BEGIN -- First name is not null
    IF (@i_lastname is null)
    BEGIN
      IF (@i_middlename is null)
      BEGIN
        IF (@i_title is null)
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and (lastname is null or lastname = '') and (middlename is null or middlename = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and title = @i_title and (lastname is null or lastname = '') and (middlename is null or middlename = '') order by authorkey desc;
        END
      END
      ELSE
      BEGIN -- Middle name is not null
        IF (@i_title is null)
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and middlename = @i_middlename  and (lastname is null or lastname = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
          select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and middlename = @i_middlename and title=@i_title and (lastname is null or lastname = '') order by authorkey desc;
        END
      END
    END
    ELSE
    BEGIN  -- Last name not null
      IF (@i_middlename is null)
      BEGIN
        IF (@i_title is null) 
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and lastname = @i_lastname  and (middlename is null or middlename = '') and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and lastname = @i_lastname and title = @i_title and (middlename is null or middlename = '') order by authorkey desc;
        END
      END
      ELSE
      BEGIN -- Middle name not null
        IF (@i_title is null)
        BEGIN
           select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and lastname = @i_lastname and middlename = @i_middlename  and (title is null or title = '') order by authorkey desc;
        END
        ELSE
        BEGIN
          select @o_existing_authorkey = authorkey from author where firstname = @i_firstname and lastname = @i_lastname and middlename = @i_middlename and title=@i_title order by authorkey desc; 
        END
      END
    END   
  END


GO

GRANT EXEC ON author_match_author TO PUBLIC

GO

PRINT 'STORED PROCEDURE : author_match_author complete'
GO

