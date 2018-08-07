IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'WK_InsertPrefixCodeToSubGentables')
  BEGIN
    PRINT 'Dropping Procedure WK_InsertPrefixCodeToSubGentables'
    DROP  Procedure  WK_InsertPrefixCodeToSubGentables
  END
GO

PRINT 'Creating Procedure WK_InsertPrefixCodeToSubGentables'
GO

CREATE PROCEDURE dbo.WK_InsertPrefixCodeToSubGentables
 @isbnPrefixCode    VARCHAR(50),
 @o_exists          VARCHAR(7) OUTPUT
AS

  DECLARE @nextDataSubCode    INT
  
BEGIN

select @o_exists = COUNT(*) from subgentables where tableid = 138 and datacode = 1 and datadesc = @isbnPrefixCode

if @o_exists = 0
  BEGIN

    SELECT @nextDataSubCode =  MAX(datasubcode) FROM subgentables WHERE (tableid = 138) AND (datacode = 1) 
    SET @nextDataSubCode = @nextDataSubCode + 1

    INSERT INTO subgentables (  tableid, 
                                datacode, 
                                datasubcode, 
                                datadesc, 
                                deletestatus,
                                tablemnemonic) 
    VALUES (138, 
            1,
            @nextDataSubCode,
            @isbnPrefixCode, 
            'N',    
            'ISBNPrefix' )

  END

select @o_exists = COUNT(*) from subgentables where tableid = 138 and datacode = 1 and datadesc = @isbnPrefixCode
    
END
