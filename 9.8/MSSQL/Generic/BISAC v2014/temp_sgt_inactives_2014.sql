IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_inactives_2014') AND type = 'U')
  BEGIN
    DROP table temp_sgt_inactives_2014
  END
go

CREATE TABLE temp_sgt_inactives_2014 (
	Code char(255))
go
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'ANT042020')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'ANT042030')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'ANT042040')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021000')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021010')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021020')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021030')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021040')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021050')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021060')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'BIB021070')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'EDU047000')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'GAM001020')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'GAM002020')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'JNF054090')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'JUV032050')
INSERT INTO temp_sgt_inactives_2014 VALUES (
	'JUV032130')

go