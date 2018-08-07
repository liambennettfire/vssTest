IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2011') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2011
  END
go

CREATE TABLE temp_replacement_codes_2011 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT INTO temp_replacement_codes_2011 VALUES (
	'HEA026000',
	'HEALTH & FITNESS / Naprapathy',
	2010,
	'HEA032000')
go
