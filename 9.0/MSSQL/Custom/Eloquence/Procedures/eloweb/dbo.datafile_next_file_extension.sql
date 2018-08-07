PRINT 'STORED PROCEDURE : datafile_next_file_extension'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'datafile_next_file_extension')
  BEGIN
    PRINT 'Dropping Procedure datafile_next_file_extension'
    DROP  Procedure  dbo.datafile_next_file_extension
  END

GO

PRINT 'Creating Procedure datafile_next_file_extension'
GO
CREATE Procedure dbo.datafile_next_file_extension
    @i_eloquencecustomerid           char(6),
    @o_file_extension                char(3)     output,
    @o_error_code                    int         output,
    @o_error_desc                    varchar(200)   output 
AS

/******************************************************************************
**  File: datafile_next_file_extension.sql
**  Name: datafile_next_file_extension
**  Desc: This stored procedure updates the next file extention if one exists
**        otherwise it creates a new file extention for the given eloquence
**        customer. 
**
**    Auth: James P. Weber
**    Date: 19 Aug 2003
**    
*******************************************************************************/

DECLARE @initial_extension char(3);
SET @initial_extension = 'AAA';

DECLARE @rowKey char(6);

BEGIN TRANSACTION

SET @o_file_extension = null;
SELECT @rowKey = fd.eloqcustomerid, @o_file_extension = fd.exportfileextension from filedata fd where fd.eloqcustomerid =  @i_eloquencecustomerid;

-- DEBUG
--PRINT '@rowKey';
--PRINT @rowKey;

IF (@rowKey IS NULL)
BEGIN
  -- DEBUG
  -- PRINT 'Creating new';

  -- Simpley create the new string an insert it into the 
  -- 
  SET @o_file_extension = @initial_extension;
  insert into filedata (eloqcustomerid, exportfileextension) VALUES
	  (@i_eloquencecustomerid, @o_file_extension);
END
ELSE IF (@o_file_extension is null)
BEGIN
  -- DEBUG
  --PRINT 'Updating null entry';

  UPDATE filedata SET exportfileextension = @initial_extension where eloqcustomerid =  @rowKey;

END
ELSE
BEGIN
  -- DEBUG
  --PRINT '@o_file_extension';
  --PRINT @o_file_extension;

  DECLARE @notDone bit;
  SET @notDone = 1;

  DECLARE @column_to_modify int;
  SET @column_to_modify = 3;

  DECLARE @modified_char char(1);

  -- Complete the roll over completely case.
  if (@o_file_extension = 'ZZZ')
  BEGIN
    SET @o_file_extension = @initial_extension; 
    SET @notDone = 0;
    update filedata set exportfileextension = @o_file_extension where eloqcustomerid = @i_eloquencecustomerid;
  END
  ELSE
  BEGIN

    WHILE (@notDone = 1)
    BEGIN    

      SET @modified_char = substring(@o_file_extension, @column_to_modify, 1);
      DECLARE @char_as_int int;
      SET @char_as_int = ASCII(@modified_char);
      SET @char_as_int = @char_as_int + 1;
   
      if (@char_as_int < 91)
      BEGIN
        SET @o_file_extension = SUBSTRING(@o_file_extension, 1, @column_to_modify - 1) + CHAR(@char_as_int) + SUBSTRING(@initial_extension, @column_to_modify, 3 - @column_to_modify ); 
        UPDATE filedata set exportfileextension = @o_file_extension WHERE eloqcustomerid = @i_eloquencecustomerid;
        SET @notDone = 0;
      END
      ELSE
      BEGIN
        -- DEBUG
        --PRINT 'ROLL OVER';
        --PRINT '@modified_char';      
        --PRINT @modified_char;      
        --PRINT '@char_as_int';
        --PRINT @char_as_int;

        -- The current column had a z or bigger, move to the next column to the left.
        SET @column_to_modify = @column_to_modify - 1
      END

    END  --  While

  END 

END

-- DEBUG Related.
--select * from filedata;
--PRINT '@char_as_int';
--PRINT @char_as_int;

COMMIT TRANSACTION
GO

GRANT EXEC ON datafile_next_file_extension TO PUBLIC
GO


PRINT 'STORED PROCEDURE : datafile_next_file_extension complete'
GO



