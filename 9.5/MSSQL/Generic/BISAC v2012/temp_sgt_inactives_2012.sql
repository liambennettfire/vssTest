IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_inactives_2012') AND type = 'U')
  BEGIN
    DROP table temp_sgt_inactives_2012
  END
go

CREATE TABLE temp_sgt_inactives_2012 (
	Code char(255))
go
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'COM060060')
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'COM069010')
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'FIC020000')
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'OCC036020')
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'PET006010')
INSERT INTO temp_sgt_inactives_2012 VALUES (
	'SPO013000')
go