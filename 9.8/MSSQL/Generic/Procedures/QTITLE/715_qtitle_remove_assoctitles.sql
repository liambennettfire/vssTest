if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_remove_assoctitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_remove_assoctitles 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_remove_assoctitles
 (@i_bookkey                  integer,
  @i_printingkey              integer,
  @i_associationtypecode      integer,
  @i_associationtypesubcode   integer,
  @i_sortorder                integer,
  @i_userid                   varchar(30),
  @i_reverse_assoctypecode    integer,
  @i_reverse_assoctypesubcode integer,
  @o_associatetitlebookkey    integer output,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_remove_assoctitles
**  Desc: This stored procedure will remove a title relationship between 2 titles.      
**
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of the title from which the relationship is created - Required
**    printingkey - printingkey of title from which the relationship is created - Required
**             (First Printing will be assumed if 0 or null)
**    associationtypecode - datacode of type of relation (tableid 440) - Required
**    associationtypesubcode - datasubcode of type of relation (0 will be used if null)
**    sortorder - CURRENTLY NOT USED (see below 11/13/06)
**    userid - Userid of user removing relationship - Required
**    reverse_assoctypecode - datacode of type of opposite relation (tableid 440) - pass 0 if none
**    reverse_assoctypesubcode - datasubcode of type of relation - pass 0 if none
**    
**    Output
**    -----------
**    associatetitlebookkey - if the productnumber is found on the database, return its bookkey (return 0 if not on database)
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 28 February 2006
**    
**************************************************************************************
**    Change History
**************************************************************************************
**  Date      Author  Modification
**  --------  ------  ---------------------------------------------------------------
**  11/13/06  KW      Took out sortorder input parameter. See case 4370.
**      If Replaces was entered on title A for title B, you could remove association 
**      for both titles only on title A. If you tried to remove these associations 
**      from title B (Replaced By), no rows were deleted. This is because rows for 
**      both directions of given association are inserted with the same sortorder.
**      NOTE: Sortorder may be necessary in the future when we allow multiple rows 
**      with the same associationtypecode/associationtypesubcode. Right now, we only
**      allow 1 to 1 relationship.
*************************************************************************************/

  DECLARE @error_var                  INT,
          @rowcount_var               INT,
          @v_bookkey                  INT,
          @v_printingkey              INT,
          @v_associationtypecode      INT,
          @v_associationtypesubcode   INT,
          @v_reverse_assoctypecode    INT,
          @v_reverse_assoctypesubcode INT,
          @v_sortorder                INT,
          @v_userid                   varchar(30),
          @v_count                    INT,
          @v_associatetitlebookkey    INT,
          @v_assoctypesubcode_desc    varchar(50),
          @v_productnumber  VARCHAR(50)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_bookkey = @i_bookkey
  SET @v_printingkey = @i_printingkey
  SET @v_associationtypecode = @i_associationtypecode
  SET @v_associationtypesubcode = @i_associationtypesubcode
  SET @v_reverse_assoctypecode = @i_reverse_assoctypecode
  SET @v_reverse_assoctypesubcode = @i_reverse_assoctypesubcode
  SET @v_sortorder = @i_sortorder
  SET @v_userid = @i_userid
  SET @o_associatetitlebookkey = 0

  IF @v_bookkey IS NULL OR @v_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: bookkey is empty.'
    RETURN
  END

  IF @v_printingkey IS NULL OR @v_printingkey = 0 BEGIN
    SET @v_printingkey = 1
  END 

  IF @v_associationtypecode IS NULL OR @v_associationtypecode = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: associationtypecode is empty.'
    RETURN
  END 

  IF @v_associationtypesubcode IS NULL BEGIN
    SET @v_associationtypesubcode = 0
  END 

  IF @v_reverse_assoctypecode IS NULL BEGIN
    SET @v_reverse_assoctypecode = 0
  END 

  IF @v_reverse_assoctypesubcode IS NULL BEGIN
    SET @v_reverse_assoctypesubcode = 0
  END

  IF @v_userid IS NULL OR ltrim(rtrim(@v_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create Title Relationship: userid is empty.'
    RETURN
  END 

  -- check to see if this relationship already exists on the database
  SELECT @v_count = count(*) 
    FROM associatedtitles
   WHERE bookkey = @v_bookkey and
         associationtypecode = @v_associationtypecode and
         associationtypesubcode = @v_associationtypesubcode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to verify relationship (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @v_count > 0 BEGIN
    -- get associatetitlebookkey
    SELECT TOP 1 @v_associatetitlebookkey = COALESCE(associatetitlebookkey,0)
      FROM associatedtitles
     WHERE bookkey = @v_bookkey and
           associationtypecode = @v_associationtypecode and
           associationtypesubcode = @v_associationtypesubcode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to get associatetitlebookkey from associatedtitles (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 

    -- need to return associatetitlebookkey because relationship in other direction may exist
    SET @o_associatetitlebookkey = @v_associatetitlebookkey
    
    SELECT @v_productnumber = isbn
    FROM associatedtitles
    WHERE bookkey = @v_bookkey AND
      associationtypecode = @v_associationtypecode AND
      associationtypesubcode = @v_associationtypesubcode AND
      associatetitlebookkey = @v_associatetitlebookkey
      
    -- remove relationship
    DELETE FROM associatedtitles
    WHERE bookkey = @v_bookkey AND
      associationtypecode = @v_associationtypecode AND
      associationtypesubcode = @v_associationtypesubcode AND
      associatetitlebookkey = @v_associatetitlebookkey
           
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to remove relationship (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 

    -- Title History and Send to Eloquence
    SET @v_assoctypesubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(440,@v_associationtypecode,@v_associationtypesubcode,'long')))
    EXECUTE qtitle_update_titlehistory 'associatedtitles','isbn',@v_bookkey,@v_printingkey,0,
                                       @v_productnumber,'delete',@v_userid,null,@v_assoctypesubcode_desc,
                                       @o_error_code output,@o_error_desc output

    IF @o_error_code < 0 BEGIN
      RETURN
    END

    -- try to remove opposite relationship
    IF @v_reverse_assoctypecode > 0 AND @v_associatetitlebookkey > 0 BEGIN
      SELECT @v_productnumber = isbn
      FROM associatedtitles
      WHERE bookkey = @v_associatetitlebookkey AND
        associationtypecode = @v_reverse_assoctypecode AND
        associationtypesubcode = @v_reverse_assoctypesubcode AND
        associatetitlebookkey = @v_bookkey
            
      DELETE FROM associatedtitles
       WHERE bookkey = @v_associatetitlebookkey and
             associationtypecode = @v_reverse_assoctypecode and
             associationtypesubcode = @v_reverse_assoctypesubcode and
             associatetitlebookkey = @v_bookkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to remove opposite relationship (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END 

      -- Title History and Send to Eloquence
      SET @v_assoctypesubcode_desc = ltrim(rtrim(dbo.get_subgentables_desc(440,@v_reverse_assoctypecode,@v_reverse_assoctypesubcode,'long')))
      EXECUTE qtitle_update_titlehistory 'associatedtitles','isbn',@v_associatetitlebookkey,@v_printingkey,0,
                                         @v_productnumber,'delete',@v_userid,null,@v_assoctypesubcode_desc,
                                         @o_error_code output,@o_error_desc output
      
      IF @o_error_code < 0 BEGIN
        RETURN
      END
    END    
  END
GO

GRANT EXEC ON qtitle_remove_assoctitles TO PUBLIC
GO
