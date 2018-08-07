UPDATE titlehistorycolumns 
SET workfieldind = 1 
WHERE tablename = 'printing' 
  AND columnname IN ('trimsizeunitofmeasure', 'spinesize', 'spinesizeunitofmeasure')