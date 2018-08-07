IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'WK_GetImprintOrgEntryKeyByPublisherID')
  BEGIN
    PRINT 'Dropping Procedure WK_GetImprintOrgEntryKeyByPublisherID'
    DROP  Procedure  WK_GetImprintOrgEntryKeyByPublisherID
  END
GO

PRINT 'Creating Procedure WK_GetImprintOrgEntryKeyByPublisherID'
GO

CREATE PROCEDURE dbo.WK_GetImprintOrgEntryKeyByPublisherID
 @publisherID          integer
AS

  DECLARE @imprintOrgEntry    INT
  
BEGIN

SELECT @imprintOrgEntry = [pss_imprint_orgentrykey]
  FROM [WK_DEV].[dbo].[WK_PUBLISHER_DISTRIBUTOR]
  where publisher_distributor_id = @publisherID
  
  SELECT @imprintOrgEntry as imprintOrgEntry
  
END
