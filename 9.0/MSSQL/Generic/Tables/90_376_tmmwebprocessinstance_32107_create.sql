CREATE TABLE tmwebprocessinstance
  (processinstancekey INT NOT NULL,
   processcode INT NOT NULL,
   lastuserid VARCHAR(30) NULL,
   lastmaintdate DATETIME NULL)
go

GRANT SELECT ON tmwebprocessinstance TO PUBLIC
go
GRANT INSERT ON tmwebprocessinstance TO PUBLIC
go
GRANT UPDATE ON tmwebprocessinstance TO PUBLIC
go
GRANT DELETE ON tmwebprocessinstance TO PUBLIC
go


ALTER TABLE tmwebprocessinstance
ADD CONSTRAINT tmwebprocessinstance_qp PRIMARY KEY (processinstancekey)
go