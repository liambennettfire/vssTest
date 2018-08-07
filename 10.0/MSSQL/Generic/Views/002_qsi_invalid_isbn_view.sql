if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qsi_invalid_isbn_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[qsi_invalid_isbn_view]
GO

CREATE VIEW qsi_invalid_isbn_view AS
SELECT b.bookkey, b.title, i.eanprefixcode, i.isbnprefixcode,
  i.isbn, i.isbn10, i.ean, i.ean13, i.gtin, i.gtin14,
  v.isbn_checkdigit, v.correct_isbn_checkdigit,
  v.ean_checkdigit, v.correct_ean_checkdigit, 
  i.lastuserid, i.lastmaintdate,
  CASE
    WHEN LEN(i.isbn) <> 13 THEN 'Invalid ISBN length - must be 13.'
    WHEN LEN(i.isbn10) <> 10 THEN 'Invalid ISBN10 length - must be 10.'
    WHEN LEN(i.ean) <> 17 THEN 'Invalid EAN length - must be 17.'
    WHEN LEN(i.ean13) <> 13 THEN 'Invalid EAN13 length - must be 13.'
    WHEN LEN(i.gtin) <> 19 THEN 'Invalid GTIN length - must be 19.'
    WHEN LEN(i.gtin14) <> 14 THEN 'Invalid GTIN14 length - must be 14.'
    WHEN v.isbnprefix <> v.isbnprefixcode_datadesc THEN 'Invalid isbnprefixcode or ISBN hyphenation - based on isbnprefixcode, correct ISBN Prefix is ' + v.isbnprefixcode_datadesc + '.'
    WHEN i.eanprefixcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 138) THEN 'UNKNOWN eanprefixcode ' + CONVERT(VARCHAR, i.eanprefixcode) + ' - only 978 and 979 EAN Prefixes are valid for books.'
    WHEN i.eanprefixcode IN (SELECT datacode FROM gentables WHERE tableid = 138 AND datadesc <> '978' AND datadesc <> '979') THEN 'UNKNOWN eanprefixcode ' + CONVERT(VARCHAR, i.eanprefixcode) + ' - only 978 and 979 EAN Prefixes are valid for books.'
    WHEN i.isbnprefixcode NOT IN (SELECT datasubcode FROM subgentables WHERE tableid = 138 AND datacode = i.eanprefixcode) THEN 'UNKNOWN isbnprefixcode ' + CONVERT(VARCHAR, i.isbnprefixcode) + ' - ISBN Prefix ' + v.isbnprefix + ' is not found for EAN Prefix ' + (SELECT datadesc FROM gentables WHERE tableid = 138 AND datacode = i.eanprefixcode) + '.'
    WHEN v.is_isbnprefixcode_valid = 0 THEN 'Invalid ISBN Prefix ' + v.isbnprefix + (SELECT ':  ' + message FROM isbnprefixvalidation WHERE tableid = 138 AND datacode = i.eanprefixcode AND datasubcode = i.isbnprefixcode)
    WHEN v.isbn_checkdigit <> correct_isbn_checkdigit THEN 'Invalid ISBN checkdigit.'
    WHEN v.ean_checkdigit <> correct_ean_checkdigit THEN 'Invalid EAN checkdigit.'
    ELSE 'OTHER ERROR'
  END error_message
FROM qsi_isbn_view v, book b, isbn i
WHERE v.bookkey = b.bookkey AND
  v.bookkey = i.bookkey AND 
    (v.isbn_checkdigit <> v.correct_isbn_checkdigit OR 
    v.ean_checkdigit <> v.correct_ean_checkdigit OR 
    v.is_isbnprefixcode_valid = 0 OR 
    v.correct_isbnprefixcode = 0 OR
    v.isbnprefix <> v.isbnprefixcode_datadesc)
go

GRANT SELECT ON qsi_invalid_isbn_view TO public
go
