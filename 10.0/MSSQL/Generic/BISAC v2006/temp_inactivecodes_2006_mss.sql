IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_inactivecodes_29_2') AND type = 'U')
  BEGIN
    DROP table temp_inactivecodes_29_2
  END
go

CREATE TABLE temp_inactivecodes_29_2 (
	Code char(255),
   Literal char(255))
go

INSERT INTO temp_inactivecodes_29_2 VALUES (
	'JNF049050',
	'Religion / Bible / Study')
go
INSERT INTO temp_inactivecodes_29_2 VALUES (
	'FIC017000',
	'Interactive')
go
INSERT INTO temp_inactivecodes_29_2 VALUES (
	'REL006170',
	'Bible / Stories / General')
go
INSERT INTO temp_inactivecodes_29_2 VALUES (
	'REL006180',
	'Bible / Stories / Old Testament')
go
INSERT INTO temp_inactivecodes_29_2 VALUES (
	'REL006190',
	'Bible / Stories / New Testament')
go
INSERT INTO temp_inactivecodes_29_2 VALUES (
	'REL006200',
	'Bible / Study / General')
go