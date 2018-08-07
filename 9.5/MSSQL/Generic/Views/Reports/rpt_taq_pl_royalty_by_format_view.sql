
GO

/****** Object:  View [dbo].[rpt_taq_pl_royalty_by_format_view]    Script Date: 08/25/2015 14:16:23 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_taq_pl_royalty_by_format_view]'))
DROP VIEW [dbo].[rpt_taq_pl_royalty_by_format_view]
GO


GO

/****** Object:  View [dbo].[rpt_taq_pl_royalty_by_format_view]    Script Date: 08/25/2015 14:16:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

Create view [dbo].[rpt_taq_pl_royalty_by_format_view] as
  SELECT c.taqprojectkey, c.plstagecode,  c.taqversionkey, r.royaltyrate, r.threshold, r.lastthresholdind,
  CASE WHEN f.mediatypecode = 2 and f.mediatypesubcode in (6,26) THEN 'Hardcover'
	   WHEN f.mediatypecode = 2 and f.mediatypesubcode in (20,27) THEN 'Paperback'
	   WHEN f.mediatypecode = 14 THEN 'Ebook'
	   ELSE '?????'
	   END  as format
  FROM taqversionroyaltyrates r, taqversionroyaltysaleschannel c, taqversionformat f
  WHERE r.taqversionroyaltykey = c.taqversionroyaltykey AND
      c.taqprojectformatkey = f.taqprojectformatkey 
  

GO
Grant all on rpt_taq_pl_royalty_by_format_view to public

