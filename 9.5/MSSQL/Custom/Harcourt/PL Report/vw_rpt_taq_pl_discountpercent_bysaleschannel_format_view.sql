/****** Object:  View [dbo].rpt_taq_pl_discountpercent_bysaleschannel_view    Script Date: 04/13/2010 10:12:31 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_discountpercent_bysaleschannel_view'))
DROP VIEW [dbo].rpt_taq_pl_discountpercent_bysaleschannel_view
GO

Create view rpt_taq_pl_discountpercent_bysaleschannel_view as
  SELECT c.taqprojectkey, c.plstagecode,  c.taqversionkey, dbo.get_gentables_desc(118,saleschannelcode,'D') as saleschannel, c.discountpercent,
  CASE WHEN f.mediatypecode = 2 and f.mediatypesubcode in (6,26) THEN 'Hardcover'
	   WHEN f.mediatypecode = 2 and f.mediatypesubcode in (20,27) THEN 'Paperback'
	   WHEN f.mediatypecode = 14 THEN 'Ebook'
	   ELSE '?????'
	   END as format
  FROM taqversionroyaltyrates r, taqversionsaleschannel c, taqversionformat f
  WHERE c.taqprojectformatkey = f.taqprojectformatkey 
  
GO
GRANT ALL ON rpt_taq_pl_discountpercent_bysaleschannel_view to PUBLIC