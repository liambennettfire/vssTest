/****** Object:  View [dbo].rpt_taq_pl_royalty_by_format_view    Script Date: 04/13/2010 10:12:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_royalty_by_format_view'))
DROP VIEW [dbo].rpt_taq_pl_royalty_by_format_view
GO
Create view rpt_taq_pl_royalty_by_format_view as
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
GRANT ALL ON rpt_taq_pl_royalty_by_format_view to PUBLIC