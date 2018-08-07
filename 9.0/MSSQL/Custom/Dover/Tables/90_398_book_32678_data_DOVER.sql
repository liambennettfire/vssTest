UPDATE book
   SET usageclasscode = 2,
       lastuserid = 'FB_32678_cleanup',
       lastmaintdate = GETDATE()
 WHERE linklevelcode = 30
   AND (usageclasscode IN (0,1))
go
