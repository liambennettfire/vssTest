ALTER TABLE taqversioncosts
ADD taqversionspeccategorykey INT NULL,
  plcalccostsubcode INT NULL,
  compunitcost FLOAT NULL,
  pocostind	TINYINT NOT NULL CONSTRAINT DF_taqversioncosts_pocostind DEFAULT 0
go
