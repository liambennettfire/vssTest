--BASIC P&L Template Search Criteria  33
--BASIC Specification Template Search Criteria  84
--BASIC Task Group Criteria  44
--BASIC Task View Criteria  41
--BASIC Scale Search Criteria  63

UPDATE qse_searchlist  
   SET autofindind = 1,
       lastuserid = 'FB_UPDATE_34636',
       lastmaintdate = GETDATE()
 WHERE listkey in (33,84,44,41,63)
   AND (autofindind = 0 OR autofindind IS NULL)
go