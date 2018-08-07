IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2013') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2013
  END
go

CREATE TABLE temp_replacement_codes_2013 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT INTO temp_replacement_codes_2013 VALUES (
	'FAM010000',
	'FAMILY & RELATIONSHIPS / Parenting / Child Rearing',
	2012,
	'FAM034000')
go

INSERT INTO temp_replacement_codes_2013 VALUES (
	'FAM018000',
	'FAMILY & RELATIONSHIPS / Emotions',
	2012,
	'SEL042000')
go

INSERT INTO temp_replacement_codes_2013 VALUES (
	'JNF012020',
	'JUVENILE NONFICTION / Computers / Hardware',
	2012,
	'JNF012000')
go

INSERT INTO temp_replacement_codes_2013 VALUES (
	'PSY018000',
	'PSYCHOLOGY / Mental Illness',
	2012,
	'PSY022000')
go


