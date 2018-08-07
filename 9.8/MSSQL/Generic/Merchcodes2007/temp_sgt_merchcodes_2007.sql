IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_merchcodes_2007') AND type = 'U')
BEGIN
DROP table temp_sgt_merchcodes_2007
END
go

CREATE TABLE temp_sgt_merchcodes_2007  (
	Code char(255),
	Literal char(255))   
go

INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET010',
	'African')
go

INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET020',
	'African-American')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET022',
	'Asian / General')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET040',
	'Asian / Chinese')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET110',
	'Asian / Japanese')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET130',
	'Asian / Korean')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET220',
	'Asian / Vietnamese')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET026',
	'Australian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET030',
	'British')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET034',
	'Canadian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET038',
	'Caribbean')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET050',
	'French')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET060',
	'German')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET070',
	'Hispanic')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET080',
	'Indian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET090',
	'Irish')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET100',
	'Italian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET120',
	'Jewish')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET135',
	'Middle Eastern')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET140',
	'Multicultural')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET150',
	'Native American')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET160',
	'Polish')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET170',
	'Portuguese')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET180',
	'Russian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET190',
	'Scandinavian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET200',
	'Scottish')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'ET210',
	'Spanish')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV010',
	'Anniversary')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV020',
	'Back to School')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV030',
	'Baptism')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV040',
	'Bar Mitzvah - Bat Mitzvah')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV050',
	'Birthday')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV060',
	'Confirmation')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV065',
	'Fall')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV070',
	'First Communion')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV080',
	'Graduation')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV084',
	'Spring')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV086',
	'Summer')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV090',
	'Summer Vacation Reading')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV100',
	'Wedding')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'EV110',
	'Winter')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL005',
	'Chinese New Year')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL010',
	'Christmas')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL030',
	'Earth Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL040',
	'Easter')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL050',
	'Election Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL060',
	'Father''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL070',
	'Halloween')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL080',
	'Hanukah')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL090',
	'Independence Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL100',
	'Kwanza')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL110',
	'Martin Luther King, Jr. Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL120',
	'Memorial Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL130',
	'Mother''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL140',
	'Passover')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL150',
	'President''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL160',
	'St. Patrick''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL170',
	'Thanksgiving')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL180',
	'Valentine''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'HL190',
	'Veteran''s Day')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP020',
	'Black History')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP024',
	'Blank Books, Journals')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP026',
	'Boy''s Interest')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP028',
	'Christian Interest')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP034',
	'Coming of Age')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP050',
	'Gay & Lesbian')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP054',
	'Gift')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP058',
	'Girl''s Interest')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP060',
	'Health & Fitness')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP062',
	'Heroes, Real Life')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP064',
	'Inspiration')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP066',
	'Internet')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP086',
	'Teen')
go
INSERT INTO temp_sgt_merchcodes_2007 VALUES (
	'TP090',
	'Women''s Interest')
go