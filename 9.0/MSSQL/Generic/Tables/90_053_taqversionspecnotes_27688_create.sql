CREATE TABLE taqversionspecnotes
  (taqversionspecnotekey INT NOT NULL,
   taqversionspecategorykey INT NOT NULL,
   text varchar(max) NULL,
   showonpoind  tinyint NULL,
   copynextprtgind  tinyint NULL,
   sortorder  INT NULL,
   lastuserid VARCHAR(30) NULL,
   lastmaintdate DATETIME NULL)
go

GRANT SELECT ON taqversionspecnotes TO PUBLIC
go
GRANT INSERT ON taqversionspecnotes TO PUBLIC
go
GRANT UPDATE ON taqversionspecnotes TO PUBLIC
go
GRANT DELETE ON taqversionspecnotes TO PUBLIC
go


ALTER TABLE taqversionspecnotes
ADD CONSTRAINT taqversionspecnotes_qp PRIMARY KEY (taqversionspecnotekey,taqversionspecategorykey)
go