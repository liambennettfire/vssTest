CREATE TABLE dbo.taqprojectdeliverydetails
(
	deliverydetailskey INT NOT NULL,
	taqprojectkey INT NOT NULL,
	quantity INT NULL,
	vesselname VARCHAR(255) NULL,
	etdport DATETIME NULL,
	lastuserid VARCHAR(30) NULL,
	lastmaintdate DATETIME NULL
  CONSTRAINT pk_taqprojectdeliverydetails PRIMARY KEY (deliverydetailskey)
)

GRANT SELECT, INSERT, DELETE, UPDATE on dbo.taqprojectdeliverydetails to Public

GO