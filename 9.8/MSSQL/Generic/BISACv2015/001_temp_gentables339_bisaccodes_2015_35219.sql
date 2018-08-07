IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_gt_bisaccodes_2015') AND type = 'U')
  BEGIN
    DROP table temp_gt_bisaccodes_2015
  END
go


CREATE TABLE temp_gt_bisaccodes_2015  (
	Code char(255),
	Literal char(255))   
go

INSERT INTO temp_gt_bisaccodes_2015  VALUES (
	'YAF',
	'YOUNG ADULT FICTION')   
go


INSERT INTO temp_gt_bisaccodes_2015 VALUES (
	'YAN',
	'YOUNG ADULT NONFICTION')
go