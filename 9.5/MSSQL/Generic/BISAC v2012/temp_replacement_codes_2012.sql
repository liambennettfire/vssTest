IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2012') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2012
  END
go

CREATE TABLE temp_replacement_codes_2012 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT INTO temp_replacement_codes_2012 VALUES (
	'COM060060',
	'COMPUTERS / Web / Page Design',
	2011,
	'COM060130')
go

INSERT INTO temp_replacement_codes_2012 VALUES (
	'COM069010',
	'COMPUTERS / Online Services / Resource Directories',
	2011,
	'COM069000')
go

INSERT INTO temp_replacement_codes_2012 VALUES (
	'FIC020000',
	'FICTION / Men’s Adventure',
	2011,
	'FIC002000')
go

INSERT INTO temp_replacement_codes_2012 VALUES (
	'OCC036020',
	'BODY, MIND & SPIRIT / Spirituality / Paganism & Neo-Paganism',
	2011,
	'REL117000')
go

INSERT INTO temp_replacement_codes_2012 VALUES (
	'PET006010',
	'PETS / Horses / Riding',
	2011,
	'SPO057000')
go
