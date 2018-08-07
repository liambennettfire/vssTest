UPDATE gentables
   SET eloquencefieldtag = '03',
       bisacdatacode = '03',
	   acceptedbyeloquenceind = 1,
	   exporteloquenceind = 1,
	   lastuserid = 'FB_UPDATE_49979',
	   lastmaintdate = getdate()
 WHERE tableid = 551    -- ProductID
   AND qsicode = 9
   AND datadesc = 'EAN-13'
go