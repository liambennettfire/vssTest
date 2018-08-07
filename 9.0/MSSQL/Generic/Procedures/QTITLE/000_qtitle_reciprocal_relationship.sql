if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_reciprocal_relationship') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_reciprocal_relationship
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_reciprocal_relationship
 (@i_bookkey  integer,
  @i_associatetitlebookkey integer,
  @i_associationtype	integer,
  @i_associationsubtype	integer,
  @i_productidtype		integer,
  @i_action		varchar(1),
  @i_authorkey	integer,
  @i_userid varchar(30),
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_reciprocal_relationship
**  Desc: This stored procedure handles any reciprocal relationships
**
**  Auth: Kusum Basra
**  Date: 10 September 2009
**
** Parameter Options:
**   Action:
**		A = Add
**		D = Delete
**
**  Author Key: populated if procedure called from Author Sales track 
*******************************************************************************/
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_count 		INT
  DECLARE @v_numericdesc1  FLOAT
  DECLARE @v_sortorder INT
  DECLARE @v_datacode INT
  DECLARE @v_datasubcode INT
  DECLARE @v_numericdesc_num int
  DECLARE 
    @v_default_sendtoeloind  TINYINT,
    @v_fielddesc  VARCHAR(80),
    @v_productnumber  VARCHAR(50),
    @v_lastuserid VARCHAR(30),
    @v_sets_clientoption INT,
    @v_tab_qsicode  INT,
    @v_quantity INT,
    @v_volumenumber INT,
    @v_numtitles  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_lastuserid = 'system - ' + @i_userid

  IF @i_action NOT IN ('A','D') 
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Invalid action type parameter - valid = A, D.'
    RETURN
  END
  
  IF @i_authorkey IS NULL
    SET @i_authorkey = 0

  SELECT @v_count = Count(*)
  FROM subgentables
  WHERE tableid = 440 
    AND datacode = @i_associationtype
    AND datasubcode =  @i_associationsubtype

  IF @v_count = 0 AND @i_associationsubtype > 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'No subgentables row found for tableid=440, datacode=' + CONVERT(VARCHAR, @i_associationtype) + 
      ', datasubcode=' + CONVERT(VARCHAR, @i_associationsubtype) + '.'
    RETURN
  END

  SELECT @v_numericdesc1 = s.numericdesc1, @v_tab_qsicode = COALESCE(g.qsicode,0)
  FROM subgentables s, gentables g
  WHERE s.tableid = g.tableid AND
    s.datacode = g.datacode AND
    s.tableid = 440 AND
    s.datacode = @i_associationtype AND
    s.datasubcode =  @i_associationsubtype

  IF @v_numericdesc1 IS NULL
  BEGIN
    RETURN
  END
  
  SET @v_numericdesc_num = CONVERT(INT, @v_numericdesc1)
  
  SELECT @v_count = count(*)
  FROM subgentables
  WHERE tableid = 440 
    AND bisacdatacode = @v_numericdesc_num
    
  IF @v_count > 1
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Reciprocal relationship could not be established. More than one matching BISAC Data Code = ' + cast(@v_numericdesc1 AS VARCHAR) + ' was found.'
    RETURN
  END
  ELSE IF @v_count = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Reciprocal relationship could not be established. No value matching BISAC Data Code = ' + cast(@v_numericdesc1 AS VARCHAR) + ' was found.'
    RETURN
  END

  IF @v_count = 1
  BEGIN
    SELECT @v_datacode = s.datacode, @v_datasubcode = s.datasubcode, @v_default_sendtoeloind = COALESCE(g.gen2ind,0)
    FROM subgentables s, gentables g
    WHERE s.tableid = g.tableid AND
      s.datacode = g.datacode AND
      s.tableid = 440 AND 
      s.bisacdatacode = @v_numericdesc_num

    --print '@v_datacode'
    --print @v_datacode
    --print '@v_datasubcode'
    --print @v_datasubcode

    SET @v_sets_clientoption = 0
    
    IF (SELECT COUNT(*) FROM clientoptions WHERE optionid = 23) > 0
      SELECT @v_sets_clientoption = optionvalue
      FROM clientoptions
      WHERE optionid = 23
  
    -- When using web sets, for set-related tabs, we need to have the same Quantity and Volume # values on the reciprocal records
    SET @v_quantity = NULL
    SET @v_volumenumber = NULL  
    IF @v_sets_clientoption = 2 --web sets
    BEGIN
      IF @v_tab_qsicode = 15 OR @v_tab_qsicode = 16
      BEGIN
        SELECT @v_quantity = quantity, @v_volumenumber = volumenumber
        FROM associatedtitles
        WHERE bookkey = @i_bookkey AND
            associatetitlebookkey = @i_associatetitlebookkey AND
            associationtypecode = @i_associationtype AND
            associationtypesubcode = @i_associationsubtype
            
        -- Get the number of attached in-house titles on the set
        IF @v_tab_qsicode = 15	--Titles in Set
        BEGIN
          SELECT @v_numtitles = COUNT(*)
          FROM associatedtitles 
          WHERE bookkey = @i_bookkey AND
              associationtypecode = @i_associationtype AND 
              associationtypesubcode = @i_associationsubtype AND
              associatetitlebookkey > 0
              
          SELECT @v_count = COUNT(*)
          FROM booksets
          WHERE bookkey = @i_bookkey AND printingkey = 1 AND issuenumber = 1
          
          IF @v_count > 0
            UPDATE booksets
            SET numtitles = @v_numtitles
            WHERE bookkey = @i_bookkey AND printingkey = 1 AND issuenumber = 1
          ELSE
            INSERT INTO booksets
              (bookkey, printingkey, issuenumber, numtitles, setversionbookkey, lastuserid, lastmaintdate)
            VALUES
              (@i_bookkey, 1, 1, @v_numtitles, @i_bookkey, @i_userid, getdate())
        END
        ELSE	--Sets
        BEGIN
          SELECT @v_numtitles = COUNT(*) + 1
          FROM associatedtitles 
          WHERE bookkey = @i_associatetitlebookkey AND
              associationtypecode = @v_datacode AND 
              associationtypesubcode = @v_datasubcode AND
              associatetitlebookkey > 0

          SELECT @v_count = COUNT(*)
          FROM booksets
          WHERE bookkey = @i_associatetitlebookkey AND printingkey = 1 AND issuenumber = 1
          
          IF @v_count > 0
            UPDATE booksets
            SET numtitles = @v_numtitles
            WHERE bookkey = @i_associatetitlebookkey AND printingkey = 1 AND issuenumber = 1
          ELSE
            INSERT INTO booksets
              (bookkey, printingkey, issuenumber, numtitles, setversionbookkey, lastuserid, lastmaintdate)
            VALUES
              (@i_associatetitlebookkey, 1, 1, @v_numtitles, @i_associatetitlebookkey, @i_userid, getdate())   
        END               
      END
    END  --web sets

    SELECT @v_count = COUNT(*)
    FROM associatedtitles
    WHERE bookkey = @i_associatetitlebookkey
      AND associationtypecode = @v_datacode
      AND associationtypesubcode = @v_datasubcode
      AND associatetitlebookkey = @i_bookkey

    IF @i_action = 'A'
    BEGIN

      IF @v_count = 0
      BEGIN
        SELECT @v_sortorder = COALESCE(MAX(sortorder),0)+1
        FROM associatedtitles
        WHERE bookkey = @i_associatetitlebookkey
          AND associationtypecode = @i_associationtype

        -- make sure the author exists for the related title (use @i_bookkey because that is what is saved 
        -- in the associatetitlebookkey column for reverse relationship
        SELECT @v_count = COUNT(*)
        FROM bookauthor
        WHERE bookkey = @i_bookkey  
          AND authorkey = @i_authorkey
          
        SELECT @v_productnumber = 
        CASE (SELECT qsicode FROM gentables WHERE tableid = 551 AND datacode = @i_productidtype)
          WHEN 1 THEN isbn
          WHEN 2 THEN ean
          WHEN 3 THEN gtin
          WHEN 4 THEN upc
          WHEN 6 THEN itemnumber
        END
        FROM isbn
        WHERE bookkey = @i_bookkey

        IF @i_authorkey > 0 AND @v_count > 0
          INSERT INTO associatedtitles
            (bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder,
            lastuserid, lastmaintdate, productidtype, isbn, releasetoeloquenceind, authorkey, quantity, volumenumber)
          VALUES(@i_associatetitlebookkey, @v_datacode, @v_datasubcode, @i_bookkey, @v_sortorder,
            @v_lastuserid, getdate(), @i_productidtype, @v_productnumber, @v_default_sendtoeloind, @i_authorkey, @v_quantity, @v_volumenumber) 
        ELSE
          INSERT INTO associatedtitles
            (bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder,
            lastuserid, lastmaintdate, productidtype, isbn, releasetoeloquenceind, authorkey, quantity, volumenumber)
          VALUES(@i_associatetitlebookkey, @v_datacode, @v_datasubcode, @i_bookkey, @v_sortorder,
            @v_lastuserid, getdate(), @i_productidtype, @v_productnumber, @v_default_sendtoeloind, NULL, @v_quantity, @v_volumenumber) 
      
        -- Write to titlehistory
        SET @v_fielddesc = ltrim(rtrim(dbo.get_subgentables_desc(440, @v_datacode, @v_datasubcode, 'long')))
        EXECUTE qtitle_update_titlehistory 'associatedtitles', 'isbn', @i_associatetitlebookkey, 1, 0,
             @v_productnumber, 'insert', @v_lastuserid, null, @v_fielddesc, @o_error_code output, @o_error_desc output  
      
      END  --IF @v_count=0 (associatedtitles)
      ELSE IF @v_count > 0 AND @v_sets_clientoption = 2 AND (@v_tab_qsicode = 15 OR @v_tab_qsicode = 16)
      BEGIN
        UPDATE associatedtitles
        SET quantity = @v_quantity, volumenumber = @v_volumenumber
        WHERE bookkey = @i_associatetitlebookkey AND
            associatetitlebookkey = @i_bookkey AND
            associationtypecode = @v_datacode AND
            associationtypesubcode = @v_datasubcode
      END
    END --IF @i_action = 'A'

    ELSE  --action is Delete 'D'
    BEGIN
      IF @v_count > 0
      BEGIN
        SELECT @v_productnumber = isbn
        FROM associatedtitles
        WHERE bookkey = @i_associatetitlebookkey
          AND associationtypecode = @v_datacode
          AND associationtypesubcode = @v_datasubcode
          AND associatetitlebookkey = @i_bookkey
      
        DELETE FROM associatedtitles
        WHERE bookkey = @i_associatetitlebookkey
          AND associationtypecode = @v_datacode
          AND associationtypesubcode = @v_datasubcode
          AND associatetitlebookkey = @i_bookkey
        
        SET @v_fielddesc = ltrim(rtrim(dbo.get_subgentables_desc(440, @v_datacode, @v_datasubcode, 'long')))
        EXECUTE qtitle_update_titlehistory 'associatedtitles', 'isbn', @i_associatetitlebookkey, 1, 0,
          @v_productnumber, 'delete', @v_lastuserid , null, @v_fielddesc, @o_error_code output,@o_error_desc output
          
      END --IF @v_count > 0
    END --Delete action
  
  END --IF @v_count=1 (subgentables)
     
  -- Save the @@ERROR in local variable before it's cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error in qtitle_reciprocal_relationship accessing associatedtitles: bookkey=' + cast(@i_bookkey AS VARCHAR) + 
		', associatetitlebookkey=' + CAST(@i_associatetitlebookkey AS VARCHAR) + '.'
  END 
  

GO

GRANT EXEC ON qtitle_reciprocal_relationship TO PUBLIC
GO