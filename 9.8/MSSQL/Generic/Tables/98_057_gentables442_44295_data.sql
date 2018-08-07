IF NOT EXISTS (SELECT 1 FROM gentables WHERE tableid=442 AND datacode=31)
  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, applid, sortorder, tablemnemonic, externalcode, datadescshort, 
    lastuserid, lastmaintdate, numericdesc1, numericdesc2, bisacdatacode, gen1ind, gen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (442, 31, 'WEB Journal Search Results Update', 'N', NULL, NULL, 'SRCHTYPE', NULL, 'WEB Journals Update', 
    'QSIDBA', getdate(), NULL, NULL, NULL, NULL, NULL, 0, 0, 1, 0)