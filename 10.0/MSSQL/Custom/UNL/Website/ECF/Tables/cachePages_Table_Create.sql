
IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qweb_ecf_CachePages') )
DROP TABLE dbo.qweb_ecf_CachePages
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-----------------------------------------------------------------------
--
-- Created 2/26/2009 by Jonathan Hess  
-- as part of the cache engine concept for ECF sites.
--
-----------------------------------------------------------------------

CREATE TABLE dbo.qweb_ecf_CachePages (
	ROW_ID int IDENTITY(1,1) NOT NULL,
	CREATE_DATE datetime NULL,
	URL varchar(max) NOT NULL,
	COMMENT varchar(max) NULL,
	ACTIVE varchar(10) NULL,
	LAST_MAINT_DATE datetime NULL ) 
	
go
CREATE unique index ROW_ID_PQ ON qweb_ecf_CachePages (ROW_ID)
go
GRANT SELECT ON qweb_ecf_CachePages TO PUBLIC
go
GRANT INSERT ON qweb_ecf_CachePages TO PUBLIC
go
GRANT UPDATE ON qweb_ecf_CachePages TO PUBLIC
go
GRANT DELETE ON qweb_ecf_CachePages TO PUBLIC
go
ALTER TABLE dbo.qweb_ecf_CachePages 
ADD CONSTRAINT qweb_ecf_ROW_ID_PK PRIMARY KEY (ROW_ID)
go

