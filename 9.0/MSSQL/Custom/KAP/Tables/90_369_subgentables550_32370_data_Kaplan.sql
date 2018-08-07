UPDATE subgentables
   SET deletestatus = 'Y'
 WHERE tableid = 550
   AND qsicode in (26,27) --Title, Set
go