IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_29_nocodes') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_29_nocodes
  END
go

CREATE TABLE temp_sgt_bisaccodes_29_nocodes (
   Code char(255),
	Literal char(255))  
go

INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
   'BODY, MIND & SPIRIT',
   'Zen Buddhism see PHILOSOPHY / Zen or RELIGION / Buddhism / Zen')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
   'RELIGION',
   'Canon & Ecclesiastical Law see Christian Church / Canon & Ecclesiastical Law')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
   'Christian Literature see Christianity / Literature & the Arts')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
  'Christian Theology / Doctrinal see Christian Theology / Systematic')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
	'Christianity / Congregational see Christianity / United Church of Christ (Congregational)')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
    'Christianity / Friends see Christianity / Quaker')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
   'Christianity / Holy Spirit see Christian Theology / Pneumatology')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES ( 
	'RELIGION',
   'Christianity / Mormon see Christianity / Church of Jesus Christ of Latter-Day Saints (Mormon)')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES ( 
	'RELIGION',
  'Christianity / Roman Catholic see Christianity / Catholic')
 go  
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION', 
   'Christianity / Society of Friends see Christianity / Quaker')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES ( 
	'RELIGION',
  'Church Administration see Christian Church / Administration')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
   'Discipleship see Christian Ministry / Discipleship')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
   'Ecclesiastical Law see Christian Church / Canon & Ecclesiastical Law')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
   'Evangelism see Christian Ministry / Evangelism')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
  'Pastoral Counseling see Christian Ministry / Counseling & Recovery')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
  'Pastoral Ministry see Christian Ministry / Pastoral Resources')
go 
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
	'Stewardship see Christian Life / Stewardship & Giving')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
	'Sufi see Islam / Sufi')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
	'Taoism (see also PHILOSOPHY / Taoist)')
go
INSERT INTO temp_sgt_bisaccodes_29_nocodes VALUES (
	'RELIGION',
	'Youth Ministries see Christian Education / Children & Youth')
go 