DECLARE
  @v_max_subcode INT,
  @v_specs_datacode INT
  
BEGIN

  SELECT @v_specs_datacode = datacode
  FROM gentables
  WHERE tableid = 636 and LOWER(datadesc) = 'specification'
  
  SELECT @v_max_subcode = COALESCE(MAX(datasubcode),0)
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_specs_datacode

  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, 
    lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, @v_specs_datacode, @v_max_subcode + 1, 'Component List – Related Project', 'N', 0, 'SECCNFG', 'Component–Rel Proj', 
    'QSIDBA', GETDATE(), 0, 0, 1, 0)

END
go

