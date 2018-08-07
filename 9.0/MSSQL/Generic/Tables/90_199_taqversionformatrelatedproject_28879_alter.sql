CREATE TABLE taqversionformatrelatedproject
  (taqversionformatrelatedkey INT NOT NULL,
   taqversionformatkey INT NOT NULL,
   taqprojectkey INT NOT NULL,
   relatedprojectkey INT NOT NULL,
   relatedversionformatkey INT NOT NULL,
   plantcostpercent DECIMAL(9,2) NULL,
   editioncostpercent DECIMAL(9,2) NULL,
   lastuserid VARCHAR(30) NULL,
   lastmaintdate DATETIME NULL)
go

GRANT SELECT ON taqversionformatrelatedproject TO PUBLIC
go
GRANT INSERT ON taqversionformatrelatedproject TO PUBLIC
go
GRANT UPDATE ON taqversionformatrelatedproject TO PUBLIC
go
GRANT DELETE ON taqversionformatrelatedproject TO PUBLIC
go


ALTER TABLE taqversionformatrelatedproject
ADD CONSTRAINT taqversionformatrelatedproject_qp PRIMARY KEY (taqversionformatrelatedkey)
go