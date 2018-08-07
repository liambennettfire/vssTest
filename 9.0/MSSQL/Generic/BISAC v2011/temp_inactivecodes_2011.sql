IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_inactives_2011') AND type = 'U')
  BEGIN
    DROP table temp_sgt_inactives_2011
  END
go

CREATE TABLE temp_sgt_inactives_2011 (
	Code char(255))
go
INSERT INTO temp_sgt_inactives_2011 VALUES (
	'HEA026000')
go