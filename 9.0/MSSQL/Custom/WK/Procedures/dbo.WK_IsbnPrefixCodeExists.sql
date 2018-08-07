IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'WK_IsbnPrefixCodeExists')
  BEGIN
    PRINT 'Dropping Procedure WK_IsbnPrefixCodeExists'
    DROP  Procedure  WK_IsbnPrefixCodeExists
  END
GO

PRINT 'Creating Procedure WK_IsbnPrefixCodeExists'
GO

CREATE PROCEDURE dbo.WK_IsbnPrefixCodeExists
 @isbnPrefixCode    VARCHAR(50),
 @o_exists          VARCHAR(7) OUTPUT
AS

--  DECLARE @imprintOrgEntry    INT
  
BEGIN

select @o_exists = COUNT(*) from subgentables where tableid = 138 and datacode = 1 and datadesc = @isbnPrefixCode
    
END
