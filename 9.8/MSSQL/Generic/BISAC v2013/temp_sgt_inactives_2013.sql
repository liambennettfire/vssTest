IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_inactives_2013') AND type = 'U')
  BEGIN
    DROP table temp_sgt_inactives_2013
  END
go

CREATE TABLE temp_sgt_inactives_2013 (
	Code char(255))
go
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'CGN004220')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'COM051160')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'CRA019000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM010000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM011000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM018000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM019000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM027000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'FAM031000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'JNF012020')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'JNF049160')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'JNF049270')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'JNF049300')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'JUV033130')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'OCC036000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'PSY018000')
INSERT INTO temp_sgt_inactives_2013 VALUES (
	'SEL018000')
go