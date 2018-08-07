-- Creating a backup table
IF OBJECT_ID('dbo.territoryrightscleanup', 'U') IS NOT NULL BEGIN
  DROP TABLE dbo.territoryrightscleanup
END  

CREATE TABLE territoryrightscleanup 
  (isbn VARCHAR(13) NULL,
  bookkey INT NULL,
  description VARCHAR(2000) NULL,
  lastuserid VARCHAR(30),
  lastmaintdate datetime NULL
  )
go

GRANT SELECT ON territoryrightscleanup TO PUBLIC
go
GRANT INSERT ON territoryrightscleanup TO PUBLIC
go
GRANT UPDATE ON territoryrightscleanup TO PUBLIC
go
GRANT DELETE ON territoryrightscleanup TO PUBLIC
go
