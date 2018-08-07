UPDATE subgentables
   SET datadescshort = NULL,
       lastmaintdate = GETDATE(),
       lastuserid = 'FB_UPDATE_34314'
 WHERE tableid = 138
   AND datadescshort IS NOT NULL
go