-- datetypecode of 32 is for Release Date and is used that way in trigger core_bookdates 
UPDATE datetype SET qsicode = 33 WHERE datetypecode = 32
GO