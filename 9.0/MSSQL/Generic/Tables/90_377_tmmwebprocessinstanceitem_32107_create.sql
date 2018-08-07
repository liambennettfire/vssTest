CREATE TABLE tmwebprocessinstanceitem
  (processinstancekey INT NOT NULL,
   sortorder INT NULL,
   key1	INT NOT NULL,
   key2	INT NULL,
   key3	INT NULL,
   key4	INT NULL,
   key5	INT NULL,
   lastuserid VARCHAR(30) NULL,
   lastmaintdate DATETIME NULL)
go

GRANT SELECT ON tmwebprocessinstanceitem TO PUBLIC
go
GRANT INSERT ON tmwebprocessinstanceitem TO PUBLIC
go
GRANT UPDATE ON tmwebprocessinstanceitem TO PUBLIC
go
GRANT DELETE ON tmwebprocessinstanceitem TO PUBLIC
go


ALTER TABLE tmwebprocessinstanceitem
ADD CONSTRAINT tmwebprocessinstanceitem_qp PRIMARY KEY (processinstancekey)
go