UPDATE isbn 
   SET isbn = NULL,
       gtin = NULL,
       gtin14 = NULL,
       lastmaintdate = GETDATE(),
       lastuserid = 'FB_CLEANUP_37441'
 WHERE isbn = '0-7814-3733-4'
   AND bookkey = 2082974
   AND isbnkey = 2082974
   AND ean IS NULL
go

DELETE FROM reuseisbns WHERE isbn = '0-7814-3733-4' AND isbnprefixcode = 1 AND isbnsubprefixcode = 2
GO