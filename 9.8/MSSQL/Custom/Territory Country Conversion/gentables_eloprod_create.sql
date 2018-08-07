IF EXISTS (SELECT * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'gentables_eloprod')
    DROP TABLE gentables_eloprod;

CREATE TABLE gentables_eloprod
  (tableid   int  NOT NULL,
	 datacode   int  NOT NULL,
	 datadesc   varchar (40) NULL,
	 deletestatus   varchar (1) NULL CONSTRAINT  DF_gentables_deletestatus1   DEFAULT ('N'),
	 applid   varchar (2) NULL,
	 sortorder   int  NULL,
	 tablemnemonic   varchar (40) NOT NULL,
	 externalcode   varchar (30) NULL,
	 datadescshort   varchar (20) NULL,
	 lastuserid   varchar (30) NULL,
	 lastmaintdate   datetime  NULL,
	 numericdesc1   float  NULL,
	 numericdesc2   float  NULL,
	 bisacdatacode   varchar (25) NULL,
	 gen1ind   tinyint  NULL,
	 gen2ind   tinyint  NULL,
	 acceptedbyeloquenceind   int  NULL,
	 exporteloquenceind   int  NULL,
	 lockbyqsiind   int  NULL,
	 lockbyeloquenceind   int  NULL,
	 eloquencefieldtag   varchar (25) NULL,
	 alternatedesc1   varchar (255) NULL,
	 alternatedesc2   varchar (255) NULL,
	 qsicode   smallint  NULL,
	 onixcode   varchar (30) NULL,
	 onixcodedefault   tinyint  NULL DEFAULT ((0))
) 
GO

GRANT SELECT ON gentables_eloprod TO PUBLIC
go
GRANT INSERT ON gentables_eloprod TO PUBLIC
go
GRANT UPDATE ON gentables_eloprod TO PUBLIC
go
GRANT DELETE ON gentables_eloprod TO PUBLIC
go
