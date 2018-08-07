CREATE TABLE cloudaccess
  (id INT NOT NULL DEFAULT 1,
  clientid VARCHAR(40) NULL,
  clientsecret VARCHAR(40) NULL,
  app	VARCHAR(10) NULL,
  catalogapp VARCHAR(10) NULL,
  apiurl VARCHAR(255) NULL,
  lastuserid VARCHAR(30) NULL,
  lastmaintdate DATETIME NULL)
go

GRANT SELECT ON cloudaccess TO PUBLIC
go
GRANT INSERT ON cloudaccess TO PUBLIC
go
GRANT UPDATE ON cloudaccess TO PUBLIC
go
GRANT DELETE ON cloudaccess TO PUBLIC
go


ALTER TABLE cloudaccess
ADD CONSTRAINT cloudaccess_qp PRIMARY KEY (id)
go