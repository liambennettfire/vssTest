PRINT 'STORED PROCEDURE : bookcomments_to_bookcommentsrtf'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'bookcomments_to_bookcommentsrtf')
	BEGIN
		PRINT 'Dropping Procedure bookcomments_to_bookcommentsrtf'
		DROP  Procedure  bookcomments_to_bookcommentsrtf
	END

GO

PRINT 'Creating Procedure bookcomments_to_bookcommentsrtf';
GO

CREATE Procedure bookcomments_to_bookcommentsrtf

AS

/******************************************************************************
** File: bookcomments_to_bookcommentsrtf.sql
** Name: bookcomments_to_bookcommentsrtf
** Desc: This stored procedure is designed to take the plain text version of the
**       comments for this and create additional entries to go into the RTF table.
**
**       This is designed to work in conjunction with the import of items 
**       as done in the stored procedure xxxx, 
**       any other imports that match this symatics can use the routine.
**
**       This means that tempkey1 must be a valid value and 
**       tempkey2 is replaced with -1 to indicate that the new values
**       are for insertion into the bookcommentrtf table.  If there was
**       a standard code, it would have been used instead of -1.
**
** Auth: James P. Weber
** Date: 27 Jul 2003
*******************************************************************************/

BEGIN

  DECLARE @ReplacementForCRLF varchar(300);
  DECLARE @ReplacementForTab  varchar(300);
  DECLARE @Prefix             varchar(2000);
  DECLARE @Postfix            varchar(2000);

  SET @ReplacementForCRLF = '}{\par}\pard\ql\li0\fi0\ri0{\f0\fs20\cf0\up0\dn0 ';
  SET @ReplacementForTab = '}{\f0\fs20\cf0\up0\dn0\tab}{\f0\fs20\cf0\up0\dn0 ';
  SET @Prefix = '{\rtf1\ansi\deff0{\fonttbl{\f0\froman Tms Rmn;}}{\colortbl\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue127;\red0\green127\blue127;\red0\green127\blue0;\red127\green0\blue127;\red127\green0\blue0;\red127\green127\blue0;\red127\green127\blue127;\red192\green192\blue192}{\info{\creatim\yr2003\mo7\dy28\hr10\min29\sec14}{\version1}{\vern262367}}\paperw12240\paperh15840\margl360\margr4320\margt239\margb0\deftab720\pard\ql\li0\fi0\ri0{\f0\fs20\cf0\up0\dn0 ';
  SET @Postfix = '}}';


  INSERT into importtext (transactionkey, tempkey1, tempkey2, tempkey3, tempkey4, textvalue, lastmaintdate)  
     select transactionkey = @@SPID, tempkey1=tempkey1, tempkey2=-1, tempkey3=tempkey3, tempkey4=tempkey4, textvalue=textvalue, lastmaintdate=getdate() from importtext where transactionkey=@@SPID and tempkey2=0;

  -- Test
  --select * from importtext where transactionkey = @@SPID;

  DECLARE @val varbinary(16)
  DECLARE @Count int;
  SET     @Count = 1;
  DECLARE @TransactionKeyValue int;
  DECLARE @TempKey1Value int;
  DECLARE @TempKey2Value int;
  DECLARE @ImportTextKey int;
  DECLARE @PatternIndex int;
  DECLARE @PatternPosition int;


  DECLARE rtf_cursor CURSOR FOR
    SELECT textptr(importtext.textvalue), tempkey1, tempkey2, importtextkey FROM importtext where transactionkey = @@SPID and tempkey2= -1;

  open rtf_cursor

  FETCH NEXT FROM rtf_cursor INTO 
          @val, @TempKey1Value, @TempKey2Value, @ImportTextKey
        
  
  WHILE @@FETCH_STATUS = 0  
  BEGIN
    -- Test
    --PRINT '@Count';
    --PRINT @Count;
    
    SET @Count = @Count + 1;

    -- Test
    --PRINT '@TempKey1Value';
    --PRINT @TempKey1Value;
    --PRINT '@TempKey2Value';
    --PRINT @TempKey2Value;

    SELECT @PatternIndex = PATINDEX('%' +  CHAR(13) + CHAR(10) + '%', importtext.textvalue)
      FROM  importtext
      WHERE importtextkey = @ImportTextKey;

    WHILE (@PatternIndex != 0)
    BEGIN 
      -- Test
      --PRINT 'CRLF';
      --PRINT '@TempString';
      --PRINT @TempString;
      --PRINT '@PatternIndex'
      --PRINT @PatternIndex;

      SET @PatternPosition = @PatternIndex-1;

      UPDATETEXT importtext.textvalue @val @PatternPosition 2 @ReplacementForCRLF 
      SET @PatternIndex = 0;
      SELECT @PatternIndex = PATINDEX('%' +  CHAR(13) + CHAR(10) + '%', importtext.textvalue)
        FROM  importtext
        WHERE importtextkey = @ImportTextKey;
    END


    -- Fix for line feeds only.
    SELECT @PatternIndex = PATINDEX('%' + CHAR(10) + '%', importtext.textvalue)
      FROM  importtext
      WHERE importtextkey = @ImportTextKey;

    WHILE (@PatternIndex != 0)
    BEGIN 
      -- Test
      --PRINT 'Line Feed';
      --PRINT '@PatternIndex'
      --PRINT @PatternIndex;

      SET @PatternPosition = @PatternIndex-1;

      UPDATETEXT importtext.textvalue @val @PatternPosition 1 @ReplacementForCRLF

      -- Test
      --SELECT * FROM  importtext
      --  WHERE importtextkey = @ImportTextKey;

      SET @PatternIndex = 0;
      SELECT @PatternIndex = PATINDEX('%' + CHAR(10) + '%', importtext.textvalue)
        FROM  importtext
        WHERE importtextkey = @ImportTextKey;
    END

    -- Carriage returns 
    SELECT @PatternIndex = PATINDEX('%' + CHAR(13) + '%', importtext.textvalue)
      FROM  importtext
      WHERE importtextkey = @ImportTextKey;

    WHILE (@PatternIndex != 0)
    BEGIN 
      -- Test
      --PRINT 'Carriage return';
      --PRINT '@PatternIndex'
      --PRINT @PatternIndex;

      SET @PatternPosition = @PatternIndex-1;

      UPDATETEXT importtext.textvalue @val @PatternPosition 1 @ReplacementForCRLF 
      SET @PatternIndex = 0;
      SELECT @PatternIndex = PATINDEX('%' + CHAR(13) + '%', importtext.textvalue)
        FROM  importtext
        WHERE importtextkey = @ImportTextKey;
    END


    -- Fix for TABS
    SELECT @PatternIndex = PATINDEX('%' + CHAR(9) + '%', importtext.textvalue)
      FROM  importtext
      WHERE importtextkey = @ImportTextKey;

    WHILE (@PatternIndex != 0)
    BEGIN 
      -- Test
      --PRINT 'TAB';
      --PRINT '@PatternIndex'
      --PRINT @PatternIndex;

      SET @PatternPosition = @PatternIndex-1;
      UPDATETEXT importtext.textvalue @val @PatternPosition 1 @ReplacementForTab 

      SELECT @PatternIndex = PATINDEX('%' + CHAR(9) + '%', importtext.textvalue)
        FROM  importtext
        WHERE importtextkey = @ImportTextKey;
    END


    UPDATETEXT importtext.textvalue @val 0 0 @Prefix 
    UPDATETEXT importtext.textvalue @val null 0 @Postfix 


    FETCH NEXT FROM rtf_cursor INTO 
          @val, @TempKey1Value, @TempKey2Value, @ImportTextKey


  END


  close rtf_cursor;
  deallocate rtf_cursor;

-- Test
--select * from importtext where transactionkey = @@SPID and tempkey2= -1;





END

GO

GRANT EXEC ON bookcomments_to_bookcommentsrtf TO PUBLIC
GO

PRINT 'STORED PROCEDURE : bookcomments_to_bookcommentsrtf complete'
GO
