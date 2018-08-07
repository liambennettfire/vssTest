CREATE TABLE dbo.taqprojectaudience
(
	taqprojectkey	INT NOT NULL,
	audiencecode INT NOT NULL,
	sortorder INT NULL,
	lastuserid VARCHAR(30) NULL,
	lastmaintdate DATETIME NULL
  CONSTRAINT pk_taqprojectaudience PRIMARY KEY (taqprojectkey, audiencecode)
)

GRANT SELECT, INSERT, DELETE, UPDATE on dbo.taqprojectaudience to Public
