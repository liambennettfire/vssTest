IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.gentable_by_desc') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.gentable_by_desc 
  END

GO

CREATE PROCEDURE dbo.gentable_by_desc 
  (@Tableid int, @Datadesc varchar(80), 
  @AddInd char(1), @datacode int output) 
AS
  DECLARE @tablemnemonic VARCHAR(40)

--  checks Gentables by description and tableid and returns the datacose
--  if @AddInd = Y a row is inserted and the new datacode returned
--  Note: gentable entries can not be blank so do not check for blanks

BEGIN

  IF (@Datadesc IS NULL) OR (@Datadesc = '')
    BEGIN
      SELECT @datacode = NULL
    END
  ELSE
    BEGIN
      SELECT @datacode = NULL
      
      SELECT @datacode = datacode
        FROM gentables
       WHERE tableid = @Tableid AND
             UPPER(datadesc) = UPPER(@Datadesc)
      
      IF (@datacode IS NULL) AND (UPPER(@AddInd) = 'Y')
        BEGIN
          SELECT @datacode = MAX(datacode) + 1
            FROM gentables
           WHERE tableid=@Tableid
        
          IF @datacode IS NULL
            SET @datacode = 1
        
          SELECT @tablemnemonic = tablemnemonic
            FROM gentablesdesc
           WHERE tableid = @Tableid
        
          INSERT gentables
            (tableid, datacode, datadesc, tablemnemonic, lastuserid, lastmaintdate)
          VALUES
            (@Tableid, @datacode, @Datadesc, @tablemnemonic, 'gentable_by_desc', getdate() )
        END
    END
END
  
GO

GRANT EXECUTE ON dbo.gentable_by_desc TO PUBLIC

GO