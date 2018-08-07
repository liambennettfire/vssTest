IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_gt_bisaccodes_2008') AND type = 'U')
  BEGIN
    DROP table temp_gt_bisaccodes_2008
  END
go


CREATE TABLE temp_gt_bisaccodes_2008  (
	Code char(255),
	Literal char(255))   
go

INSERT INTO temp_gt_bisaccodes_2008  VALUES (
	'ANT',
	'ANTIQUES & COLLECTIBLES')   
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'ARC',
	'ARCHITECTURE')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'ART',
	'ART')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'BIB',
	'BIBLES')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'BIO',
	'BIOGRAPHY & AUTOBIOGRAPHY')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'OCC',
	'BODY, MIND & SPIRIT')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'BUS',
	'BUSINESS & ECONOMICS')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'CGN',
	'COMICS & GRAPHIC NOVELS')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'COM',
	'COMPUTERS')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'CKB',
	'COOKING')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'CRA',
	'CRAFTS & HOBBIES')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'CUR',
	'CURRENT EVENTS')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'DRA',
	'DRAMA')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'DES',
	'DESIGN')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'EDU',
	'EDUCATION')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'FAM',
	'FAMILY & RELATIONSHIPS')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'FIC',
	'FICTION')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'FOR',
	'FOREIGN LANGUAGE STUDY')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'GAM',
	'GAMES')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'GAR',
	'GARDENING')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'HEA',
	'HEALTH & FITNESS')

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'HIS',
	'HISTORY')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'HOM',
	'HOUSE & HOME')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'HUM',
	'HUMOR')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'JUV',
	'JUVENILE FICTION')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'JNF',
	'JUVENILE NONFICTION')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'LAN',
	'LANGUAGE ARTS & DISCIPLINES')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'LAW',
	'LAW')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'LCO',
	'LITERARY COLLECTIONS')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'LIT',
	'LITERARY CRITICISM')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'MAT',
	'MATHEMATICS')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'MED',
	'MEDICAL')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'MUS',
	'MUSIC')

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'NAT',
	'NATURE')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'PER',
	'PERFORMING ARTS')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'PET',
	'PETS')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'PHI',
	'PHILOSOPHY')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'PHO',
	'PHOTOGRAPHY')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'POE',
	'POETRY')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'POL',
	'POLITICAL SCIENCE')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'PSY',
	'PSYCHOLOGY')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'REF',
	'REFERENCE')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'REL',
	'RELIGION')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'SCI',
	'SCIENCE')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'SEL',
	'SELF-HELP')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'SOC',
	'SOCIAL SCIENCE')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'SPO',
	'SPORTS & RECREATION')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'STU',
	'STUDY AIDS')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'TEC',
	'TECHNOLOGY & ENGINEERING')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'TRA',
	'TRANSPORTATION')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'TRV',
	'TRAVEL')
go


INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'TRU',
	'TRUE CRIME')
go

INSERT INTO temp_gt_bisaccodes_2008 VALUES (
	'NON',
	'NON-CLASSIFIABLE')
go
