-- Add Culture field to Project Detail sections
DECLARE
  @v_datacode INT,
  @v_datasubcode INT,
  @v_datadesc VARCHAR(100),
  @v_datadescshort VARCHAR(40),
  @v_alternatedesc1 VARCHAR(40),
  @v_column INT,
  @v_sortorder INT
  
DECLARE @InsertTable TABLE
(
  datacode int,
  datasubcode int,
  numericdesc1 int,
  sortorder int,
  datadesc varchar(100),
  datadescshort varchar(40),
  alternatedesc1 varchar(40)
)

SET @v_sortorder = 0 -- Set all to hidden

-- TAQ Project Details
INSERT INTO @InsertTable
  (datacode, datasubcode, numericdesc1, sortorder, datadesc, datadescshort, alternatedesc1)
VALUES
  (12, 23, 3, @v_sortorder, 'Culture', 'Culture', 'Culture')
  
-- Other Project Details
INSERT INTO @InsertTable
  (datacode, datasubcode, numericdesc1, sortorder, datadesc, datadescshort, alternatedesc1)
VALUES
  (13, 26, 2, @v_sortorder, 'Culture', 'Culture', 'Culture')
  
DECLARE ins_cur CURSOR FOR
SELECT datacode, datasubcode, numericdesc1, sortorder, datadesc, datadescshort, alternatedesc1
FROM @InsertTable

OPEN ins_cur

FETCH ins_cur INTO
  @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_datadesc, @v_datadescshort, @v_alternatedesc1

WHILE @@FETCH_STATUS = 0
BEGIN
  IF NOT EXISTS(SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode AND datasubcode = @v_datasubcode)
  BEGIN
    INSERT INTO subgentables
      (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, numericdesc1,
      subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1,
      subgen3ind, subgen4ind, lastuserid, lastmaintdate)
    VALUES
      (636, @v_datacode, @v_datasubcode, @v_datadesc, 'N', @v_sortorder, 'SECCNFG', @v_datadescshort, @v_column, 
      0, 0, 0, 0, 1, 0, @v_alternatedesc1,
      0, 0, 'QSIDBA', getdate())

    IF @@ERROR <> 0 BEGIN
      PRINT 'Insert to subgentables had an error: tableid=636, datacode=' + cast(@v_datacode AS VARCHAR) + ', desc= ' + @v_datadesc
      GOTO ErrorExit
    END 
  END    
  
  FETCH ins_cur INTO
    @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_datadesc, @v_datadescshort, @v_alternatedesc1
END

ErrorExit:
CLOSE ins_cur
DEALLOCATE ins_cur
  
GO