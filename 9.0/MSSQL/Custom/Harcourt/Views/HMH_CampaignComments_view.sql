if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[campaigncomments_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[campaigncomments_view]
GO

CREATE VIEW campaigncomments_view AS
	SELECT t.taqprojectkey 'Campaign ID',
	       tc.commentkey 'Comment ID', 
	       q.commenttext,commenthtml,commenthtmllite
      FROM qsicomments q, taqproject t, taqprojectcomments tc
     WHERE t.taqprojectkey = tc.taqprojectkey
       AND tc.commentkey = q.commentkey
       AND t.searchitemcode = 3 
       AND t.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode =9) -- Marketing Campaign
		
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[campaigncomments_view]  TO [public]
GO

select * from [campaigncomments_view]