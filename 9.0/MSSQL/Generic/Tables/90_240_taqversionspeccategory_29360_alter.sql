ALTER TABLE taqversionspeccategory
ADD deriveqtyfromfgqty TINYINT NOT NULL CONSTRAINT DF_taqversionspeccategory_deriveqtyfromfgqty DEFAULT 0,
  spoilagepercentage DECIMAL(9,2) NULL
go
