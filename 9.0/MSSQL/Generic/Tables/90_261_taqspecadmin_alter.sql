UPDATE taqspecadmin SET showunitofmeasureind = 0 WHERE showunitofmeasureind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN showunitofmeasureind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_showunitofmeasureind DEFAULT 0 FOR showunitofmeasureind
go

UPDATE taqspecadmin SET usefunctionforitemdetailind = 0 WHERE usefunctionforitemdetailind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN usefunctionforitemdetailind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_usefunctionforitemdetailind DEFAULT 0 FOR usefunctionforitemdetailind
go

UPDATE taqspecadmin SET usefunctionforqtyind = 0 WHERE usefunctionforqtyind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN usefunctionforqtyind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_usefunctionforqtyind DEFAULT 0 FOR usefunctionforqtyind
go

UPDATE taqspecadmin SET usefunctionfordescind = 0 WHERE usefunctionfordescind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN usefunctionfordescind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_usefunctionfordescind DEFAULT 0 FOR usefunctionfordescind
go

UPDATE taqspecadmin SET usefunctionfordecimalind = 0 WHERE usefunctionfordecimalind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN usefunctionfordecimalind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_usefunctionfordecimalind DEFAULT 0 FOR usefunctionfordecimalind
go

UPDATE taqspecadmin SET usefunctionforuomind = 0 WHERE usefunctionforuomind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN usefunctionforuomind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_usefunctionforuomind DEFAULT 0 FOR usefunctionforuomind
go

UPDATE taqspecadmin SET showdesc2ind = 0 WHERE showdesc2ind IS NULL
go

ALTER TABLE taqspecadmin
ALTER COLUMN showdesc2ind TINYINT NOT NULL
go

ALTER TABLE taqspecadmin
ADD CONSTRAINT DF_taqspecadm_showdesc2ind DEFAULT 0 FOR showdesc2ind
go
