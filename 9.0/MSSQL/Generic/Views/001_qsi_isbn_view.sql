if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qsi_isbn_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[qsi_isbn_view]
GO

CREATE VIEW qsi_isbn_view AS
SELECT bookkey, ean, isbn, lastuserid, lastmaintdate,
  CASE
    WHEN CHARINDEX('-', isbn) > 0 AND LEN(isbn) = 13 THEN SUBSTRING(isbn, 1, (CHARINDEX('-', isbn) -1)) 
    ELSE NULL
  END isbngroup,
  CASE
    WHEN CHARINDEX('-', isbn) > 0 AND LEN(isbn) = 13 THEN SUBSTRING(isbn, CHARINDEX('-', isbn) +1, CHARINDEX('-', isbn, (CHARINDEX('-', isbn) +1)) - (CHARINDEX('-', isbn) +1))
    ELSE NULL
  END pubprefix,
  CASE
    WHEN CHARINDEX('-', isbn) > 0 AND LEN(isbn) = 13 THEN SUBSTRING(isbn, 1, CHARINDEX('-', isbn, (CHARINDEX('-', isbn) +1)) -1) 
    ELSE NULL
  END isbnprefix,
  (SELECT isbnprefix FROM isbnprefixvalidation WHERE tableid = 138 AND datacode = eanprefixcode AND datasubcode = isbnprefixcode) isbnprefixcode_datadesc,
  (SELECT isvalid FROM isbnprefixvalidation WHERE tableid = 138 AND datacode = eanprefixcode AND datasubcode = isbnprefixcode) is_isbnprefixcode_valid,
  (SELECT pubprefixlength FROM isbnprefixvalidation WHERE tableid = 138 AND datacode = eanprefixcode AND datasubcode = isbnprefixcode) correct_pubprefixlength,
  isbnprefixcode,
  CASE
    WHEN CHARINDEX('-', isbn) > 0 AND LEN(isbn) = 13 THEN
    CASE
      WHEN SUBSTRING(isbn, 1, CHARINDEX('-', isbn, (CHARINDEX('-', isbn) +1)) -1) IN (SELECT datadesc FROM subgentables WHERE tableid = 138 AND datacode = eanprefixcode AND lastuserid <> 'QSI_DUP') THEN (SELECT datasubcode FROM subgentables WHERE tableid = 138 AND datacode = eanprefixcode AND lastuserid <> 'QSI_DUP' AND datadesc = SUBSTRING(isbn, 1, CHARINDEX('-', isbn, (CHARINDEX('-', isbn) +1)) -1) ) 
      ELSE 0
    END
    ELSE 0
  END correct_isbnprefixcode,
  eanprefixcode,
  (SELECT datacode FROM gentables WHERE tableid = 138 AND datadesc = SUBSTRING(ean, 1, 3)) correct_eanprefixcode,
  SUBSTRING(isbn, 13, 1) isbn_checkdigit,
  CASE
    WHEN LEN(isbn) <> 13 THEN '?'
    WHEN CHARINDEX('D', REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) > 0 THEN '?'
    WHEN CHARINDEX('E', REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) > 0 THEN '?'
    WHEN CHARINDEX('-', isbn) = 0 THEN '?'
    WHEN SUBSTRING(isbn, 1, (CHARINDEX('-', isbn) -1)) NOT IN (SELECT isbngroup FROM isbngroup) THEN '?'
    WHEN ISNUMERIC(REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) = 1 THEN dbo.qean_checkdigit(SUBSTRING(isbn, 1, 12), 0)    
    ELSE '?'
  END correct_isbn_checkdigit,
  SUBSTRING(ean, 17, 1) ean_checkdigit,
  CASE LEN(ean)
    WHEN 17 THEN
      CASE
        WHEN CHARINDEX('D', REPLACE(SUBSTRING(ean, 1, 16), '-', '')) > 0 THEN '?'
        WHEN CHARINDEX('E', REPLACE(SUBSTRING(ean, 1, 16), '-', '')) > 0 THEN '?'
        WHEN CHARINDEX('-', ean) = 0 THEN '?'
        WHEN SUBSTRING(ean, 1, (CHARINDEX('-', ean) -1)) NOT IN (SELECT datadesc FROM gentables WHERE tableid = 138) THEN '?'
        WHEN ISNUMERIC(REPLACE(SUBSTRING(ean, 1, 16), '-', '')) = 1 THEN dbo.qean_checkdigit(SUBSTRING(ean, 1, 16), 1)    
        ELSE '?'
      END
    ELSE
      CASE
        WHEN CHARINDEX('D', '978' + REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) > 0 THEN '?'
        WHEN CHARINDEX('E', '978' + REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) > 0 THEN '?'
        WHEN CHARINDEX('-', isbn) = 0 THEN '?'
        WHEN ISNUMERIC(REPLACE(SUBSTRING(isbn, 1, 12), '-', '')) = 1 THEN dbo.qean_checkdigit('978' + SUBSTRING(isbn, 1, 12), 1)    
        ELSE '?'
      END
  END correct_ean_checkdigit  
FROM isbn 
WHERE LEN(isbn) > 1
go

GRANT SELECT ON qsi_isbn_view TO public
go
