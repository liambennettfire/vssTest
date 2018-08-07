IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2014') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2014
  END
go

CREATE TABLE temp_replacement_codes_2014 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021000',
	'BIBLES / Today''s New International Version / General',
	2013,
	'BIB018000')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021010',
	'BIBLES / Today''s New International Version / Children',
	2013,
	'BIB018010')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021020',
	'BIBLES / Today''s New International Version / Devotional',
	2013,
	'BIB018020')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021030',
	'BIBLES / Today''s New International Version / New Testamemt & Portions',
	2013,
	'BIB018030')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021040',
	'BIBLES / Today''s New International Version / Reference',
	2013,
	'BIB018040')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021050',
	'BIBLES / Today''s New International Version / Study',
	2013,
	'BIB018050')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021060',
	'BIBLES / Today''s New International Version / Text',
	2013,
	'BIB018060')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'BIB021070',
	'BIBLES / Today''s New International Version / Youth & Teen',
	2013,
	'BIB018070')
go


INSERT INTO temp_replacement_codes_2014 VALUES (
	'EDU047000',
	'EDUCATION / Driver Education',
	2013,
	'TRA001080
')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'GAM001020',
	'GAMES / Checkers',
	2013,
	'GAM001000')
go

INSERT INTO temp_replacement_codes_2014 VALUES (
	'GAM002020',
	'GAMES / Card Games / Solitaire',
	2013,
	'GAM002000')
go


INSERT INTO temp_replacement_codes_2014 VALUES (
	'JUV032130',
	'JUVENILE FICTION / Sports & Recreation / Roller & In-Line Skating',
	2013,
	'JUV032000')
go


