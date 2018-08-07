UPDATE gentablesitemtype
   SET sortorder = 1,
       lastuserid = 'FB_UPDATE_34421',
       lastmaintdate = GETDATE()
 WHERE tableid = 636
   AND datacode = (SELECT datacode FROM gentables WHERE tableid = 636 and LOWER(datadesc) = 'specification')
   AND datasubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 636 AND LOWER(datadesc) = 'component list – quantity')
   AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 15) --Purchase Order
   AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 41)  --Purchase Order
go