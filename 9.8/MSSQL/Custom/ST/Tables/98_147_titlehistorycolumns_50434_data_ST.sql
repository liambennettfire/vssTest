UPDATE titlehistorycolumns
   SET workfieldind = 1
 WHERE tablename = 'bookmisc'
   AND columndescription like 'Miscellaneous Item%'
   AND workfieldind = 0
GO

DISABLE TRIGGER ST_Propogate_MiscFields ON bookmisc;  
GO  