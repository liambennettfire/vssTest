IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_inactivecodes_2008') AND type = 'U')
  BEGIN
    DROP table temp_inactivecodes_2008
  END
go

CREATE TABLE temp_inactivecodes_2008 (
	Code char(255))
go

/* This is an example - only the code is necessary for the deleted rows */
/*INSERT INTO temp_inactivecodes_2008 VALUES (
	'ANT004000')
go*/

/* Clip Art */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART005000')
go

/* Fashion */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART011000')
go

/* Graphic Arts */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART014000')
go

/* Design/General */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030000')
go

/* Design/Book */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030010')
go

/* Design/Decorative */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030020')
go

/* Design/Furniture */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030030')
go

/* Design/Textile&Costume */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030040')
go

/* Design/Product */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART030050')
go

/* Design/Commercial/General */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART032000')
go

/* Design/Commercial/Advertising */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART032010')
go

/* Design/Commercial/Illustration */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART032020')
go

/* Design/Typography */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'ART036000')
go

/* Comics & Graphic Novels /History & Criticism */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'CGN005000')
go

/* Computers /Programming /Languages /CGI */
INSERT INTO temp_inactivecodes_2008 VALUES (
	'COM051340')
go

/* Computers /Hardware/ Workstations*/
INSERT INTO temp_inactivecodes_2008 VALUES (
	'COM076000')
go

