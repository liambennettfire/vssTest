-- remove qsicode set by original version of this sql and readd because may be incorrect
  UPDATE datetype
     SET qsicode = null
   WHERE datetypecode = 505 and qsicode = 16

  UPDATE datetype
     SET qsicode = 16
   WHERE lower(rtrim(ltrim(description))) = 'approve asset'
go