IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'WK_GetParentOrgEntryKey')
  BEGIN
    PRINT 'Dropping Procedure WK_GetParentOrgEntryKey'
    DROP  Procedure  WK_GetParentOrgEntryKey
  END
GO

PRINT 'Creating Procedure WK_GetParentOrgEntryKey'
GO

CREATE PROCEDURE dbo.WK_GetParentOrgEntryKey
 @orgEntryKey          integer
AS

  DECLARE @orglevelkey			INT
  DECLARE @orgentryparentkey	INT
  DECLARE @orgEntryDesc			varchar(100)
  
BEGIN

SELECT @orgEntryKey = orgEntryKey, @orglevelkey = orglevelkey, @orgEntryDesc = orgentrydesc, @orgentryparentkey = orgentryparentkey from orgentry where orgentrykey = @orgEntryKey
  
SELECT @orgEntryKey as orgEntryKey, @orglevelkey as imprintOrgEntry, @orgEntryDesc as orgEntryDesc, @orgentryparentkey as orgentryparentkey
  
END
 